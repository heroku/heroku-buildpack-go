package librato

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
	"time"

	"github.com/heroku/x/scrub"
)

// Error is used to report information from a non 200 error returned by Librato.
type Error struct {
	code, retries                    int // return code and retries remaining
	body, rateLimitAgg, rateLimitStd string

	// Used to debug things on occasion if inspection of the original
	// request is necessary.
	dumpedRequest string
}

// Code returned by librato
func (e Error) Code() int {
	return e.code
}

// Temporary error that will be retried?
func (e Error) Temporary() bool {
	return e.retries > 0
}

// Request that generated the error
func (e Error) Request() string {
	return e.dumpedRequest
}

// RateLimit info returned by librato in the X-Librato-RateLimit-Agg and
// X-Librato-RateLimit-Std headers
func (e Error) RateLimit() (string, string) {
	return e.rateLimitAgg, e.rateLimitStd
}

// Body returned by librato.
func (e Error) Body() string {
	return e.body
}

// Error interface
func (e Error) Error() string {
	return fmt.Sprintf("code: %d, retries remaining: %d, body: %s, rate-limit-agg: %s, rate-limit-std: %s", e.code, e.retries, e.body, e.rateLimitAgg, e.rateLimitStd)
}

// extended librato gauge format is used for all metric types.
type gauge struct {
	Name   string  `json:"name"`
	Period float64 `json:"period"`
	Count  int64   `json:"count"`
	Sum    float64 `json:"sum"`
	Min    float64 `json:"min"`
	Max    float64 `json:"max"`
	SumSq  float64 `json:"sum_squares"`
}

// sample the metrics
func (p *Provider) sample(period float64) []gauge {
	p.mu.Lock()
	defer p.mu.Unlock() // should only block New{Histogram,Counter,Gauge}

	if len(p.counters) == 0 && len(p.histograms) == 0 && len(p.gauges) == 0 {
		return nil
	}

	// Assemble all the data we have to send
	var gauges []gauge
	for _, c := range p.counters {
		var v float64
		if p.resetCounters {
			v = c.ValueReset()
		} else {
			v = c.Value()
		}
		gauges = append(gauges, gauge{Name: c.Name, Period: period, Count: 1, Sum: v, Min: v, Max: v, SumSq: v * v})
	}
	for _, g := range p.gauges {
		v := g.Value()
		gauges = append(gauges, gauge{Name: g.Name, Period: period, Count: 1, Sum: v, Min: v, Max: v, SumSq: v * v})
	}
	for _, h := range p.histograms {
		gauges = append(gauges, h.measures(period)...)
	}
	return gauges
}

// batch the metrics into a []*http.Requests
func (p *Provider) batch(u *url.URL, interval time.Duration) ([]*http.Request, error) {
	// Calculate the sample time.
	ivSec := int64(interval / time.Second)
	st := (time.Now().Unix() / ivSec) * ivSec

	// Sample the metrics.
	gauges := p.sample(interval.Seconds())

	if len(gauges) == 0 { // no data to report
		return nil, nil
	}

	// Don't accidentally leak the creds, which can happen if we return the u with a u.User set
	var user *url.Userinfo
	user, u.User = u.User, nil

	nextEnd := func(e int) int {
		e += p.batchSize
		if l := len(gauges); e > l {
			return l
		}
		return e
	}

	requests := make([]*http.Request, 0, len(gauges)/p.batchSize+1)
	for b, e := 0, nextEnd(0); b < len(gauges); b, e = e, nextEnd(e) {
		r := struct {
			Source      string                 `json:"source,omitempty"`
			MeasureTime int64                  `json:"measure_time"`
			Gauges      []gauge                `json:"gauges"`
			Attributes  map[string]interface{} `json:"attributes,omitempty"`
		}{
			Source:      p.source,
			MeasureTime: st,
			Gauges:      gauges[b:e],
		}
		if p.ssa {
			r.Attributes = map[string]interface{}{"aggregate": true}
		}

		var buf bytes.Buffer
		if err := json.NewEncoder(&buf).Encode(r); err != nil {
			return nil, err
		}

		req, err := http.NewRequest(http.MethodPost, u.String(), &buf)
		if err != nil {
			return nil, err
		}
		if user != nil {
			p, _ := user.Password()
			req.SetBasicAuth(user.Username(), p)
		}
		req.Header.Set("Content-Type", "application/json")
		requests = append(requests, req)
	}

	return requests, nil
}

// reportWithRetry the metrics to the url, every interval, with max retries.
func (p *Provider) reportWithRetry(u *url.URL, interval time.Duration) {
	nu := *u // copy the url
	requests, err := p.batch(&nu, interval)
	if err != nil {
		p.errorHandler(err)
		return
	}
	var wg sync.WaitGroup
	for _, req := range requests {
		wg.Add(1)
		go func(req *http.Request) {
			defer wg.Done()
			for r := p.numRetries; r > 0; r-- {
				err := p.report(req)
				if err == nil {
					return
				}
				if terr, ok := err.(Error); ok {
					terr.retries = r - 1
					err = error(terr)
				}
				p.errorHandler(err)
				if err := p.backoff(r - 1); err != nil {
					return
				}
				// Not required with go1.9rc1
				if b, err := req.GetBody(); err == nil {
					req.Body = b
				}
			}
		}(req)
	}
	wg.Wait()
}

// report the request, which already has a Body containing metrics
func (p *Provider) report(req *http.Request) error {
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode/100 != 2 {
		// Best effort, but don't fail on error
		d, _ := ioutil.ReadAll(resp.Body)

		e := Error{
			code:         resp.StatusCode,
			body:         string(d),
			rateLimitAgg: resp.Header.Get("X-Librato-RateLimit-Agg"),
			rateLimitStd: resp.Header.Get("X-Librato-RateLimit-Std"),
		}
		if p.requestDebugging {
			req.Header = scrub.Header(req.Header)

			// Best effort, but don't fail on error
			if b, err := req.GetBody(); err == nil {
				req.Body = b
			}
			d, _ := httputil.DumpRequestOut(req, true)
			e.dumpedRequest = string(d)
		}

		return e
	}
	return nil
}

package librato

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math"
	"math/rand"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	kmetrics "github.com/go-kit/kit/metrics"
)

var (
	doesntmatter = time.Hour
)

func ExampleNew() {
	start := time.Now()
	u, err := url.Parse(DefaultURL)
	if err != nil {
		log.Fatal(err)
	}
	u.User = url.UserPassword("libratoUser", "libratoPassword/Token")

	errHandler := func(err error) {
		log.Println(err)
	}
	p := New(u, 20*time.Second, WithErrorHandler(errHandler))
	c := p.NewCounter("i.am.a.counter")
	h := p.NewHistogram("i.am.a.histogram", DefaultBucketCount)
	g := p.NewGauge("i.am.a.gauge")

	// Pretend applicaion logic....
	c.Add(1)
	h.Observe(time.Since(start).Seconds()) // how long did it take the program to get here.
	g.Set(1000)
	// /Pretend

	// block until we report one final time
	p.Stop()
}

func TestLibratoReportRequestDebugging(t *testing.T) {
	for _, debug := range []bool{true, false} {
		t.Run(fmt.Sprintf("%t", debug), func(t *testing.T) {
			t.Parallel()
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusBadRequest)
			}))
			defer srv.Close()
			u, err := url.Parse(srv.URL)
			if err != nil {
				t.Fatal(err)
			}
			p := New(u, doesntmatter, func(p *Provider) { p.requestDebugging = debug }).(*Provider)
			p.Stop()
			p.NewCounter("foo").Add(1) // need at least one metric in order to report
			reqs, err := p.batch(u, doesntmatter)
			if err != nil {
				t.Fatal("unexpected error", err)
			}
			if len(reqs) != 1 {
				t.Errorf("expected 1 request, got %d", len(reqs))
			}
			err = p.report(reqs[0])
			if err == nil {
				t.Fatal("expected error, got nil")
			}

			e, ok := err.(Error)
			if !ok {
				t.Fatalf("expected an Error, got %T: %q", err, err.Error())
			}

			req := e.Request()
			if debug {
				if req == "" {
					t.Error("unexpected empty request")
				}
			} else {
				if req != "" {
					t.Errorf("expected no request, got %#v", req)
				}
			}

		})
	}
}

type temporary interface {
	Temporary() bool
}

func TestLibratoRetriesWithErrors(t *testing.T) {
	var retried int
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		retried++
		b, err := io.Copy(ioutil.Discard, r.Body)
		if err != nil {
			t.Fatal("Unable to read all of the request body:", err)
		}
		if b == 0 {
			t.Fatal("expected to copy more than 0 bytes")
		}
		w.WriteHeader(http.StatusBadRequest)
	}))
	defer srv.Close()

	u, err := url.Parse(srv.URL)
	if err != nil {
		t.Fatal(err)
	}

	var totalErrors, temporaryErrors, finalErrors int
	expectedRetries := 3
	errHandler := func(err error) {
		totalErrors++
		if terr, ok := err.(temporary); ok {
			if terr.Temporary() {
				temporaryErrors++
			} else {
				finalErrors++
			}
			t.Log(err)
		}
	}
	p := New(u, doesntmatter, WithErrorHandler(errHandler), WithRetries(expectedRetries), WithRequestDebugging()).(*Provider)
	p.Stop()
	p.NewCounter("foo").Add(1) // need at least one metric in order to report
	p.reportWithRetry(u, doesntmatter)

	if totalErrors != expectedRetries {
		t.Errorf("expected %d total errors, got %d", expectedRetries, totalErrors)
	}

	expectedTemporaryErrors := expectedRetries - 1
	if temporaryErrors != expectedTemporaryErrors {
		t.Errorf("expected %d temporary errors, got %d", expectedTemporaryErrors, temporaryErrors)
	}

	expectedFinalErrors := 1
	if finalErrors != expectedFinalErrors {
		t.Errorf("expected %d final errors, got %d", expectedFinalErrors, finalErrors)
	}

	if retried != expectedRetries {
		t.Errorf("expected %d retries, got %d", expectedRetries, retried)
	}
}

func TestLibratoRetriesWithErrorsNoDebugging(t *testing.T) {
	var retried int
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		retried++
		b, err := io.Copy(ioutil.Discard, r.Body)
		if err != nil {
			t.Fatal("Unable to read all of the request body:", err)
		}
		if b == 0 {
			t.Fatal("expected more than 0 bytes in the body")
		}
		w.WriteHeader(http.StatusBadRequest)
	}))
	defer srv.Close()

	u, err := url.Parse(srv.URL)
	if err != nil {
		t.Fatal(err)
	}

	var totalErrors, temporaryErrors, finalErrors int
	expectedRetries := 3
	errHandler := func(err error) {
		totalErrors++
		if terr, ok := err.(temporary); ok {
			if terr.Temporary() {
				temporaryErrors++
			} else {
				finalErrors++
			}
			t.Log(err)
		}
	}
	p := New(u, doesntmatter, WithErrorHandler(errHandler), WithRetries(expectedRetries)).(*Provider)
	p.Stop()
	p.NewCounter("foo").Add(1) // need at least one metric in order to report
	p.reportWithRetry(u, doesntmatter)

	if totalErrors != expectedRetries {
		t.Errorf("expected %d total errors, got %d", expectedRetries, totalErrors)
	}

	expectedTemporaryErrors := expectedRetries - 1
	if temporaryErrors != expectedTemporaryErrors {
		t.Errorf("expected %d temporary errors, got %d", expectedTemporaryErrors, temporaryErrors)
	}

	expectedFinalErrors := 1
	if finalErrors != expectedFinalErrors {
		t.Errorf("expected %d final errors, got %d", expectedFinalErrors, finalErrors)
	}

	if retried != expectedRetries {
		t.Errorf("expected %d retries, got %d", expectedRetries, retried)
	}
}

func TestLibratoBatchingReport(t *testing.T) {
	user := os.Getenv("LIBRATO_TEST_USER")
	pwd := os.Getenv("LIBRATO_TEST_PWD")
	if user == "" || pwd == "" {
		t.Skip("LIBRATO_TEST_USER || LIBRATO_TEST_PWD unset")
	}
	rand.Seed(time.Now().UnixNano())
	u, err := url.Parse(DefaultURL)
	if err != nil {
		t.Fatalf("expected nil, got %q", err)
	}
	u.User = url.UserPassword(user, pwd)

	errs := func(err error) {
		t.Error("unexpected error reporting metrics", err)
	}

	p := New(u, time.Second, WithSource("test.source"), WithErrorHandler(errs))
	h := make([]kmetrics.Histogram, 0, DefaultBatchSize)
	for i := 0; i < DefaultBatchSize; i++ { // each histogram creates multiple gauges
		h = append(h, p.NewHistogram(fmt.Sprintf("test.histogram.%d", i), DefaultBucketCount))
	}

	done := make(chan struct{})
	go func() {
		for i := 0; i < 30; i++ {
			for i := range h {
				h[i].Observe(rand.Float64() * 100)
				h[i].Observe(rand.Float64() * 200)
				h[i].Observe(rand.Float64() * 300)
			}
			time.Sleep(100 * time.Millisecond)
		}
		p.Stop()
		close(done)
	}()

	<-done
	p.Stop() // do a final report
}

func TestLibratoSingleReport(t *testing.T) {
	user := os.Getenv("LIBRATO_TEST_USER")
	pwd := os.Getenv("LIBRATO_TEST_PWD")
	if user == "" || pwd == "" {
		t.Skip("LIBRATO_TEST_USER || LIBRATO_TEST_PWD unset")
	}
	rand.Seed(time.Now().UnixNano())
	u, err := url.Parse(DefaultURL)
	if err != nil {
		t.Fatalf("expected nil, got %q", err)
	}
	u.User = url.UserPassword(user, pwd)

	errs := func(err error) {
		t.Fatal("unexpected error reporting metrics", err)
	}

	p := New(u, doesntmatter, WithSource("test.source"), WithErrorHandler(errs))
	c := p.NewCounter("test.counter")
	g := p.NewGauge("test.gauge")
	h := p.NewHistogram("test.histogram", DefaultBucketCount)
	c.Add(float64(time.Now().Unix())) // increasing value
	g.Set(rand.Float64())
	h.Observe(10)
	h.Observe(100)
	h.Observe(150)
	p.Stop() // does a final report
}

func TestLibratoReport(t *testing.T) {
	user := os.Getenv("LIBRATO_TEST_USER")
	pwd := os.Getenv("LIBRATO_TEST_PWD")
	if user == "" || pwd == "" {
		t.Skip("LIBRATO_TEST_USER || LIBRATO_TEST_PWD unset")
	}
	rand.Seed(time.Now().UnixNano())
	u, err := url.Parse(DefaultURL)
	if err != nil {
		t.Fatalf("expected nil, got %q", err)
	}
	u.User = url.UserPassword(user, pwd)

	errs := func(err error) {
		t.Error("unexpected error reporting metrics", err)
	}

	p := New(u, time.Second, WithSource("test.source"), WithErrorHandler(errs))
	c := p.NewCounter("test.counter")
	g := p.NewGauge("test.gauge")
	h := p.NewHistogram("test.histogram", DefaultBucketCount)

	done := make(chan struct{})

	go func() {
		for i := 0; i < 30; i++ {
			c.Add(float64(time.Now().Unix())) // increasing value
			g.Set(rand.Float64())
			h.Observe(rand.Float64() * 100)
			h.Observe(rand.Float64() * 100)
			h.Observe(rand.Float64() * 100)
			time.Sleep(100 * time.Millisecond)
		}
		p.Stop()
		close(done)
	}()

	<-done
	p.Stop() // does a final report
}

func TestLibratoHistogramJSONMarshalers(t *testing.T) {
	h := Histogram{name: "test.histogram", buckets: DefaultBucketCount, percentilePrefix: ".p"}
	h.reset()
	h.Observe(10)
	h.Observe(100)
	h.Observe(150)
	ePeriod := 1.0
	d := h.measures(ePeriod)
	if len(d) != 4 {
		t.Fatalf("expected length of parts to be 4, got %d", len(d))
	}

	p1, err := json.Marshal(d[0])
	if err != nil {
		t.Fatal("unexpected error unmarshaling", err)
	}
	p99, err := json.Marshal(d[1])
	if err != nil {
		t.Fatal("unexpected error unmarshaling", err)
	}
	p95, err := json.Marshal(d[2])
	if err != nil {
		t.Fatal("unexpected error unmarshaling", err)
	}
	p50, err := json.Marshal(d[3])
	if err != nil {
		t.Fatal("unexpected error unmarshaling", err)
	}

	cases := []struct {
		eRaw, eName              string
		eCount                   int64
		eMin, eMax, eSum, eSumSq float64
		input                    []byte
	}{
		{
			eRaw:   `{"name":"test.histogram","period":1,"count":3,"sum":260,"min":10,"max":150,"sum_squares":32600}`,
			eName:  "test.histogram",
			eCount: 3, eMin: 10, eMax: 150, eSum: 260, eSumSq: 32600,
			input: p1,
		},
		{
			eRaw:   `{"name":"test.histogram.p99","period":1,"count":1,"sum":150,"min":150,"max":150,"sum_squares":22500}`,
			eName:  "test.histogram.p99",
			eCount: 1, eMin: 150, eMax: 150, eSum: 150, eSumSq: 22500,
			input: p99,
		},
		{
			eRaw:   `{"name":"test.histogram.p95","period":1,"count":1,"sum":150,"min":150,"max":150,"sum_squares":22500}`,
			eName:  "test.histogram.p95",
			eCount: 1, eMin: 150, eMax: 150, eSum: 150, eSumSq: 22500,
			input: p95,
		},
		{
			eRaw:   `{"name":"test.histogram.p50","period":1,"count":1,"sum":100,"min":100,"max":100,"sum_squares":10000}`,
			eName:  "test.histogram.p50",
			eCount: 1, eMin: 100, eMax: 100, eSum: 100, eSumSq: 10000,
			input: p50,
		},
	}

	for _, tc := range cases {
		t.Run(tc.eName, func(t *testing.T) {
			t.Parallel()
			if string(tc.input) != tc.eRaw {
				t.Errorf("expected %q\ngot %q", tc.eRaw, tc.input)
			}

			var tg gauge
			err := json.Unmarshal(tc.input, &tg)
			if err != nil {
				t.Fatal("unexpected error unmarshalling", err)
			}

			if tg.Name != tc.eName {
				t.Errorf("expected %q, got %q", tc.eName, tg.Name)
			}
			if tg.Count != tc.eCount {
				t.Errorf("expected %d, got %d", tc.eCount, tg.Count)
			}
			if tg.Period != ePeriod {
				t.Errorf("expected %f, got %f", ePeriod, tg.Period)
			}
			if math.Float64bits(tg.Sum) != math.Float64bits(tc.eSum) {
				t.Errorf("expected %f, got %f", tc.eSum, tg.Sum)
			}
			if math.Float64bits(tg.Min) != math.Float64bits(tc.eMin) {
				t.Errorf("expected %f, got %f", tc.eMin, tg.Min)
			}
			if math.Float64bits(tg.Max) != math.Float64bits(tc.eMax) {
				t.Errorf("expected %f, got %f", tc.eMin, tg.Max)
			}
			if math.Float64bits(tg.SumSq) != math.Float64bits(tc.eSumSq) {
				t.Errorf("expected %f, got %f", tc.eSumSq, tg.SumSq)
			}
		})
	}
}

func TestScrubbing(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		b, err := io.Copy(ioutil.Discard, r.Body)
		if err != nil {
			t.Fatal("Unable to read all of the request body:", err)
		}
		if b == 0 {
			t.Fatal("expected more than 0 bytes in the body")
		}

		w.WriteHeader(http.StatusBadRequest)
	}))
	u, err := url.Parse(srv.URL)
	if err != nil {
		t.Fatal(err)
	}
	errors := make([]error, 0, 100)
	var errCnt int
	errHandler := func(err error) {
		errors = append(errors, err)
		errCnt++
	}
	u.User = url.UserPassword("foo", "bar") // put user info into the URL
	p := New(u, doesntmatter, WithErrorHandler(errHandler), WithRequestDebugging()).(*Provider)
	p.Stop()

	foo := p.NewCounter("foo")
	foo.Add(1)
	p.reportWithRetry(u, doesntmatter)

	for _, err := range errors {
		e, ok := err.(Error)
		if !ok {
			t.Fatalf("expected Error, got %T: %q", err, err.Error())
		}
		request := e.Request()
		if !strings.Contains(request, "Authorization: Basic [SCRUBBED]") {
			t.Errorf("expected Authorization header to be scrubbed, got %q", request)
		}
	}

	// Close the server now so we get an error from the http client
	srv.Close()
	errors = errors[errCnt:]
	p.reportWithRetry(u, doesntmatter)

	for _, err := range errors {
		_, ok := err.(Error)
		if ok {
			t.Errorf("unexpected Error, got %T: %q", err, err.Error())
		}
		if es := err.Error(); strings.Contains(es, "foo") {
			t.Error("expected the error to not contain sensitive data, got", es)
		}
	}

	if errCnt != 2*DefaultNumRetries {
		t.Errorf("expected total error count to be %d, got %d", 2*DefaultNumRetries, errCnt)
	}
}

func TestWithResetCounters(t *testing.T) {
	for _, reset := range []bool{true, false} {
		t.Run(fmt.Sprintf("%t", reset), func(t *testing.T) {
			t.Parallel()
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusOK)
			}))
			defer srv.Close()
			u, err := url.Parse(srv.URL)
			if err != nil {
				t.Fatal(err)
			}
			p := New(u, doesntmatter, func(p *Provider) { p.resetCounters = reset }).(*Provider)
			p.Stop()

			foo := p.NewCounter("foo")
			foo.Add(1)
			reqs, err := p.batch(u, doesntmatter)
			if err != nil {
				t.Fatal("unexpected error batching", err)
			}
			if len(reqs) != 1 {
				t.Errorf("expected 1 request, got %d", len(reqs))
			}
			p.report(reqs[0])

			var expected float64
			if reset {
				expected = 0
			} else {
				expected = 1
			}
			type valuer interface {
				Value() float64
			}
			if v := foo.(valuer).Value(); v != expected {
				t.Errorf("expected %f, got %f", expected, v)
			}
		})
	}
}

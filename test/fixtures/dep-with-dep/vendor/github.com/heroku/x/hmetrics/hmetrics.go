package hmetrics

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"sync"
	"time"
)

const (
	metricWaitTime = 20 * time.Second
)

type AlreadyStarted struct{}

func (as AlreadyStarted) Error() string {
	return "already started"
}

func (as AlreadyStarted) Fatal() bool {
	return false
}

type HerokuMetricsURLUnset struct{}

func (e HerokuMetricsURLUnset) Error() string {
	return "cannot report metrics because HEROKU_METRICS_URL is unset"
}

func (e HerokuMetricsURLUnset) Fatal() bool {
	return true
}

var (
	mu      sync.Mutex
	started bool
)

// ErrHandler receives any errors encountered during collection or reporting of metrics to Heroku. Processing of metrics
// continues if the ErrHandler returns nil, but aborts if the ErrHandler itself returns an error.
type ErrHandler func(err error) error

func Report(ctx context.Context, ef ErrHandler) error {
	mu.Lock()
	defer mu.Unlock()
	if started {
		return AlreadyStarted{}
	}
	endpoint := os.Getenv("HEROKU_METRICS_URL")
	if endpoint == "" {
		return HerokuMetricsURLUnset{}
	}
	if ef == nil {
		ef = func(_ error) error { return nil }
	}
	go report(ctx, endpoint, ef)
	started = true
	return nil
}

// The only thing that should come after an exit() is a return.
// Best to use in a function that can defer it.
func exit() {
	mu.Lock()
	defer mu.Unlock()
	started = false
}

func report(ctx context.Context, endpoint string, ef ErrHandler) {
	defer exit()

	t := time.NewTicker(metricWaitTime)
	defer t.Stop()

	for {
		select {
		case <-t.C:
		case <-ctx.Done():
			return
		}

		if err := gatherMetrics(); err != nil {
			if err := ef(err); err != nil {
				return
			}
			continue
		}
		if err := submitPayload(ctx, endpoint); err != nil {
			if err := ef(err); err != nil {
				return
			}
			continue
		}
	}
}

var (
	lastGCPause uint64
	lastNumGC   uint32
	buf         bytes.Buffer
)

// TODO: If we ever have high frequency charts HeapIdle minus HeapReleased could be interesting.
func gatherMetrics() error {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	// cribbed from https://github.com/codahale/metrics/blob/master/runtime/memstats.go

	pauseNS := stats.PauseTotalNs - lastGCPause
	lastGCPause = stats.PauseTotalNs

	numGC := stats.NumGC - lastNumGC
	lastNumGC = stats.NumGC

	result := struct {
		Counters map[string]float64 `json:"counters"`
		Gauges   map[string]float64 `json:"gauges"`
	}{
		Counters: map[string]float64{
			"go.gc.collections": float64(numGC),
			"go.gc.pause.ns":    float64(pauseNS),
		},
		Gauges: map[string]float64{
			"go.memory.heap.bytes":   float64(stats.Alloc),
			"go.memory.stack.bytes":  float64(stats.StackInuse),
			"go.memory.heap.objects": float64(stats.Mallocs - stats.Frees), // Number of "live" objects.
			"go.gc.goal":             float64(stats.NextGC),                // Goal heap size for next GC.
			"go.routines":            float64(runtime.NumGoroutine()),      // Current number of goroutines.
		},
	}

	buf.Reset()
	return json.NewEncoder(&buf).Encode(result)
}

func submitPayload(ctx context.Context, where string) error {
	req, err := http.NewRequest("POST", where, &buf)
	if err != nil {
		return err
	}
	req = req.WithContext(ctx)
	req.Header.Add("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("expected %v (http.StatusOK) but got %s", http.StatusOK, resp.Status)
	}

	return nil
}

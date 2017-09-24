package metrics

import (
	"github.com/go-kit/kit/metrics"
)

// Provider represents all the kinds of metrics a provider must expose. This is
// here for 2 reasons: (1) go-kit/metrics/provider imports all the providers in
// the world supported by go-kit cluttering up your vendor folder; and (2)
// provider.Provider (hmmmmm stutter)!
type Provider interface {
	NewCounter(name string) metrics.Counter
	NewGauge(name string) metrics.Gauge
	NewHistogram(name string, buckets int) metrics.Histogram
	Stop()
}

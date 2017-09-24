/*
Package discard is copied out of the go-kit metrics, provider package because
importing that package brings in too many dependencies.
*/
package discard

import (
	"github.com/go-kit/kit/metrics"
	"github.com/go-kit/kit/metrics/discard"
	xmetrics "github.com/heroku/x/go-kit/metrics"
)

type discardProvider struct{}

var _ xmetrics.Provider = &discardProvider{}

// New returns a provider that produces no-op metrics via the
// discarding backend.
func New() xmetrics.Provider { return discardProvider{} }

// NewCounter implements Provider.
func (discardProvider) NewCounter(string) metrics.Counter { return discard.NewCounter() }

// NewGauge implements Provider.
func (discardProvider) NewGauge(string) metrics.Gauge { return discard.NewGauge() }

// NewHistogram implements Provider.
func (discardProvider) NewHistogram(string, int) metrics.Histogram { return discard.NewHistogram() }

// Stop implements Provider.
func (discardProvider) Stop() {}

/*
package onload automatically starts up the hmetrics reporting.

Use this package when you don't care about shutting down them metrics reporting or being notified of any reporting
errors.

usage:

import (
	_ "github.com/heroku/x/hmetrics/onload"
)

*/

package onloads

import (
	"context"

	"github.com/heroku/x/hmetrics"
)

func init() {
	hmetrics.Report(context.Background(), nil)
}

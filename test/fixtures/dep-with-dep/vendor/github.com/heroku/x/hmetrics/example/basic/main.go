package main

import (
	"context"
	"net/http"
	"os"

	"github.com/heroku/x/hmetrics"
)

func main() {
	// Don't care about canceling or errors
	hmetrics.Report(context.Background(), nil)

	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}

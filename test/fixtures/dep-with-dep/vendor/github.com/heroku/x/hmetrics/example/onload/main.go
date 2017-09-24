package main

import (
	"net/http"
	"os"

	_ "github.com/heroku/x/hmetrics/onload"
)

func main() {
	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}

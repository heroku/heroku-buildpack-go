package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/heroku/x/hmetrics"
)

type fataler interface {
	Fatal() bool
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	eh := func(err error) error {
		log.Println("Error reporting metrics to heroku:", err)
		return nil
	}
	if err := hmetrics.Report(ctx, eh); err != nil {
		if f, ok := err.(fataler); ok {
			if f.Fatal() {
				log.Fatal(err)
			}
			log.Println(err)
		}
	}

	http.ListenAndServe(":"+os.Getenv("PORT"), nil)
}

package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	pwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	http.Handle("/", http.FileServer(http.Dir(pwd)))
	http.ListenAndServe(":"+port, nil)
}

package main

import (
	"fmt"

	"github.com/heroku/x/scrub"
)

func main() {
	fmt.Println("hello")
	fmt.Println(scrub.RestrictedParams["access_token"])
}

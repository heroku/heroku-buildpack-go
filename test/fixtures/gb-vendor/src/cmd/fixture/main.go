package main

import "fmt"
import "github.com/heroku/slog"

func main() {
	c := slog.Context{}
	c.Add("test", "me")
	fmt.Println(c)
}

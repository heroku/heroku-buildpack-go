package main

import "fmt"
import "github.com/heroku/slog"

func main() {
	ctx := slog.Context{}
	ctx.Add("fixture", true)
	fmt.Println(ctx)
}

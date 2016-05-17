package main

import (
	"fmt"

	"github.com/heroku/slog"
)

func main() {
	ctx := slog.Context{}
	ctx.Count("hello", 1)
	fmt.Println(ctx)
}

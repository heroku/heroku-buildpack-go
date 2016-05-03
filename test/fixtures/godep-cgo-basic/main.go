package main

import (
	"fmt"

	// Check pgdriver.go for for CGO flags
	_ "github.com/jbarham/gopgsqldriver"
)

func main() {
	fmt.Println("hello")
}

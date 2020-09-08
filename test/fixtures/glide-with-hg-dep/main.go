package main

import "fmt"
import "bitbucket.org/pkg/urlenc"

func main() {
	i := urlenc.Unmarshal
	fmt.Println(i)
}

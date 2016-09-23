package sub

import (
	"fmt"
	"testing"
)

func TestHello(t *testing.T) {
	if h := Hello(); h != "hello" {
		t.Fatal("Expected Hello() to return 'hello', instead got:", h)
	}
}

func ExampleHello() {
	fmt.Println(Hello())
	// Output:
	// hello
}

func BenchmarkHello(b *testing.B) {
	var h string
	for i := 0; i < b.N; i++ {
		h = Hello()
	}
	_ = h
}

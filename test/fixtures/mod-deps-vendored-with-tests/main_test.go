package main

import "testing"

func Test_BasicTest(t *testing.T) {
	one := 1
	if 1 != one {
		t.Fatalf("expected 1 == 1")
	}
}

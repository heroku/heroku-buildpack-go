package main

import "testing"

func Test_BasicTest(t *testing.T) {
	one := 1
	if one != 1 {
		t.Fatalf("expected 1 == 1")
	}
}

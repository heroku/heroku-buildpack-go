package main

import (
	"testing"
)

func TestMerge(t *testing.T) {
	r := merge(map[string]string{"A": "1"}, []string{"B=2"})
	if r[0] != "B=2" {
		t.Errorf("expected B=2, got %q", r[0])
	}
	if r[1] != "A=1" {
		t.Errorf("expected A=1, got %q", r[1])
	}
}

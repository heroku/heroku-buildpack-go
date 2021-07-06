package urlenc

import (
	"testing"
)

type Person struct {
	Name         string
	Age          int
	Hobbies      []string
	Alive        bool
	LuckyNumbers []int
}

func includesInt(list []int, pat int) bool {
	for _, s := range list {
		if s == pat {
			return true
		}
	}
	return false
}

func includesString(list []string, pat string) bool {
	for _, s := range list {
		if s == pat {
			return true
		}
	}
	return false
}

func TestUnmarshal(t *testing.T) {
	b := []byte("Name=Jeff&Age=18&Hobbies=swimming&Hobbies=running&Alive=true&LuckyNumbers=3&LuckyNumbers=7")
	p := new(Person)
	err := Unmarshal(b, &p)
	if err != nil {
		t.Error(err)
	}
	if p.Name != "Jeff" {
		t.Errorf("expected to Unmarshal name to Jeff got: %s", p.Name)
	}
	if p.Age != 18 {
		t.Errorf("expected to Unmarshal Age to 18 got %d", p.Age)
	}
	if len(p.Hobbies) < 2 || !includesString(p.Hobbies, "swimming") || !includesString(p.Hobbies, "running") {
		t.Errorf("expetcted to Unmarshal Hobbies to contain swimming & running got: %v", p.Hobbies)
	}
	if !p.Alive {
		t.Errorf("expected to Unmarshal Alive to true got: %v", p.Alive)
	}
	if len(p.LuckyNumbers) < 2 || !includesInt(p.LuckyNumbers, 3) || !includesInt(p.LuckyNumbers, 7) {
		t.Errorf("expetcted to Unmarshal LuckyNumbers to contain 3 & 7 got: %v", p.LuckyNumbers)
	}
}

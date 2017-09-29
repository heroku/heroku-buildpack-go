package cache

import (
	"context"
	"testing"
)

func TestLRUCapacity(t *testing.T) {
	_, err := NewLRU(0)
	if err == nil {
		t.Errorf("NewLRU should not allow 0 capacity cache")
	}
}

func TestLRU(t *testing.T) {
	ctx := context.Background()
	underTest, _ := NewLRU(2)

	// Populate 3 items, forcing "foo" out.
	underTest.Put(ctx, "foo", 1)
	underTest.Put(ctx, "bar", 2)
	underTest.Put(ctx, "baz", 3)

	_, ok := underTest.Get(ctx, "foo")
	if ok {
		t.Fatalf("foo was found, but should have been evicted.")
	}

	bari, ok := underTest.Get(ctx, "bar")
	if !ok {
		t.Fatalf("bar was not found")
	}
	bar, ok := bari.(int)
	if !ok {
		t.Fatalf("bar was Put as an int, but is a %t", bari)
	}

	underTest.Put(ctx, "bar", bar*2)
	underTest.Put(ctx, "foo", 1)

	_, ok = underTest.Get(ctx, "foo")
	if !ok {
		t.Fatalf("after Put, foo should now be available")
	}

	_, ok = underTest.Get(ctx, "baz")
	if ok {
		t.Fatalf("baz was found, but should have been evicted.")
	}

	bari, ok = underTest.Get(ctx, "bar")
	if !ok {
		t.Fatalf("bar was not found")
	}
	bar, ok = bari.(int)
	if !ok {
		t.Fatalf("bar was Put as an int, but is a %t", bari)
	}
	if bar != 4 {
		t.Fatalf("expected bar to be 10, got %d", bar)
	}
}

func TestLRUDelete(t *testing.T) {
	ctx := context.Background()
	underTest, _ := NewLRU(2)

	// Populate 3 items, forcing "foo" out.
	underTest.Put(ctx, "foo", 1)
	_, ok := underTest.Get(ctx, "foo")
	if !ok {
		t.Fatalf("foo was Put, but was not found")
	}

	underTest.Delete(ctx, "foo")

	_, ok = underTest.Get(ctx, "foo")
	if ok {
		t.Fatalf("foo was Deleted, but was found")
	}
}

func BenchmarkLRUPut(b *testing.B) {
	keys := []string{"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
	ctx := context.Background()
	underTest, _ := NewLRU(10)

	for i := 0; i < b.N; i++ {
		underTest.Put(ctx, keys[i%len(keys)], i)
	}
}

func BenchmarkLRUGet(b *testing.B) {
	keys := []string{"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
	ctx := context.Background()
	underTest, _ := NewLRU(10)
	for i := 0; i < 10; i++ {
		underTest.Put(ctx, keys[i%len(keys)], i)
	}

	for i := 0; i < b.N; i++ {
		underTest.Get(ctx, keys[i%10])
	}
}

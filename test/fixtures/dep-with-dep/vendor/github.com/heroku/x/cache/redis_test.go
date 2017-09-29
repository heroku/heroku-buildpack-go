package cache

import (
	"testing"
)

func TestRedisImplementsCache(t *testing.T) {
	var i interface{} = Redis{}
	if _, ok := i.(Cache); !ok {
		t.Fatalf("type Redis does not implement interface Cache")
	}
}

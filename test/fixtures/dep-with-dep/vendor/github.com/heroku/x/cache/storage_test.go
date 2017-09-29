package cache

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/garyburd/redigo/redis"
)

func TestHashImplementsStorage(t *testing.T) {
	var i interface{} = Hash{}
	if _, ok := i.(Storage); !ok {
		t.Fatalf("type Hash does not implement interface Storage")
	}
}

func TestVolatileImplementsStorage(t *testing.T) {
	var i interface{} = Volatile{}
	if _, ok := i.(Storage); !ok {
		t.Fatalf("type Volatile does not implement interface Storage")
	}
}

var rurl string

func init() {
	rurl = os.Getenv("REDIS_URL")
}

func makeHash(p *redis.Pool) Storage {
	return Hash{Pool: p}
}

func makeVolatile(p *redis.Pool) Storage {
	return Volatile{Pool: p, TTL: 10 * time.Minute}
}

func TestStorageImpls(t *testing.T) {
	if rurl == "" {
		t.Skip("Skipping because there's no REDIS URL")
	}

	cases := []struct {
		name           string
		storageCreator func(p *redis.Pool) Storage
	}{
		{
			name:           "Hash",
			storageCreator: makeHash,
		},
		{
			name:           "Volatile",
			storageCreator: makeVolatile,
		},
	}

	var testval = []byte("remember, remember the fifth of november")

	pool, err := NewPool(rurl)
	if err != nil {
		t.Fatalf("NewPool: %v", err)
	}

	for _, cs := range cases {
		t.Run(cs.name, func(tt *testing.T) {
			st := cs.storageCreator(pool)
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
			defer cancel()

			// Put
			err := st.Put(ctx, tt.Name(), cs.name, testval)
			if err != nil {
				tt.Fatalf("Put: %v", err)
			}

			// Get
			fromRedis, err := st.Get(ctx, tt.Name(), cs.name)
			if err != nil {
				tt.Fatalf("Get: %v", err)
			}

			if string(fromRedis) != string(testval) {
				tt.Fatalf("expected %q but got: %q", string(testval), string(fromRedis))
			}

			// Delete
			ok, err := st.Delete(ctx, tt.Name(), cs.name)
			if err != nil {
				tt.Fatalf("Delete: %v", err)
			}
			if !ok {
				tt.Fatalf("Delete did not delete any redis values")
			}
		})
	}
}

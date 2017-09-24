package cache

import (
	"context"
	"time"

	"github.com/garyburd/redigo/redis"
	"github.com/go-kit/kit/metrics"
)

// Storage is a common interface for the different kinds of ways redis is used
// at Heroku.
type Storage interface {
	Get(ctx context.Context, prefix, key string) ([]byte, error)
	Put(ctx context.Context, prefix, key string, buf []byte) error
	Delete(ctx context.Context, prefix, key string) (bool, error)
}

// Hash uses redis hashes to store data.
type Hash struct {
	Pool *redis.Pool

	// metrics
	PutTimes, GetTimes, DeleteTimes metrics.Histogram
}

func measure(h metrics.Histogram, start time.Time) {
	if h == nil { // guard against it not being set
		return
	}
	h.Observe(time.Since(start).Seconds())
}

// Put inserts an item into a redis Hash.
func (h Hash) Put(ctx context.Context, prefix, key string, buf []byte) error {
	conn := h.Pool.Get()
	defer conn.Close()

	defer measure(h.PutTimes, time.Now())
	_, err := conn.Do("HSET", prefix, key, buf)
	return err
}

// Get retrieves an item from a redis Hash.
func (h Hash) Get(ctx context.Context, prefix, key string) ([]byte, error) {
	conn := h.Pool.Get()
	defer conn.Close()

	defer measure(h.GetTimes, time.Now())
	return redis.Bytes(conn.Do("HGET", prefix, key))
}

// Delete removes an item from a redis Hash.
func (h Hash) Delete(ctx context.Context, prefix, key string) (bool, error) {
	conn := h.Pool.Get()
	defer conn.Close()

	defer measure(h.DeleteTimes, time.Now())
	return redis.Bool(conn.Do("HDEL", prefix, key))
}

// Volatile uses redis key->value pairs with a common expiration time-to-live.
type Volatile struct {
	TTL  time.Duration
	Pool *redis.Pool

	// metrics
	PutTimes, GetTimes, DeleteTimes metrics.Histogram
}

// Put inserts an item into redis with a time-to-live.
func (v Volatile) Put(ctx context.Context, prefix, key string, buf []byte) error {
	conn := v.Pool.Get()
	defer conn.Close()

	defer measure(v.PutTimes, time.Now())
	_, err := conn.Do("PSETEX", prefix+":"+key, int(v.TTL.Seconds()*1000), buf)
	return err
}

// Get retrieves an item from redis.
func (v Volatile) Get(ctx context.Context, prefix, key string) ([]byte, error) {
	conn := v.Pool.Get()
	defer conn.Close()

	defer measure(v.GetTimes, time.Now())
	return redis.Bytes(conn.Do("GET", prefix+":"+key))
}

// Delete removes an item from redis.
func (v Volatile) Delete(ctx context.Context, prefix, key string) (bool, error) {
	conn := v.Pool.Get()
	defer conn.Close()

	defer measure(v.DeleteTimes, time.Now())
	val, err := redis.Bool(conn.Do("DEL", prefix, key))
	return !val, err
}

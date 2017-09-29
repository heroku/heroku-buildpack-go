package cache

import (
	"context"
	"time"

	"github.com/garyburd/redigo/redis"
)

// NewPool creates a new redis pool with default "sane" settings.
func NewPool(uri string) (*redis.Pool, error) {
	return &redis.Pool{
		MaxIdle:     3,
		IdleTimeout: 4 * time.Minute,
		Dial:        func() (redis.Conn, error) { return redis.DialURL(uri) },
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			if time.Since(t) < time.Minute {
				return nil
			}
			_, err := c.Do("PING")
			return err
		},
	}, nil
}

// Redis is a Cache implementation backed by redis using a given key prefix, Storage
// mechanism, and a pair of Encoder/Decoder to convert redis values into boxed Go types.
type Redis struct {
	Prefix  string
	Storage Storage
	Encoder Encoder
	Decoder Decoder
}

// Put adds a given key->value pair to the Cache.
func (r Redis) Put(ctx context.Context, key string, value interface{}) error {
	buf, err := r.Encoder(value)
	if err != nil {
		return err
	}
	return r.Storage.Put(ctx, r.Prefix, key, buf)
}

// Get retrieves a given key->value pair from the Cache.
func (r Redis) Get(ctx context.Context, key string) (interface{}, bool) {
	v, err := r.Storage.Get(ctx, r.Prefix, key)
	if err != nil {
		return nil, false
	}

	buf, err := r.Decoder(v)
	return buf, err == nil
}

// Delete removes a given key->value pair from the Cache.
func (r Redis) Delete(ctx context.Context, key string) (bool, error) {
	ok, err := r.Storage.Delete(ctx, r.Prefix, key)
	return err == nil && ok, err
}

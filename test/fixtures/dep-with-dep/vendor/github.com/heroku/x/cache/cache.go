// Package cache is a generic cache mechanism.
//
// This is intended to store recently retrieved data from a datastore that
// cannot handle being queried directly for each request.
package cache

import "context"

// Getter interface allows get semantics.
type Getter interface {
	Get(ctx context.Context, key string) (value interface{}, ok bool)
}

// Putter interface allows put semantics.
type Putter interface {
	Put(ctx context.Context, key string, value interface{}) error
}

// Deleter interface allows deletion semantics.
type Deleter interface {
	Delete(ctx context.Context, key string) (existed bool, err error)
}

// PutDeleter interface combines Putter and Deleter, allowing for only modify
// semantics
type PutDeleter interface {
	Putter
	Deleter
}

// Cache interface combines Putter, Deleter and Getter allowing for full cache
// semantics.
type Cache interface {
	Getter
	Putter
	Deleter
}

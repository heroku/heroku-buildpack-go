package cache

import (
	"container/list"
	"context"
	"errors"
	"sync"

	"github.com/apg/ln"
)

type lruEntry struct {
	key   string
	value interface{}
}

type lruCache struct {
	sync.RWMutex

	length   int
	capacity int
	list     *list.List
	table    map[string]*list.Element
}

// NewLRU creates a new Cache which evicts the oldest entry when capacity is filled
func NewLRU(capacity int) (Cache, error) {
	if capacity < 1 {
		return nil, errors.New("capacity can't be less than 1")
	}

	return &lruCache{
		capacity: capacity,
		list:     list.New(),
		table:    make(map[string]*list.Element),
	}, nil
}

func (c *lruCache) Put(ctx context.Context, key string, value interface{}) error {
	c.Lock()
	defer c.Unlock()

	// is it in the cache already?
	e, ok := c.table[key]
	if ok { // Update it, and move it up front.
		v, ok := e.Value.(*lruEntry)
		if !ok {
			err := errors.New("type assertion failed")
			ln.Error(ctx, ln.F{
				"err": err,
				"key": key,
			})
			return err
		}
		v.value = value
		c.list.MoveToFront(e)
		return nil
	}

	// Make room if necessary
	for c.capacity > 0 && c.length >= c.capacity {
		c.evict()
	}

	// Insert into the cache
	v := &lruEntry{key, value}
	e = c.list.PushFront(v)
	c.table[key] = e
	c.length++
	return nil
}

// Get retrieves a value from the cache and refreshes it's TTL
func (c *lruCache) Get(ctx context.Context, key string) (value interface{}, ok bool) {
	c.RLock()
	defer c.RUnlock()

	e, ok := c.table[key]
	if !ok {
		return nil, false
	}
	c.list.MoveToFront(e)
	return e.Value.(*lruEntry).value, true
}

// Delete removes the value associated with key from the cache.
func (c *lruCache) Delete(ctx context.Context, key string) (bool, error) {
	c.Lock()
	defer c.Unlock()

	e, ok := c.table[key]
	if !ok {
		return false, nil
	}

	delete(c.table, key)
	c.list.Remove(e)
	c.length--
	return true, nil
}

// evict removes the least recently used item from the cache
func (c *lruCache) evict() {
	e := c.list.Back()
	if e == nil {
		return
	}

	v := c.list.Remove(e).(*lruEntry)
	delete(c.table, v.key)
	c.length--
}

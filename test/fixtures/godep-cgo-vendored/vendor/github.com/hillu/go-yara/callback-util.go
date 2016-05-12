package yara

import (
	"strconv"
	"sync"
)

/*
The closure type stores (pointers to) arbitrary data, returning a
simple int. A pointer to this int may be passed through C code to
callback functions written in Go that can use it to access the data
without violating the rules for passing pointers through C code.

Concurrent access to the stored data is protected through a
sync.RWMutex.
*/
type closure struct {
	m map[int]interface{}
	sync.RWMutex
}

func (c *closure) Put(elem interface{}) *int {
	c.Lock()
	if c.m == nil {
		c.m = make(map[int]interface{})
	}
	defer c.Unlock()
	for i := 0; ; i++ {
		_, ok := c.m[i]
		if !ok {
			c.m[i] = elem
			return &i
		}
	}
}

func (c *closure) Get(id *int) interface{} {
	c.RLock()
	defer c.RUnlock()
	if r, ok := c.m[*id]; ok {
		return r
	}
	panic("get: element " + strconv.Itoa(*id) + " not found")
}

func (c *closure) Delete(id *int) {
	c.Lock()
	defer c.Unlock()
	if _, ok := c.m[*id]; !ok {
		panic("delete: element " + strconv.Itoa(*id) + " not found")
	}
	delete(c.m, *id)
}

var callbackData closure

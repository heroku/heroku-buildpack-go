// Copyright © 2015 Hilko Bengen <bengen@hilluzination.de>. All rights reserved.
// Use of this source code is governed by the license that can be
// found in the LICENSE file.

package yara

import (
	"io"
	"unsafe"
)

// #include <string.h>
import "C"

//export streamRead
func streamRead(ptr unsafe.Pointer, size, nmemb C.size_t, userData unsafe.Pointer) C.size_t {
	if size == 0 || nmemb == 0 {
		return nmemb
	}
	reader := callbackData.Get((*int)(userData)).(io.Reader)
	dst := uintptr(ptr)
	buf := make([]byte, size)
	for i := 0; i < int(nmemb); i++ {
		var sz int
		for offset := 0; offset < int(size); offset += sz {
			var err error
			if sz, err = reader.Read(buf[offset:]); err != nil {
				return C.size_t(i)
			}
		}
		C.memcpy(unsafe.Pointer(dst+uintptr(i)*uintptr(size)), unsafe.Pointer(&buf[0]), size)
	}
	return nmemb
}

//export streamWrite
func streamWrite(ptr unsafe.Pointer, size, nmemb C.size_t, userData unsafe.Pointer) C.size_t {
	if size == 0 || nmemb == 0 {
		return nmemb
	}
	writer := callbackData.Get((*int)(userData)).(io.Writer)
	src := uintptr(ptr)
	buf := make([]byte, size)
	for i := 0; i < int(nmemb); i++ {
		C.memcpy(unsafe.Pointer(&buf[0]), unsafe.Pointer(src+uintptr(i)*uintptr(size)), size)
		var sz int
		for offset := 0; offset < int(size); offset += sz {
			var err error
			if sz, err = writer.Write(buf[offset:]); err != nil {
				return C.size_t(i)
			}
		}
	}
	return nmemb
}

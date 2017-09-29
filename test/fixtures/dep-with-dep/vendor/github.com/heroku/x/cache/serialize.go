package cache

import "errors"

// Encoder serializes a go value to a byte slice.
type Encoder func(v interface{}) ([]byte, error)

// Decoder parses a go value from a byte slice.
type Decoder func([]byte) (interface{}, error)

// ErrNotString is returned when StringEncoder is fed an interface{} that is not
// underlying type string.
var ErrNotString = errors.New("StringEncoder: Unable to Encode non-string")

// StringEncoder encodes a string to a byte slice. This will fail if it is not
// passed a string.
func StringEncoder(v interface{}) ([]byte, error) {
	str, ok := v.(string)
	if !ok {
		return nil, ErrNotString
	}
	return []byte(str), nil
}

// StringDecoder converts a byte slice into a string.
func StringDecoder(buf []byte) (interface{}, error) {
	return string(buf), nil
}

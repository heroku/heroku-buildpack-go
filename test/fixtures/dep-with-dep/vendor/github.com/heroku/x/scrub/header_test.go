package scrub

import (
	"fmt"
	"net/http"
	"net/textproto"
	"testing"
)

func TestHeader(t *testing.T) {
	for name := range RestrictedHeaders {
		t.Run(name, func(tt *testing.T) {
			h := http.Header{
				textproto.CanonicalMIMEHeaderKey(name): []string{"test_string_please_ignore"},
			}

			sc := Header(h)

			if val := sc.Get(name); val != scrubbedValue {
				tt.Fatalf("%s: want: %q, got: %q", name, scrubbedValue, val)
			}
		})
	}
}

func TestHeaderAuthorization(t *testing.T) {
	kinds := []string{"Bearer", "Basic"}

	for _, k := range kinds {
		t.Run(k, func(tt *testing.T) {
			h := http.Header{
				"Authorization": []string{fmt.Sprintf("%s please_ignore", k)},
			}

			sc := Header(h)
			scrubAs := fmt.Sprintf("%s %s", k, scrubbedValue)

			if val := sc.Get("Authorization"); val != scrubAs {
				tt.Fatalf("%s: want: %q, got: %q", k, scrubAs, val)
			}
		})
	}
}

func TestHeaderShouldntScrub(t *testing.T) {
	const (
		headerName = "super-awesome-api-key"
		eValue     = "hunter2"
	)

	h := http.Header{}
	h.Add(headerName, eValue)

	sc := Header(h)
	if val := sc.Get(headerName); val != eValue {
		t.Fatalf("want: %q, got: %q", eValue, val)
	}
}

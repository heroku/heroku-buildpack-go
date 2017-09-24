package cache

import "testing"

func TestEncoderDecoder(t *testing.T) {
	cases := []struct {
		name        string
		encoder     func(interface{}) ([]byte, error)
		decoder     func([]byte) (interface{}, error)
		legaldata   interface{}
		illegaldata interface{}
	}{
		{
			name:        "String",
			encoder:     StringEncoder,
			decoder:     StringDecoder,
			legaldata:   "foo",
			illegaldata: struct{}{},
		},
	}

	for _, cs := range cases {
		t.Run(cs.name, func(tt *testing.T) {
			buf, err := cs.encoder(cs.legaldata)
			if err != nil {
				tt.Fatalf("encoding: %v", err)
			}

			_, err = cs.decoder(buf)
			if err != nil {
				tt.Fatalf("decoding: %v", err)
			}

			_, err = cs.encoder(cs.illegaldata)
			if err == nil {
				tt.Fatalf("encoding data that should be illegal: %v", err)
			}
		})
	}
}

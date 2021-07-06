package urlenc

import (
	"fmt"
	"net/url"
	"reflect"
	"strconv"
	"strings"
)

// decode urlencoded bytes into a struct v
func Unmarshal(data []byte, v interface{}) error {
	values, err := url.ParseQuery(string(data))
	if err != nil {
		return err
	}
	return UnmarshalForm(values, v)
}

// Fill a struct `v` from the values in `values`
func UnmarshalForm(values url.Values, v interface{}) error {
	// check v is valid
	rv := reflect.ValueOf(v).Elem()
	// dereference pointer
	if rv.Kind() == reflect.Ptr {
		rv = rv.Elem()
	}
	// get type
	rt := rv.Type()
	if rv.Kind() == reflect.Struct {
		// for each struct field on v
		for i := 0; i < rt.NumField(); i++ {
			// values field value
			t := rt.Field(i)
			fvs := values[t.Name]
			err := UnmarshalValues(fvs, t, rv.Field(i))
			if err != nil {
				return err
			}
		}
	} else {
		return fmt.Errorf("v must point to a struct")
	}
	return nil
}

func UnmarshalValues(fvs []string, t reflect.StructField, v reflect.Value) error {
	if len(fvs) == 0 {
		return nil
	}
	switch v.Kind() {
	case reflect.Slice:
		// add all values values to slice
		sv := reflect.MakeSlice(t.Type, len(fvs), len(fvs))
		for i, fv := range fvs {
			svv := sv.Index(i)
			err := UnmarshalValue(fv, svv)
			if err != nil {
				return err
			}
		}
		v.Set(sv)
	default:
		return UnmarshalValue(fvs[0], v)
	}
	return nil
}

func UnmarshalValue(fv string, v reflect.Value) error {
	switch v.Kind() {
	case reflect.Int64:
		// convert to Int64
		if i, err := strconv.ParseInt(fv, 10, 64); err == nil {
			v.SetInt(i)
		}
	case reflect.Int:
		// convert to Int
		// convert to Int64
		if i, err := strconv.ParseInt(fv, 10, 64); err == nil {
			v.SetInt(i)
		}
	case reflect.String:
		// copy string
		v.SetString(fv)
	case reflect.Bool:
		fv = strings.ToUpper(fv)
		if len(fv) > 0 && (fv[0] == 'Y' || fv[0] == 'T' || fv[0] == '1') {
			v.SetBool(true)
		}
	default:
		return fmt.Errorf("Cannot decode into struct field of type %v", v.Kind())
	}
	return nil
}

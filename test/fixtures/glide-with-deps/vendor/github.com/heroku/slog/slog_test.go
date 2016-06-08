package slog

import (
	"fmt"
	"regexp"
	"testing"
	"time"
)

// Slog
func ExampleContext_single() {
	fmt.Println(Context{"foo": "bar"})
	//Output:
	// foo=bar
}

func ExampleContext_single_num() {
	fmt.Println(Context{"foo": 1})
	//Output:
	// foo=1
}

func ExampleContext_multi() {
	fmt.Println(Context{"foo": "bar", "bar": "bazzle"})

	//Output:
	// bar=bazzle foo=bar
}

func ExampleContext_mixed() {
	fmt.Println(Context{"foo": "bar", "bar": "bazzle", "baz": 1, "bazzle": true})

	//Output:
	// bar=bazzle baz=1 bazzle foo=bar
}

func ExampleContext_withError() {
	fmt.Println(Context{"error": fmt.Errorf("fi fie fo fum")})

	//Output:
	// error="fi fie fo fum"
}

func ExampleContext_float64() {
	l := Context{"float64": float64(1.34)}
	fmt.Println(l)

	//Output:
	// float64=1.34
}

func ExampleContext_bool() {
	l := Context{"booltest": true}
	fmt.Println(l)
	//Output:
	// booltest
}

func ExampleContext_duration() {
	// No time
	l := Context{"elapsed": time.Duration(time.Nanosecond * 0)}
	fmt.Println(l)

	l["elapsed"] = time.Duration(time.Nanosecond)
	fmt.Println(l)

	l["elapsed"] = time.Duration(time.Microsecond)
	fmt.Println(l)

	l["elapsed"] = time.Duration(time.Millisecond)
	fmt.Println(l)

	l["elapsed"] = time.Duration(time.Second)
	fmt.Println(l)

	l["elapsed"] = time.Duration(time.Second + 200*time.Millisecond)
	fmt.Println(l)

	l["elapsed"] = time.Duration(300*time.Second + 200*time.Millisecond + 10*time.Millisecond)
	fmt.Println(l)

	//Output:
	// elapsed=0
	// elapsed=0.000000001
	// elapsed=0.000001
	// elapsed=0.001
	// elapsed=1.000
	// elapsed=1.200
	// elapsed=300.210
}

func ExampleContext_add() {
	l := Context{"start": true}
	fmt.Println(l)

	l["error"] = "BOOM"
	fmt.Println(l)

	//Output:
	// start
	// error=BOOM start
}

func ExampleContext_empty() {
	fmt.Println(Context{"empty": ""})

	//Output:
	// empty=""
}

func ExampleContext_time() {
	fmt.Println(Context{"now": time.Unix(0, 0).UTC()})

	//Output:
	// now="1970-01-01T00:00:00Z"
}

func ExampleContext_withEquals() {
	fmt.Println(Context{"test": "foo=bar"})

	//Output:
	// test="foo=bar"
}

func ExampleContext_withComma() {
	fmt.Println(Context{"test": "1,2,3,4"})

	//Output:
	// test="1,2,3,4"
}

func ExampleContext_withSpace() {
	fmt.Println(Context{"test": "1 2 3 4"})

	//Output:
	// test="1 2 3 4"
}

func ExampleContext_withNewline() {
	fmt.Println(Context{"test": "12\n34"})

	//Output:
	// test="12\n34"
}

func ExampleContext_withQuotes() {
	fmt.Println(Context{"test": "\"123\""})
	fmt.Println(Context{"test": `"123`})
	fmt.Println(Context{"test": `'1 23`})

	//Output:
	// test="\"123\""
	// test="\"123"
	// test="'1 23"
}

func ExampleContext_replace() {
	l := Context{"start": "here"}
	fmt.Println(l)

	l["start"] = "there"
	fmt.Println(l)

	//Output:
	// start=here
	// start=there
}

func ExampleContext_l2met() {
	l := Context{"measure#foo.bar": 12}
	fmt.Println(l)

	//Output: measure#foo.bar=12
}

func ExampleContext_l2metMulti() {
	l := Context{"measure#foo.bar": 12}
	l["count#bam.boo"] = 6

	fmt.Println(l)

	//Output: count#bam.boo=6 measure#foo.bar=12
}

func ExampleContext_count() {
	l := Context{}
	l.Count("foo", 1)
	fmt.Println(l)

	l.Count("foo", 1)
	fmt.Println(l)

	//Output:
	// count#foo=1
	// count#foo=2
}

func ExampleContext_measure() {
	l := Context{}
	l.Measure("foo", 1)
	fmt.Println(l)

	l.Measure("foo", 3)
	fmt.Println(l)

	l.Measure("bar", 1.256)
	fmt.Println(l)

	//Output:
	// measure#foo=1
	// measure#foo=3
	// measure#bar=1.256 measure#foo=3
}

func ExampleContext_sample() {
	l := Context{}
	l.Sample("foo", 12)
	fmt.Println(l)

	l.Sample("foo", 1)
	fmt.Println(l)

	//Output:
	// sample#foo=12
	// sample#foo=1
}

func ExampleContext_unique() {
	l := Context{}
	l.Unique("foo", 12)
	fmt.Println(l)

	l.Unique("foo", 1)
	fmt.Println(l)

	//Output:
	// unique#foo=12
	// unique#foo=1
}

func TestMeasureSince(t *testing.T) {
	testKey := "example.duration"
	ctx := Context{}
	when := time.Now()
	ctx.MeasureSince(testKey, when)

	expectedKey := "measure#" + testKey
	duration, found := ctx["measure#example.duration"]
	if !found {
		t.Errorf("Expected key (%s) not found\n", expectedKey)
	}

	_, isDuration := duration.(time.Duration)
	if !isDuration {
		t.Errorf("Expected a time.Duration, but value wasn't")
	}

	resultPattern := regexp.MustCompile(fmt.Sprintf("%s=\\d+\\.\\d+", expectedKey))
	result := fmt.Sprint(ctx)
	if !resultPattern.MatchString(result) {
		t.Errorf("Expected pattern not found in output: %s", result)
	}
}

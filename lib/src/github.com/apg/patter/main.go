// Program patter rewrites the output of `go test -v` as TAP.
//
// See the README for more information.
//
// Released under the Modified BSD license. See LICENSE for more information.
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

type result struct {
	wasTest bool
	ok      bool
	num     int
	skip    bool
	extra   string
}

func writeHeader(w io.Writer) {
	w.Write([]byte("TAP version 13\n"))
}

func writePlan(w io.Writer, tests int) {
	if tests > 0 {
		fmt.Fprintf(w, "1..%d\n", tests)
	} else {
		w.Write([]byte("1..0 # skip because no tests were run."))
	}
}

func (r result) Write(wr io.Writer) (n int, err error) {
	var m int

	w := bufio.NewWriter(wr)
	defer w.Flush()

	if !r.wasTest { // just output, which we'll prefix with #
		if len(r.extra) > 0 {
			m, err = w.WriteString("# " + r.extra + "\n")
			if err != nil {
				return
			}
			n = n + m
		}
		return
	}

	// result of an actual test
	if r.ok {
		m, err = w.WriteString("ok ")
		if err != nil {
			return
		}
		n = n + m
	} else {
		m, err = w.WriteString("not ok ")
		if err != nil {
			return
		}
		n = n + m
	}

	// test number
	m, err = w.WriteString(strconv.Itoa(r.num))
	if err != nil {
		return
	}
	n = n + m

	prefix := " - "
	// description
	if r.skip {
		prefix = " # skip "
	}

	m, err = w.WriteString(prefix)
	if err != nil {
		return
	}
	n = n + m

	m, err = w.WriteString(r.extra + "\n")
	return n + m, err
}

func parseLine(b string) (r result, ok bool) {
	if strings.HasPrefix(b, "=== ") { // we simply ignore this junk
		return r, false
	}

	// --- signifies an actual result.
	if strings.HasPrefix(b, "--- ") {
		r.extra = b[10:]

		switch b[4:9] {
		case "PASS:":
			r.wasTest = true
			r.ok = true
		case "FAIL:":
			r.wasTest = true
		case "SKIP:":
			r.wasTest = true
			r.ok = true
			r.skip = true
		default:
		}
	} else if strings.HasPrefix(b, " ") || strings.HasPrefix(b, "\t") {
		r.wasTest = false
		r.extra = strings.TrimSpace(b)
	}
	return r, true
}

func main() {
	var tests int
	writeHeader(os.Stdout)
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		result, ok := parseLine(scanner.Text())
		if ok {
			if result.wasTest {
				tests++
			}
			result.num = tests
			result.Write(os.Stdout)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "\nBail out! %s: fatal: while reading standard input: %s", os.Args[0], err)
		os.Exit(1)
	}

	writePlan(os.Stdout, tests)
}

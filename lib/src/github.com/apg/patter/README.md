# patter

Output's `go test -v` as TAP.

## Usage

```
usage: patter
```

Patter has no arguments. It reads from STDIN, the output of `go test
-v`, and
outputs
[TAP v13](http://testanything.org/tap-version-13-specification.html)
compatible output.

## Example

Suppose the current directory has a test file, `foo_test.go`. Running
`go test -v -p 5 ./...` might produce the following output:

```bash
$ go test -v -p 5 ./...
=== RUN   TestSkip
--- SKIP: TestSkip (0.00s)
	foo_test.go:6: this test is being skipped
=== RUN   TestError
--- FAIL: TestError (0.00s)
	foo_test.go:10: this test is erroring
=== RUN   Test2Error
--- FAIL: Test2Error (0.00s)
	foo_test.go:14: this test is error 1
	foo_test.go:15: this test is error 2
=== RUN   TestFatal
--- FAIL: TestFatal (0.00s)
	foo_test.go:19: this test is fataling
=== RUN   TestOK
--- PASS: TestOK (0.00s)
=== RUN   TestParallel
=== RUN   TestParallel/X=100000
=== RUN   TestParallel/X=200000
=== RUN   TestParallel/X=300000
=== RUN   TestParallel/X=400000
=== RUN   TestParallel/X=500000
--- FAIL: TestParallel (0.00s)
    --- FAIL: TestParallel/X=600000 (0.00s)
    	foo_test.go:67: ouch!
    --- PASS: TestParallel/X=100000 (0.03s)
    --- PASS: TestParallel/X=200000 (0.06s)
    --- PASS: TestParallel/X=300000 (0.10s)
    --- PASS: TestParallel/X=400000 (0.13s)
    --- PASS: TestParallel/X=500000 (0.18s)
FAIL
exit status 1
FAIL	github.com/apg/patter/example	0.185s
```

If we, instead, pipe the output of `go test -v -p 5 ./...` into
`patter`, we get the following output:

```
TAP version 13
ok 1 # skip TestSkip (0.00s)
# foo_test.go:6: this test is being skipped
not ok 2 - TestError (0.00s)
# foo_test.go:10: this test is erroring
not ok 3 - Test2Error (0.00s)
# foo_test.go:14: this test is error 1
# foo_test.go:15: this test is error 2
not ok 4 - TestFatal (0.00s)
# foo_test.go:19: this test is fataling
ok 5 - TestOK (0.00s)
not ok 6 - TestParallel (0.00s)
# --- FAIL: TestParallel/X=600000 (0.00s)
# foo_test.go:67: ouch!
# --- PASS: TestParallel/X=100000 (0.03s)
# --- PASS: TestParallel/X=200000 (0.06s)
# --- PASS: TestParallel/X=400000 (0.11s)
# --- PASS: TestParallel/X=300000 (0.13s)
# --- PASS: TestParallel/X=500000 (0.18s)
1..6
```

Because `patter` doesn't know how many tests will be run, it outputs
the plan line (e.g. 1..5) at the end. This is allowed via the spec.

### A note on testing.Run, and Parallel subtests.

`patter` handles the testing package's subtests, by counting the
parent, and outputting the children as diagnostic output. This makes
the code a lot less complicated and doesn't double count. PRs very
welcome if you require, per sub-test, reporting.

### Bailing out!

It's possible that `patter` will encounter I/O errors while reading
from STDIN. If this happens, patter *bails out* using the special 
words `Bail out!` followed by an error message. This is the expected
emergency behaviour of TAP.

## Contributing

Contributions are welcome, and encouraged! Please open an issue before
a Pull Request to avoid duplicated effort, and/or functionality that
will not be merged.

## Copyright

(c) 2016, Andrew Gwozdziewycz <web@apgwoz.com>

See LICENSE file for more information.


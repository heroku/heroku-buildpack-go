# Go Buildpack Changelog

## Unreleased

## v31 (2016-02-17)

go1.6 released, 1.4.3 deprecated

## v30 (2016-02-04)

Bump to go1.6rc2

## v29 (2016-02-04)

Update support link

## v28 (2016-02-04)

Support for GB, A project based build tool for the Go programming language.
Fix the download of older go versions (< go1.3) now that googlecode is dead.
Only make/use env_dir if it's passed
Remove support for .godir and `Godeps` file (used by *way* old, unsupported versions of godep)

## v27 (2016-01-28)

Fix incorrect reporting of go1.6rc1 as deprecated

## v26 (2016-01-27)

add a LICENSE file
Bump default go1.6 version to go1.6rc1

## v25 (2016-01-13)

Default to `go1.5.3` when `go1.5` is specified.

## v24 (2016-01-07)

Better support for go1.6: Support GO15VENDOREXPERIMENT=0, go.1.6 uses newer -X $GO_LINKER_SYMBOL=$GO_LINKER_VALUE ldflag, like 1.5  

## v23 (2015-12-17)

Deprecate .godir, Godeps file (not Godeps/Godeps.json) and older Go versions.
Specifying a major version of go (e.g. go1.5) in Godeps/Godeps.json will cause the buildpack to select the current minor rev of Go (for bugfix goodness).
Support go1.6 via go1.6beta1

## V22 (2015-12-03)

Default back to `./...` when not using Godeps/Godeps.json at all (.godir & old Godeps file).

## V21 (2015-12-03)

Always detect packages from Godeps.json file. Previously this was only done for projects using GO15VENDOREXPERIMENT.

## V20 (2015-11-10)

Default to Package "." when using GO15VENDOREXPERIMENT

## V19 (2015-10-06)

Use new linker -X option format for go1.5

## V18 (2015-08-26)

Fix a typo (wanr -> warn)

## V17 (2015-08-26)

Support GO15VENDOREXPERIMENT flag (experimentally) & jq updated from 1.3 to 1.5

## V16 (2015-08-19)

Default to Go 1.5 if no version is specified

## V15 (2015-08-06)

Update godeps (bug fixes and version command)

## V14 (2015-07-10)

Basic validation of Godeps/Godeps.json file.

* https://github.com/heroku/heroku-buildpack-go/commit/c01751fdfcd5476421a6229ac4168a9c76823d4b

## v13 (2015-06-30)

Set GOMAXPROCS based on dyno size.

## v12 (2015-06-29)

GOPATH naming changed & update godep

* https://github.com/heroku/heroku-buildpack-go/pull/82

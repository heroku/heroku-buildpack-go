# Go Buildpack Changelog

## Unreleased

#v46

go1.7 released, drop support for go1.5.X

#v45

go1.7rc5 is the default for go1.7
GOVERSION & GO_INSTALL_PACKAGE_SPEC take priority over config files for godep/govendor. This is to help people deploying the same repo to multiple apps, allowing them to compile only specific packages and choose different go versions.

#v44

go1.7rc3 is the default for go1.7

#v43 (2016-07-19)

go1.7rc1 is the default for go1.7
Use go1.7rc2 and go1.6.3

## v42 (2016-07-07)

Official README image
glide support
go1.7beta2 is the default for go1.7
Release notes for internal people
Remove the need for Procfiles in simple situations

## v41 (2016-06-01)

GB: .go files only in src/ aren't valid and we shouldn't detect them as such. So -mindepth 2 added to GB detection
Make detection and compile ordering the same
Normalize names and location of functions
Support go1.7beta1
Add Travis CI image to README

## v40 (2016-05-18)

Bump govendor to 1.0.3

## v39 (2016-05-17)

Support govendor sync.

## v38 (2016-05-13)

Add '${build_dir}' substitution to build time environment variables. This is mainly useful for CGO support of vendored libs/includes
No longer set GOMAXPROCS defaults for go1.5+

## v37 (2016-05-09)

Bump GB to 0.4.1, remove beta warning

## v36 (2016-05-06)

Fix a bug in vendor path massaging

## v35 (2016-05-05)

Re-did the tests to use the same docker based testing that the nodejs buildpack uses. Added tests for most bits of the buildpack. This resulted
in a few minor changes in bin/compile. These are:
    1. warn goes to stdout, not stderr
    1. a new function 'err' writes to stderr (in red)
    1. 'warn'ing that used to exit 1 after now 'err' instead
    1. UNSET VendorExperiment if a Godeps/_workspace/src directory exists
    1. installs now 2>&1
These are essentially all cleanups.
Add LICENSE files for jq and godep, which this buildpack bundles.

## v34 (2016-04-25)

massage the installable package spec to include the name + vendor directory when vendor is used: https://github.com/heroku/heroku-buildpack-go/pull/120

## v33 (2016-04-21)

Support the downloading and compilation of development versions of go
go1.6.2 released, set as default for go1.6

## v32 (2016-04-13)

Initial support for govendor
retry curls up to 15 times with a 2 second wait between retries
go1.6.1 released, set as default for go1.6
go1.5.4 released, set as default for go1.5

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

# Go Buildpack Changelog

## Unreleased

## v89 (2018-06-12)
* GOCACHE support

## v88 (2018-06-12)

* Add go1.10.3 and go1.9.7
* Default to go1.10.3
* go1.10 expands to go1.10.3 and go1.9 expands to go1.9.7

## v87 (2018-05-03)

* Add go1.10.2 and go1.9.6
* Default to go1.10.2
* go1.10 expands to go1.10.2 and go1.9 expands to go1.9.6

## v86 (2018-04-17)

* Add go1.10.1 and go1.9.5
* Default to go1.10.1
* go1.10 expands to go1.10.1 and go1.9 expands to go1.9.5
* Deprecate go1.8*

## v85 (2018-02-23)

* Check to see if the buildpack knows about a file before trying to download it. Fixes #227.
* Fixed GO_LINKER_SYMBOL handling for go1.10+ (Thanks @djui)

## v84 (2018-02-16)

* Better naked version expansion that allows not only for 1.9 -> go1.9.4, but also 1.9.4 -> go1.9.4, which was missing previously.
* Add support for go1.10 (which will expand to the current go1.10.X version) and go1.10.0 (which pins to go1.10).
* Add `make sync` target and update README around syncing.

## v83 (2018-02-08)

* Add go1.10rc2 and default go1.10 to it.
* Add `1.X` versions expansions. Previously the full version string needed to start with `go`. Example: `go1.9` was required instead of `1.9`. Now both expand to the current go 1.9 version (currently `go1.9.4`).

## v82 (2018-02-07)

* Add go1.9.4 & 1.8.7 and default go1.9/go1.8 to them.

## v81 (2018-01-26)

* Bump dep to v0.4.0
* Bump dep to v0.4.1
* Add go1.10rc1 and default it as the version for go1.10

## v80 (2018-01-24)

* Add go1.9.3 and make it the default

## v79 (2018-01-17)

* Add go1.10beta1 and go1.10beta2

## v78 (2017-10-26)

* Add go1.9.2 and go1.8.5 and default go1.9/go1.8 to them.

## v77 (2017-10-17)

* Add support for Git credentials specified via config vars. See [here](https://github.com/heroku/heroku-buildpack-go#private-git-repos) for more info. So far this has only been tested with Github and personal access tokens over https, but should work for other methods as well.
* Tests now use a local file:// URL for most dependencies. This enables offline mode for most tests and makes it easier to test local changes before syncing the production bucket.
* Tests now better us shunit2 setup/teardown, instead of not cleaning up after themselves.
* Run tests against both the older heroku/cedar:14 image and the new heroku/heroku:16-build image.
* Because of the three changes above, tests are now faster.
* Allow `go1.X.0` versions that expand to `go1.X`, effectively pinning the minor version to the first version in the X series.

## v76 (2017-10-06)

* Actually make go1.9.1 supported
* Actually make go1.8.4 supported

## v75 (2017-10-05)

* Preliminary [dep](https://github.com/golang/dep) support.
* Update tq to v0.5
* Add tq and dep to s3 to ease dep integration.
* Update go to [1.9.1 & 1.8.4](https://groups.google.com/forum/#!msg/golang-nuts/sHfMg4gZNps/a-HDgDDDAAAJ) & default to them.

## v74 (2017-09-14)

* Promote go1.9 to supported.

## v73 (2017-08-25)

* Add go1.9 and default go1.9 to it.

## v72 (2017-08-09)

* Add go1.9rc2 and default go1.9 to it.

## v71 (2017-07-25)

* Add go1.9rc1 and default go1.9 to it.

## v70 (2017-06-26)

* Add go1.9beta2 and default go1.9 to it.

## v69 (2017-06-15)

* Support "go1.9" as a possible version, mapping to "go1.9beta1".
* Support "go1.9beta1" as a possible version.

## v68 (2017-06-06)

* Add `$GLIDE_SKIP_INSTALL` for when glide users need to skip the `glide install` step.

## v67 (2017-05-25)

* Support go1.8.3 and default to it.

## v66 (2017-05-24)

* Support go 1.8.2 and go1.7.6. Default to both.

## v65 (2017-05-16)

* Support `heroku.additionalTools` for `github.com/mattes/migrate` for govendor.

## v64 (2017-04-10)

* Support go 1.8.1. Default to go1.8.1.

## v63 (2017-04-04)

* Add $GO_TEST_SKIP_BENCHMARK, that when set to anything skips the benchmark during test execution.

## v62 (2017-02-16)

* Go 1.8 final support
* Update gb to 0.4.4-pre (made up from master @ 137520c0f2217d8b7f934dc307865488ef31b551)

## v61 (2017-02-10)

* Ensure there is a `${build}/bin` after moving things around to setup `$GOPATH`

## v60 (2017-01-27)

* Default go1.7 to go1.7.5 (was actually missing from last release :-()

## v59 (2017-01-26)

* Bump go1.8 to go1.8rc3
* Default go1.7 to go1.7.5

## v58

* Bump go1.8 to go1.8rc2

## v57

* Ensure glide is in the PATH, even when using from the cache.

## v56

* go1.8 support (beta / rc atm).
* Start using our own s3 bucket instead of various internet locations.
* Verify SHAs of filesdownloaded.

## v54/v55

* Fix erroneous warning about go1.7.4 / go1.6.4 being deprecated

## v53

* Default to go1.7.4 for go1.7
* Default to go1.6.4 for go1.6

## v52

* Default to go1.7.3 for go1.7

## v51

* Add support for testpack (bin/test-compile & bin/test)

## v50

* Bump versions of GB (0.4.3), Glide (0.12.2) & govendor (1.0.8)

## v49

* govendor: set `.heroku.sync = false` to prevent a `govendor sync` from being run before go install.
* When `GO_INSTALL_TOOLS_IN_IMAGE=true` the go tool chain (and dep tool) will be installed in `$HOME/.heroku/go` (`$GOROOT=$HOME/.heroku/go`). $GOROOT/bin is added to the `$PATH`.
* When `GO_SETUP_GOPATH_IN_IMAGE=true` (except for GB) the provided code is setup in a proper $GOPATH (`$GOPATH=$HOME`) and user's code is placed in `$GOPATH/src/$PROJECT NAME`.

## v48

* Bump govendor to v1.0.6
* Bump to go1.7.1

## v47

* When using glide, install hg

## v46

* go1.7 released, drop support for go1.5.X

## v45

* go1.7rc5 is the default for go1.7
* `GOVERSION` & `GO_INSTALL_PACKAGE_SPEC` take priority over config files for godep/govendor. This is to help people deploying the same repo to multiple apps, allowing them to compile only specific packages and choose different go versions.

## v44

* go1.7rc3 is the default for go1.7

## v43 (2016-07-19)

* go1.7rc1 is the default for go1.7
* Use go1.7rc2 and go1.6.3

## v42 (2016-07-07)

* Official README image
* glide support
* go1.7beta2 is the default for go1.7
* Release notes for internal people
* Remove the need for Procfiles in simple situations

## v41 (2016-06-01)

* GB: .go files only in src/ aren't valid and we shouldn't detect them as such. So -mindepth 2 added to GB detection
* Make detection and compile ordering the same
* Normalize names and location of functions
* Support go1.7beta1
* Add Travis CI image to README

## v40 (2016-05-18)

* Bump govendor to 1.0.3

## v39 (2016-05-17)

* Support govendor sync.

## v38 (2016-05-13)

* Add '${build_dir}' substitution to build time environment variables. This is mainly useful for CGO support of vendored libs/includes
* No longer set `GOMAXPROCS` defaults for go1.5+

## v37 (2016-05-09)

* Bump GB to 0.4.1, remove beta warning

## v36 (2016-05-06)

* Fix a bug in vendor path massaging

## v35 (2016-05-05)

* Re-did the tests to use the same docker based testing that the nodejs buildpack uses. Added tests for most bits of the buildpack. This resulted in a few minor changes in bin/compile. These cleanups are:

    1. warn goes to stdout, not stderr
    1. a new function 'err' writes to stderr (in red)
    1. 'warn'ing that used to exit 1 after now 'err' instead
    1. UNSET VendorExperiment if a Godeps/_workspace/src directory exists
    1. installs now 2>&1

* Add LICENSE files for jq and godep, which this buildpack bundles.

## v34 (2016-04-25)

* Massage the installable package spec to include the name + vendor directory when [vendor is used](https://github.com/heroku/heroku-buildpack-go/pull/120)

## v33 (2016-04-21)

* Support the downloading and compilation of development versions of go go1.6.2 released, set as default for go1.6

## v32 (2016-04-13)

* Initial support for govendor
* Retry curls up to 15 times with a 2 second wait between retries
* go1.6.1 released, set as default for go1.6
* go1.5.4 released, set as default for go1.5

## v31 (2016-02-17)

* go1.6 released, 1.4.3 deprecated

## v30 (2016-02-04)

* Bump to go1.6rc2

## v29 (2016-02-04)

* Update support link

## v28 (2016-02-04)

* Support for GB, A project based build tool for the Go programming language.
* Fix the download of older go versions (< go1.3) now that googlecode is dead.
* Only make/use env_dir if it's passed
* Remove support for .godir and `Godeps` file (used by *way* old, unsupported versions of godep)

## v27 (2016-01-28)

* Fix incorrect reporting of go1.6rc1 as deprecated

## v26 (2016-01-27)

* Add a LICENSE file
* Bump default go1.6 version to go1.6rc1

## v25 (2016-01-13)

* Default to `go1.5.3` when `go1.5` is specified.

## v24 (2016-01-07)

* Better support for go1.6: Support `GO15VENDOREXPERIMENT=0`, go.1.6 uses newer `-X $GO_LINKER_SYMBOL=$GO_LINKER_VALUE` ldflag, like 1.5

## v23 (2015-12-17)

* Deprecate .godir, Godeps file (not Godeps/Godeps.json) and older Go versions.
* Specifying a major version of go (e.g. go1.5) in Godeps/Godeps.json will cause the buildpack to select the current minor rev of Go (for bugfix goodness).
* Support go1.6 via go1.6beta1

## V22 (2015-12-03)

* Default back to `./...` when not using Godeps/Godeps.json at all (.godir & old Godeps file).

## V21 (2015-12-03)

* Always detect packages from Godeps.json file. Previously this was only done for projects using `GO15VENDOREXPERIMENT`.

## V20 (2015-11-10)

* Default to Package "." when using `GO15VENDOREXPERIMENT`

## V19 (2015-10-06)

* Use new linker -X option format for go1.5

## V18 (2015-08-26)

* Fix a typo (wanr -> warn)

## V17 (2015-08-26)

* Support `GO15VENDOREXPERIMENT` flag (experimentally) & jq updated from 1.3 to 1.5

## V16 (2015-08-19)

* Default to Go 1.5 if no version is specified

## V15 (2015-08-06)

* Update godeps (bug fixes and version command)

## V14 (2015-07-10)

* [Basic validation of Godeps/Godeps.json file](https://github.com/heroku/heroku-buildpack-go/commit/c01751fdfcd5476421a6229ac4168a9c76823d4b)

## v13 (2015-06-30)

* Set `GOMAXPROCS` based on dyno size.

## v12 (2015-06-29)

* [GOPATH naming changed & update godep](https://github.com/heroku/heroku-buildpack-go/pull/82)

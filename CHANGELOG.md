# Changelog

## [Unreleased]

## [v209] - 2025-07-08

* Add go1.24.5
* Add go1.23.11
* go1.24 defaults to 1.24.5
* go1.23 defaults to 1.23.11
* Stop testing against the Heroku-20 stack.

## [v208] - 2025-06-17

* Add go1.24.4
* Add go1.23.10
* go1.24 defaults to 1.24.4
* go1.23 defaults to 1.23.10

## [v207] - 2025-05-14

* Add go1.24.3
* Add go1.23.9
* go1.24 defaults to 1.24.3
* go1.23 defaults to 1.23.9

## [v206] - 2025-04-02

* Add go1.24.2
* Add go1.23.8
* go1.24 defaults to 1.24.2
* go1.23 defaults to 1.23.8

## [v205] - 2025-03-04

* Add go1.24.1
* Add go1.23.7
* go1.24 defaults to 1.24.1
* go1.23 defaults to 1.23.7

## [v204] - 2025-02-12

* Add go1.24.0
* go1.24 defaults to 1.24.0

## [v203] - 2025-02-06

* Add go1.23.6
* Add go1.22.12
* go1.23 defaults to 1.23.6
* go1.22 defaults to 1.22.12

## [v202] - 2025-01-21

* Add go1.23.5
* Add go1.22.11
* go1.23 defaults to 1.23.5
* go1.22 defaults to 1.22.11

## [v201] - 2024-12-06

* Add go1.23.4
* Add go1.22.10
* go1.23 defaults to 1.23.4
* go1.22 defaults to 1.22.10

## [v200] - 2024-11-12

* go1.23 defaults to 1.23.3
* go1.22 defaults to 1.22.9

## [v199] - 2024-11-11

* Add go1.23.3
* Add go1.22.9

## [v198] - 2024-10-01

* Add go1.23.2
* Add go1.22.8
* go1.23 defaults to 1.23.2
* go1.22 defaults to 1.22.8

## [v197] - 2024-09-05

* Add go1.23.1
* Add go1.22.7
* go1.23 defaults to 1.23.1
* go1.22 defaults to 1.22.7

## [v196] - 2024-09-03

* Deprecate support for unmaintained dependency managers: `dep`, `gb`, `glide`, `godep` and `govendor`.
  Support for these dependency managers will be removed on March 1, 2025.
  Apps using these dependency managers should migrate to Go modules as soon as possible.
  Learn more about using Go modules on Heroku [here](https://devcenter.heroku.com/articles/go-modules).
* Add support for wwwauth[] git credential arguments

## [v195] - 2024-08-13

* Add go1.23.0
* go1.23 defaults to go1.23.0

## [v194] - 2024-08-07

* Add go1.22.6
* Add go1.21.13
* go1.22 defaults to go1.22.6
* go1.21 defaults to go1.21.13

## [v193] - 2024-07-15

* Source GOFLAGS from the environment
* Add go1.22.5
* Add go1.21.12
* go1.22 defaults to go1.22.5
* go1.21 defaults to go1.21.12

## [v192] - 2024-06-04

* Add go1.22.4
* Add go1.21.11
* go1.22 defaults to go1.22.4
* go1.21 defaults to go1.21.11

## [v191] - 2024-05-07

* Add go1.22.3
* Add go1.21.10
* go1.22 defaults to go1.22.3
* go1.21 defaults to go1.21.10
* Add support for heroku-24
* Drop support for installing bzr-hosted dependencies directly; bzr-hosted

## [v190] - 2024-04-05

* Add go1.22.2
* Add go1.21.9
* go1.22 defaults to go1.22.2
* go1.21 defaults to go1.21.9

## [v189] - 2024-03-06

* Add go1.22.1
* Add go1.21.8
* go1.22 defaults to go1.22.1
* go1.21 defaults to go1.21.8

## [v188] - 2024-02-28

* Defaults to go1.20.14 when Go version is not specified
* Defaults to go1.20.14 when bootstrapping Go development releases

## [v187] - 2024-02-08

* Add go1.21.7
* Add go1.20.14
* go1.21 defaults to go1.21.7
* go1.20 defaults to go1.20.14

## [v186] - 2024-02-08

* Add go1.22.0
* Use go1.22.0 for go1.22

## [v185] - 2024-02-06

* Add go1.22rc1, go1.22rc2

## [v184] - 2024-01-16

* Added `--show-error` flag to all curl commands
* Add go1.20.13
* Add go1.21.6
* go1.20 defaults to go1.20.13
* go1.21 defaults to go1.21.5

## [v183] - 2024-01-02

* Add go1.20.12
* Add go1.21.5
* go1.20 defaults to go1.20.12
* go1.21 defaults to go1.21.45

## [v182] - 2023-11-13

* Add go1.20.11
* Add go1.21.4
* go1.20 defaults to go1.20.11
* go1.21 defaults to go1.21.4

## [v181] - 2023-10-11

* Add go1.20.9
* Add go1.20.10
* Add go1.21.2
* Add go1.21.3
* go1.20 defaults to go1.20.10
* go1.21 defaults to go1.21.3

## [v180] - 2023-09-18

* Add go1.19.13
* Add go1.20.8
* go1.19 defaults to go1.19.13
* go1.20 defaults to go1.20.8

## [v179] - 2023-09-18

* Add go1.21.1
* go1.21 defaults to go1.21.1

## [v178] - 2023-08-14

* Add go1.21.0
* Use go1.21.0 for go1.21

## [v177] - 2023-08-07

* Add go1.20.7
* Add go1.19.12
* go1.20 defaults to go1.20.7
* go1.19 defaults to go1.19.12

## [v176] - 2023-08-01

* Add go1.20.6
* Add go1.19.11
* go1.20 defaults to go1.20.6
* go1.19 defaults to go1.19.11

## [v175] - 2023-06-26

* Add go1.20.5
* Add go1.19.10
* go1.20 defaults to go1.20.5
* go1.19 defaults to go1.19.10
* Drop support for the heroku-18 stack

## [v174] - 2023-05-09

* Add go1.20.4
* Add go1.19.9
* go1.20 defaults to go1.20.4
* go1.19 defaults to go1.19.9

### [v173] - 2023-04-11

* Add go1.20.3
* Add go1.19.8
* go1.20 defaults to go1.20.3
* go1.19 defaults to go1.19.8

### [v172] - 2023-03-23

* Add go1.20.1 and go1.20.2
* Add go1.19.6 and go1.19.7
* go1.20 defaults to 1.20.2
* go1.19 defaults to 1.19.7

### [v171] - 2023-02-06

* Add go1.20, use for go1.20 and go1.20.0

### [v170] - 2023-01-23

* Add go1.19.4, go1.19.5
* Add go1.18.9, go1.18.10
* go1.19 defaults to go1.19.5
* go1.18 defaults to go1.18.10

## [v169] - 2022-11-09

* Add go1.19.2, and go1.19.3
* Add go1.18.4, go1.18.5, go1.18.7, and go1.18.8
* Add go1.17.11, go1.17.12, and go1.17.13
* go1.19 defaults to go1.19.3
* go1.18 defaults to go1.18.8
* go1.17 defaults to go1.17.13

## [v168] - 2022-09-08

* Add go1.19
* Add go1.19.1
* Add go1.18.6
* go1.18 defaults to 1.18.6
* go1.19 defaults to 1.19.1

## [v166] - 2022-06-15

* Re-release of the changes in v164.

## [v165] - 2022-06-14

* Temporary rollback of the v164 release.

## [v164] - 2022-06-14

* Adjust curl retry and connection timeout handling
* Switch to the recommended regional S3 domain instead of the global one

## [v163] - 2022-06-09, [v167] (published by mistake 2022-09-08)

* Use the go version in `go.mod` if no `+heroku` comment is found (#378/#411)
* Add go1.18.3
* go1.18 defaults to 1.18.3

## [v162] - 2022-03-23

* Add go1.17.9
* Add go1.17.10
* Add go1.18.1
* Add go1.18.2
* go1.17 defaults to 1.17.10
* go1.18 defaults to 1.18.2
* Add Heroku-22 to the Circle CI test matrix.

## [v161] - 2022-03-15

* Add go1.15.11
* Add go1.15.12
* Add go1.15.13
* Add go1.15.14
* Add go1.15.15
* Add go1.16.11
* Add go1.16.12
* Add go1.16.13
* Add go1.16.14
* Add go1.16.15
* Add go1.17.4
* Add go1.17.5
* Add go1.17.6
* Add go1.17.7
* Add go1.17.8
* Add go1.18
* go1.18 defaults to 1.18
* go1.17 defaults to 1.17.8
* go1.16 defaults to 1.16.15
* go1.15 defaults to 1.15.15

## [v160] - 2021-11-30

* Stop suppressing error output from `go list`
* Document how to install additional tools with go modules

## [v159] - 2021-11-30

* Republish v157 (with missing binaries)

## [v158] - 2021-11-30

* Rollback v157 to v156 (binaries were missing)

## [v157] - 2021-11-30

* Add go1.16.10, use for go1.16
* Add go1.17.3, use for go1.17

## [v156] - 2021-10-11

* Add go1.16.9, use for go1.16
* Add go1.17.2, use for go1.17

## [v155] - 2021-09-13

* Add go1.16.8, use for go1.16
* Add go1.17.1, use for go1.17

## [v154] - 2021-08-18

* Add go1.17
* Add go1.16.7, use for go1.16
* Add go 1.16.6
* Add go 1.16.5
* Add go 1.16.4
* Add go 1.16.3
* Add go 1.16.2
* Add go1.15.10, use for go 1.15
* Drop Heroku-16 from CI test matrix

## [v153] - 2021-03-11

* Add go1.16.1, use for go1.16
* Add go1.15.9, use for go1.15

## [v152] - 2021-02-17

* Drop cedar-14 from test matrix
* Remove skipping of tests on cedar-14
* Update Makefile's default IMAGE to heroku/heroku:20-build
* Install patter in a Go 1.16+ compatible way
* Add go1.16, use for go1.16 and go1.16.0
* Add go1.14.15, use for go1.14
* Add go1.15.8, use for go1.15

## [v151] - 2021-02-01

* Add go1.16rc1, use for go1.16

## [v150] - 2021-01-21

* Add go1.14.14, use for go1.14
* Add go1.15.7, use for go1.15

## v149 - 2020-12-07

* Add go1.14.11
* Add go1.15.4
* Add go1.14.12
* Add go1.15.5
* Add go1.14.13, use for go1.14
* Add go1.15.6, use for go1.15

## v148 - 2020-10-19

* Add go1.14.10, use for go1.14
* Add go1.15.3, use for go1.15

## v147 - 2020-09-15

* *GoModules* Private proxy support via `GOPROXY`, `GOPRIVATE`, and `GONOPROXY`
* Add go1.14.9, use for go1.14
* Add go1.15.2, use for go1.15

## v146 - 2020-09-08

* Update glide-with-hg-dep test fixture to use a new dependency, bitbucket.org/pkg/inflect is gone
* Add go1.14.8, use for go1.14
* Add go1.15.1, use for go1.15

## v145 - 2020-08-18

* Switch `heroku-buildpack-go`'s default branch from `master` to `main`.
* Add go1.13.15, use for go1.13
* Add go1.14.7, use for go1.14
* Add go1.15

## v144 - 2020-07-17

* Add go1.13.13
* Add go1.14.5
* Add go1.13.14, use for go1.13
* Add go1.14.6, use for go1.14

## v143 - 2020-06-08

* Add go1.13.11
* Add go1.14.3
* Add go1.13.12, use for go1.13
* Add go1.14.4, use for go1.14

## v142 - 2020-04-27

* Set GOPATH earlier when using modules, which fixes issues when using Heroku CI

## v141 - 2020-04-21

* Add Heroku-20 to the Travis test matrix
* Add go1.13.10, use for go1.13
* Add go1.14.2, use for go1.14

## v140 - 2020-04-16

* Only pass -mod=vendor to `go list` if a vendor directory is present (#394)

## v139 - 2020-03-23

* Update shunit2
* sbin/sync-files.sh: verify checksums serially
* Add go1.12.17, use for go1.12 and as the default
* Add go1.13.9, use for go1.13
* Add go1.14.1, use for go1.14

## v138 - 2020-03-13

* Add go1.13.8
* Add go1.14
* Expand go1.13 to go1.13.8
* Expand go1.14 to go1.14

## v137 - 2020-02-19

* Add go1.12.15 and go1.12.16
* Add go1.13.6 and go1.13.7
* Add go1.14rc1
* Default to go1.12.16
* Expand go1.13 to go1.13.7
* Expand go1.14 to go1.14rc1

## v136 - 2019-12-16

* Add go1.12.13
* Add go1.13.4
* Add go1.13.5, use for go1.13
* Add go1.12.14, expand go1.12 to go1.12.14, and default to go1.12.14
* Add go1.14beta1 expand go1.14 to go1.14beta1
* Remove duplicate deploy docs.

## v135 - 2019-12-03

* Same as 134, which looks like a misfire.

## v134 - 2019-10-22

* Add go1.13.3, use for go1.13
* Add go1.12.12, expand go1.12 to go1.12.12, and default to go1.12.12
* Add go1.13.2, use for go1.13
* Add go1.12.11, expand go1.12 to go1.12.11, and default to go1.12.11
* Remove hg and bzr installation as they are now part of the heroku-16 and heroku-18 build images.

## v131 - 2019-10-15) (and v132/v133

* Bump golangci-lint to v1.20.0

## v130 - 2019-09-26

* Add go1.13.1, use for go1.13
* Add go1.12.10, expand go1.12 to go1.12.10, and default to go1.12.10

## v129 - 2019-09-05

* Add go1.13rc2, use for go1.13
* Add go1.13, use for go1.13
* Bump Glide to 0.13.3

## v128 - 2019-08-27

* Download and install bzr when modules are in use.
* Add go1.12.9, expand go1.12 to go1.12.9, and default to go1.12.9
* Add go1.11.13, expand go1.11 to go1.11.13
* Add go1.13rc1, expand go1.13 to go1.13rc1

## v127 - 2019-08-15

* Add go1.12.8, expand go1.12 to go1.12.8, and default to go1.12.8

## v126 - 2019-07-10

* Set the public bit on files uploaded by ./sbin/sync-files.sh so that the files are publicly available.

## v125 - 2019-07-10

* Rollback to v119

## v124 - 2019-07-10

* Rollback attempt

## v123 - 2019-07-10

* Rollback attempt

## v122 - 2019-07-09

* Add go1.12.7, expand go1.12 to go1.12.7, and default to go1.12.7
* Add go1.11.12 and expand go1.11 to go 1.11.12

## v121 - 2019-07-09

* Botched release

## v120 - 2019-07-09

* Botched release

## v119 - 2019-06-27

* Add go1.13beta1 and make it the default when go1.13 is specified

## v118 - 2019-06-21

* Add -r to xargs so that xargs doesn't run commands when there is no input.

## v117 - 2019-06-17

* Add go1.12.6, expand go1.12 to go1.12.6, and default to go1.12.6
* Add go1.11.11 and expand go1.11 to go1.11.11

## v116 - 2019-05-14

* *Dep* Dep bumped to v0.5.2. Dep v0.5.1 & v0.5.0 also made available.

## v115 - 2019-05-09

* Cleanup how the stdlib is sourced.

## v114 - 2019-05-07

* *GoModules* Make read-only module files writable so they can be deleted during cache cleaning on Go version upgrade.

## v113 - 2019-05-07

* *GoModules* *TestPack* When .golangci.{yml,toml,json} exist run `golangci-lint -v --build-tags heroku run` during test. Use your .golangci.{yml,toml,json} to configure golangci-lint.
* Add go1.12.5, expand go1.12 to go1.12.5, and default to go1.12.5
* Add go1.11.10 and expand go1.11 to go1.11.10

## v112 - 2019-04-30

* *GoModules* When no Procfile exists and only a single main package exists, setup the resulting executable as the web process type.
* *GoModules* When no Procfile exists and multiple main packages exist, setup the resulting executables as process types of the same name.
* *GoModules* This means that a main package in a `web` directory will be setup as the web process type, a package in a `worker` directory will be setup as the worker process type, etc.

## v111 - 2019-04-18

* *GoModules* Set GOPATH to capture downloaded dependencies.

## v110 - 2019-04-15

* Add go1.12.4, expand go1.12 to go1.12.4, and default to go1.12.4
* Add go1.11.9 and expand go1.11 to go1.11.9
* Restore vendored mattes migrate teset on cedar:14 (finally fixed in ^)

## v109 - 2019-04-09

* Add go1.12.3, expand go1.12 to go1.12.3, and default to go1.12.3
* Add go1.11.8 and expand go1.11 to go1.11.8

## v108 - 2019-04-08

* *GoModules* Handle quoted module names in go.mod
* Add go1.12.2, expand go1.12 to go1.12.2, and default to go1.12.2
* Add go1.11.7 and expand go1.11 to go1.11.7
* *GoModules* Drop 'Go.SupportsModuleExperiment' from data.json, instead error for go versions < go1.11 when using modules.
* Drop 'Go.Supported' from data.json since the buildpack is no longer using it for anything.
* Skip vendored mattes migrate compile on cedar:14 due to gcc error.

## v107 - 2019-04-02

* Handle non files in bin/ (symlinks, directories, etc) when diffing to determine contents of bin/

## v106 - 2019-04-01

* *GoModules* Fixed flag handling, which has been broken since -mod=vendor was added (at least)
* *GoModules* Detect main packages in the repo and install them when there isn't a specified package spec.
* Only list the contents of bin/ that were installed/modified by the buildpack, instead of everything in bin/
* Small updates to the readme

## v105 - 2019-03-18

* Add go1.12.1 & go1.11.6
* Default to go1.12.1
* If ./cmd exists and no package spec is set, then set package spec to ./cmd/...

## v104 - 2019-03-11

* *GoModules* Fix up Go modules testing to include mod=vendor or mod=readonly and set GOPATH to a temporary directory so downloaded deps' tests aren't executed.
* Move publish script to /sbin/publish / don't push to master since it's disabled.
* Add Codeowners to automate PR reviews.

## v103 - 2019-03-07

* Removed warnings on command line
* Added info about compiled binaries

## v102 - 2019-03-01

* Add go1.12 and default to it when go1.12 is specified.
* Add go1.12 to the list of supported versions.
* Deprecate go1.10*

## v101 - 2019-02-21

* Track count of go versions being deployed

## v100 - 2019-02-12

* Add go1.10.8 and default to it when go1.10 is specified
* Add go1.11.5 and default to it when go1.11 is specified or no version is specified.
* *GoModules* Support go modules on Heroku CI (bin/test-compile & bin/test).
* Add pre/post compile run hooks: /bin/go-pre-compile & /bin/go-post-compile
* Add go1.12rc1 and default to it when go1.12 is specified.

## v99 - 2019-01-15

* Add go1.12beta1 and default to it when go1.12 is specified
* Add go1.12beta2 and default to it when go1.12 is specified

## v98 - 2018-12-18

* Fix git Credential Helper for go module use (missing brackets) - @chrisroberts
* Fix dep help text for package install - @andrewslotin
* Add go1.11.3 & go1.11.4 using go1.11.4 as the default for go1.11
* Add go1.10.6 & go1.10.7 using go1.10.7 as the default for go1.10

## v97 - 2018-11-05

* Re-apply v95

## v96 - 2018-11-05

* Rollback

## v95 - 2018-11-05

* Add go1.11.2, use it as the default for go1.11
* Add go1.10.5, use it as the default for go1.10

## v94 - 2018-10-19

* Remove the need for Procfiles in simple situations for go modules
* Add go1.11.1, use it as the default for go1.11
* Promote go1.11.1 as the default install
* Deprecate go1.9.X

## v93 - 2018-08-30

* Be clearer about what version of go is chosen if none is specified. Addresses #266.
* Handle version stuff in the right place for go modules.

## v92 - 2018-08-27

* Add go1.11 and mark it as supported
* Add go1.10.4 and make it the default, supported version

## v91 - 2018-08-24

* Add go1.11rc2 (unsupported) for experimenters
* Add basic support for go modules (unsupported) for experimenters
* Adds support for Golang Migrate (github.com/golang-migrate/migrate) as an additional tool
* Deprecates support for Mattes Migrate (is now Golang Migrate)

## v90 - 2018-08-16

* Add go1.11beta1 (unsupported) for experimenters
* Add go1.11beta2 (unsupported) for experimenters
* Add go1.11rc1 (unsupported) for experimenters

## v89 - 2018-06-12

* GOCACHE support

## v88 - 2018-06-12

* Add go1.10.3 and go1.9.7
* Default to go1.10.3
* go1.10 expands to go1.10.3 and go1.9 expands to go1.9.7

## v87 - 2018-05-03

* Add go1.10.2 and go1.9.6
* Default to go1.10.2
* go1.10 expands to go1.10.2 and go1.9 expands to go1.9.6

## v86 - 2018-04-17

* Add go1.10.1 and go1.9.5
* Default to go1.10.1
* go1.10 expands to go1.10.1 and go1.9 expands to go1.9.5
* Deprecate go1.8*

## v85 - 2018-02-23

* Check to see if the buildpack knows about a file before trying to download it. Fixes #227.
* Fixed GO_LINKER_SYMBOL handling for go1.10+ (Thanks @djui)

## v84 - 2018-02-16

* Better naked version expansion that allows not only for 1.9 -> go1.9.4, but also 1.9.4 -> go1.9.4, which was missing previously.
* Add support for go1.10 (which will expand to the current go1.10.X version) and go1.10.0 (which pins to go1.10).
* Add `make sync` target and update README around syncing.

## v83 - 2018-02-08

* Add go1.10rc2 and default go1.10 to it.
* Add `1.X` versions expansions. Previously the full version string needed to start with `go`. Example: `go1.9` was required instead of `1.9`. Now both expand to the current go 1.9 version (currently `go1.9.4`).

## v82 - 2018-02-07

* Add go1.9.4 & 1.8.7 and default go1.9/go1.8 to them.

## v81 - 2018-01-26

* Bump dep to v0.4.0
* Bump dep to v0.4.1
* Add go1.10rc1 and default it as the version for go1.10

## v80 - 2018-01-24

* Add go1.9.3 and make it the default

## v79 - 2018-01-17

* Add go1.10beta1 and go1.10beta2

## v78 - 2017-10-26

* Add go1.9.2 and go1.8.5 and default go1.9/go1.8 to them.

## v77 - 2017-10-17

* Add support for Git credentials specified via config vars. See [here](https://github.com/heroku/heroku-buildpack-go#private-git-repos) for more info. So far this has only been tested with Github and personal access tokens over https, but should work for other methods as well.
* Tests now use a local file:// URL for most dependencies. This enables offline mode for most tests and makes it easier to test local changes before syncing the production bucket.
* Tests now better us shunit2 setup/teardown, instead of not cleaning up after themselves.
* Run tests against both the older heroku/cedar:14 image and the new heroku/heroku:16-build image.
* Because of the three changes above, tests are now faster.
* Allow `go1.X.0` versions that expand to `go1.X`, effectively pinning the minor version to the first version in the X series.

## v76 - 2017-10-06

* Actually make go1.9.1 supported
* Actually make go1.8.4 supported

## v75 - 2017-10-05

* Preliminary [dep](https://github.com/golang/dep) support.
* Update tq to v0.5
* Add tq and dep to s3 to ease dep integration.
* Update go to [1.9.1 & 1.8.4](https://groups.google.com/forum/#!msg/golang-nuts/sHfMg4gZNps/a-HDgDDDAAAJ) & default to them.

## v74 - 2017-09-14

* Promote go1.9 to supported.

## v73 - 2017-08-25

* Add go1.9 and default go1.9 to it.

## v72 - 2017-08-09

* Add go1.9rc2 and default go1.9 to it.

## v71 - 2017-07-25

* Add go1.9rc1 and default go1.9 to it.

## v70 - 2017-06-26

* Add go1.9beta2 and default go1.9 to it.

## v69 - 2017-06-15

* Support "go1.9" as a possible version, mapping to "go1.9beta1".
* Support "go1.9beta1" as a possible version.

## v68 - 2017-06-06

* Add `$GLIDE_SKIP_INSTALL` for when glide users need to skip the `glide install` step.

## v67 - 2017-05-25

* Support go1.8.3 and default to it.

## v66 - 2017-05-24

* Support go 1.8.2 and go1.7.6. Default to both.

## v65 - 2017-05-16

* Support `heroku.additionalTools` for `github.com/mattes/migrate` for govendor.

## v64 - 2017-04-10

* Support go 1.8.1. Default to go1.8.1.

## v63 - 2017-04-04

* Add $GO_TEST_SKIP_BENCHMARK, that when set to anything skips the benchmark during test execution.

## v62 - 2017-02-16

* Go 1.8 final support
* Update gb to 0.4.4-pre (made up from master @ 137520c0f2217d8b7f934dc307865488ef31b551)

## v61 - 2017-02-10

* Ensure there is a `${build}/bin` after moving things around to setup `$GOPATH`

## v60 - 2017-01-27

* Default go1.7 to go1.7.5 (was actually missing from last release :-()

## v59 - 2017-01-26

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

## v43 - 2016-07-19

* go1.7rc1 is the default for go1.7
* Use go1.7rc2 and go1.6.3

## v42 - 2016-07-07

* Official README image
* glide support
* go1.7beta2 is the default for go1.7
* Release notes for internal people
* Remove the need for Procfiles in simple situations

## v41 - 2016-06-01

* GB: .go files only in src/ aren't valid and we shouldn't detect them as such. So -mindepth 2 added to GB detection
* Make detection and compile ordering the same
* Normalize names and location of functions
* Support go1.7beta1
* Add Travis CI image to README

## v40 - 2016-05-18

* Bump govendor to 1.0.3

## v39 - 2016-05-17

* Support govendor sync.

## v38 - 2016-05-13

* Add '${build_dir}' substitution to build time environment variables. This is mainly useful for CGO support of vendored libs/includes
* No longer set `GOMAXPROCS` defaults for go1.5+

## v37 - 2016-05-09

* Bump GB to 0.4.1, remove beta warning

## v36 - 2016-05-06

* Fix a bug in vendor path massaging

## v35 - 2016-05-05

* Re-did the tests to use the same docker based testing that the nodejs buildpack uses. Added tests for most bits of the buildpack. This resulted in a few minor changes in bin/compile. These cleanups are:

    1. warn goes to stdout, not stderr
    1. a new function 'err' writes to stderr (in red)
    1. 'warn'ing that used to exit 1 after now 'err' instead
    1. UNSET VendorExperiment if a Godeps/_workspace/src directory exists
    1. installs now 2>&1

* Add LICENSE files for jq and godep, which this buildpack bundles.

## v34 - 2016-04-25

* Massage the installable package spec to include the name + vendor directory when [vendor is used](https://github.com/heroku/heroku-buildpack-go/pull/120)

## v33 - 2016-04-21

* Support the downloading and compilation of development versions of go go1.6.2 released, set as default for go1.6

## v32 - 2016-04-13

* Initial support for govendor
* Retry curls up to 15 times with a 2 second wait between retries
* go1.6.1 released, set as default for go1.6
* go1.5.4 released, set as default for go1.5

## v31 - 2016-02-17

* go1.6 released, 1.4.3 deprecated

## v30 - 2016-02-04

* Bump to go1.6rc2

## v29 - 2016-02-04

* Update support link

## v28 - 2016-02-04

* Support for GB, A project based build tool for the Go programming language.
* Fix the download of older go versions (< go1.3) now that googlecode is dead.
* Only make/use env_dir if it's passed
* Remove support for .godir and `Godeps` file (used by *way* old, unsupported versions of godep)

## v27 - 2016-01-28

* Fix incorrect reporting of go1.6rc1 as deprecated

## v26 - 2016-01-27

* Add a LICENSE file
* Bump default go1.6 version to go1.6rc1

## v25 - 2016-01-13

* Default to `go1.5.3` when `go1.5` is specified.

## v24 - 2016-01-07

* Better support for go1.6: Support `GO15VENDOREXPERIMENT=0`, go.1.6 uses newer `-X $GO_LINKER_SYMBOL=$GO_LINKER_VALUE` ldflag, like 1.5

## v23 - 2015-12-17

* Deprecate .godir, Godeps file (not Godeps/Godeps.json) and older Go versions.
* Specifying a major version of go (e.g. go1.5) in Godeps/Godeps.json will cause the buildpack to select the current minor rev of Go (for bugfix goodness).
* Support go1.6 via go1.6beta1

## v22 - 2015-12-03

* Default back to `./...` when not using Godeps/Godeps.json at all (.godir & old Godeps file).

## v21 - 2015-12-03

* Always detect packages from Godeps.json file. Previously this was only done for projects using `GO15VENDOREXPERIMENT`.

## v20 - 2015-11-10

* Default to Package "." when using `GO15VENDOREXPERIMENT`

## v19 - 2015-10-06

* Use new linker -X option format for go1.5

## v18 - 2015-08-26

* Fix a typo (wanr -> warn)

## v17 - 2015-08-26

* Support `GO15VENDOREXPERIMENT` flag (experimentally) & jq updated from 1.3 to 1.5

## v16 - 2015-08-19

* Default to Go 1.5 if no version is specified

## v15 - 2015-08-06

* Update godeps (bug fixes and version command)

## v14 - 2015-07-10

* [Basic validation of Godeps/Godeps.json file](https://github.com/heroku/heroku-buildpack-go/commit/c01751fdfcd5476421a6229ac4168a9c76823d4b)

## v13 - 2015-06-30

* Set `GOMAXPROCS` based on dyno size.

## v12 - 2015-06-29

* [GOPATH naming changed & update godep](https://github.com/heroku/heroku-buildpack-go/pull/82)

[unreleased]: https://github.com/heroku/heroku-buildpack-go/compare/v209...main
[v209]: https://github.com/heroku/heroku-buildpack-go/compare/v208...v209
[v208]: https://github.com/heroku/heroku-buildpack-go/compare/v207...v208
[v207]: https://github.com/heroku/heroku-buildpack-go/compare/v206...v207
[v206]: https://github.com/heroku/heroku-buildpack-go/compare/v205...v206
[v205]: https://github.com/heroku/heroku-buildpack-go/compare/v204...v205
[v204]: https://github.com/heroku/heroku-buildpack-go/compare/v203...v204
[v203]: https://github.com/heroku/heroku-buildpack-go/compare/v202...v203
[v202]: https://github.com/heroku/heroku-buildpack-go/compare/v201...v202
[v201]: https://github.com/heroku/heroku-buildpack-go/compare/v200...v201
[v200]: https://github.com/heroku/heroku-buildpack-go/compare/v199...v200
[v199]: https://github.com/heroku/heroku-buildpack-go/compare/v198...v199
[v198]: https://github.com/heroku/heroku-buildpack-go/compare/v197...v198
[v196]: https://github.com/heroku/heroku-buildpack-go/compare/v195...v196
[v195]: https://github.com/heroku/heroku-buildpack-go/compare/v194...v195
[v194]: https://github.com/heroku/heroku-buildpack-go/compare/v193...v194
[v191]: https://github.com/heroku/heroku-buildpack-go/compare/v190...v191
[v190]: https://github.com/heroku/heroku-buildpack-go/compare/v189...v190
[v189]: https://github.com/heroku/heroku-buildpack-go/compare/v188...v189
[v188]: https://github.com/heroku/heroku-buildpack-go/compare/v187...v188
[v187]: https://github.com/heroku/heroku-buildpack-go/compare/v186...v187
[v186]: https://github.com/heroku/heroku-buildpack-go/compare/v185...v186
[v185]: https://github.com/heroku/heroku-buildpack-go/compare/v184...v185
[v184]: https://github.com/heroku/heroku-buildpack-go/compare/v183...v184
[v183]: https://github.com/heroku/heroku-buildpack-go/compare/v182...v183
[v182]: https://github.com/heroku/heroku-buildpack-go/compare/v181...v182
[v181]: https://github.com/heroku/heroku-buildpack-go/compare/v180...v181
[v180]: https://github.com/heroku/heroku-buildpack-go/compare/v179...v180
[v179]: https://github.com/heroku/heroku-buildpack-go/compare/v178...v179
[v178]: https://github.com/heroku/heroku-buildpack-go/compare/v177...v178
[v177]: https://github.com/heroku/heroku-buildpack-go/compare/v176...v177
[v176]: https://github.com/heroku/heroku-buildpack-go/compare/v175...v176
[v175]: https://github.com/heroku/heroku-buildpack-go/compare/v174...v175
[v174]: https://github.com/heroku/heroku-buildpack-go/compare/v173...v174
[v173]: https://github.com/heroku/heroku-buildpack-go/compare/v172...v173
[v172]: https://github.com/heroku/heroku-buildpack-go/compare/v171...v172
[v171]: https://github.com/heroku/heroku-buildpack-go/compare/v170...v171
[v170]: https://github.com/heroku/heroku-buildpack-go/compare/v169...v170
[v169]: https://github.com/heroku/heroku-buildpack-go/compare/v168...v169
[v168]: https://github.com/heroku/heroku-buildpack-go/compare/v167...v168
[v167]: https://github.com/heroku/heroku-buildpack-go/compare/v166...v167
[v166]: https://github.com/heroku/heroku-buildpack-go/compare/v165...v166
[v165]: https://github.com/heroku/heroku-buildpack-go/compare/v164...v165
[v164]: https://github.com/heroku/heroku-buildpack-go/compare/v163...v164
[v163]: https://github.com/heroku/heroku-buildpack-go/compare/v162...v163
[v162]: https://github.com/heroku/heroku-buildpack-go/compare/v161...v162
[v161]: https://github.com/heroku/heroku-buildpack-go/compare/v160...v161
[v160]: https://github.com/heroku/heroku-buildpack-go/compare/v159...v160
[v159]: https://github.com/heroku/heroku-buildpack-go/compare/v158...v159
[v158]: https://github.com/heroku/heroku-buildpack-go/compare/v157...v158
[v157]: https://github.com/heroku/heroku-buildpack-go/compare/v156...v157
[v156]: https://github.com/heroku/heroku-buildpack-go/compare/v155...v156
[v155]: https://github.com/heroku/heroku-buildpack-go/compare/v154...v155
[v154]: https://github.com/heroku/heroku-buildpack-go/compare/v153...v154
[v153]: https://github.com/heroku/heroku-buildpack-go/compare/v152...v153
[v152]: https://github.com/heroku/heroku-buildpack-go/compare/v151...v152
[v151]: https://github.com/heroku/heroku-buildpack-go/compare/v150...v151
[v150]: https://github.com/heroku/heroku-buildpack-go/compare/v149...v150

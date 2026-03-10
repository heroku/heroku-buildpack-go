# Heroku Buildpack for Go

[![CI](https://github.com/heroku/heroku-buildpack-go/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/heroku-buildpack-go/actions/workflows/ci.yml)

![Heroku Buildpack for Go](https://raw.githubusercontent.com/heroku/buildpacks/refs/heads/main/assets/images/buildpack-banner-go.png)

This is the official [Heroku buildpack][buildpack] for [Go][go].

## Getting Started

Follow the guide at
<https://devcenter.heroku.com/articles/getting-started-with-go>

There's also a hello world sample app at
<https://github.com/heroku/go-getting-started>

## Example

```console
$ ls -A1
.git
Procfile
go.mod
main.go

$ heroku create
Creating polar-waters-4785...
...

$ git push heroku main
...
-----> Go app detected
-----> Installing go1.25.7... done
-----> Running: go install -v -tags heroku .
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 1.6MB
-----> Launching... done, v4
       https://polar-waters-4785.herokuapp.com/ deployed to Heroku
```

This buildpack will detect your repository as Go if it contains a
[go.mod][gomodules] file.

This buildpack adds a `heroku` [build constraint][build-constraint], to enable
heroku-specific code. See the [App Engine build constraints
article][app-engine-build-constraints] for more info.

## Go Module Specifics

When using go modules, this buildpack will search the code base for `main`
packages, ignoring any in `vendor/`, and will automatically compile those
packages. If this isn't what you want you can specify specific package spec(s)
via the `go.mod` file's `// +heroku install` directive (see below).

The `go.mod` file allows for arbitrary comments. This buildpack utilizes [build
constraint](https://golang.org/pkg/go/build/#hdr-Build_Constraints) style
comments to track Heroku build specific configuration which is encoded in the
following way:

- `// +heroku goVersion <version>`: the major version of go you would like
  Heroku to use when compiling your code. If not specified this defaults to the
  buildpack's [DefaultVersion]. Specifying a version < go1.11 will cause a build
  error because modules are not supported by older versions of go.

  Example: `// +heroku goVersion go1.11`

- `// +heroku install <packagespec>[ <packagespec>]`: a space seperated list of
  the packages you want to install. If not specified, the buildpack defaults to
  detecting the `main` packages in the code base. Generally speaking this should
  be sufficient for most users. If this isn't what you want you can instruct the
  buildpack to only build certain packages via this option. Other common choices
  are: `./cmd/...` (all packages and sub packages in the `cmd` directory) and
  `./...` (all packages and sub packages of the current directory). The exact
  choice depends on the layout of your repository though.

  Example: `// +heroku install ./cmd/... ./special`

The Go version can also be overridden using the `$GOVERSION` environment
variable, which takes precedence over the `go.mod` directives. Setting
`$GOVERSION` to a major version will result in the buildpack using the latest
released minor version in that series. Since Go doesn't release `.0` versions,
specifying a `.0` version will pin your code to the initial release of the given
major version (ex `go1.24.0` == `go1.24` w/o auto updating to `go1.24.1` when
it becomes available).

```console
heroku config:set GOVERSION=go1.24   # Will use go1.24.X, where X is the latest minor release in the 1.24 series
heroku config:set GOVERSION=go1.23.4 # Pins to go1.23.4
```

If a top level `vendor` directory exists and the `go.sum` file has a size
greater than zero, `go install` is invoked with `-mod=vendor`, causing the build
to skip downloading and checking of dependencies. This results in only the
dependencies from the top level `vendor` directory being used.

### Pre/Post Compile Hooks

If the file `bin/go-pre-compile` or `bin/go-post-compile` exists and is
executable then it will be executed either before compilation (go-pre-compile)
of the repo, or after compilation (go-post-compile).

These hooks can be used to install additional tools, such as `github.com/golang-migrate/migrate`:

```bash
#!/bin/bash
set -e

go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.1
```

Because the buildpack installs compiled executables to `bin`, the
`go-post-compile` hook can be written in go if it's installed by the specified
`<packagespec>` (see above).

Example:

```console
$ cat go.mod
// +heroku install ./cmd/...
$ ls -F cmd
client/ go-post-compile/ server/
```

## Default Procfile

If there is no Procfile in the base directory of the code being built and the
buildpack can figure out the name of the base package (also known as the
module), then a default Procfile is created that includes a `web` process type
that runs the resulting executable from compiling the base package.

For example, if the package name was `github.com/heroku/example`, this buildpack
would create a Procfile that looks like this:

```sh
$ cat Procfile
web: example
```

This is useful when the base package is also the only main package to build.

If you have adopted the `cmd/<executable name>` structure this won't work and
you will need to create a [Procfile].

## Private Git Repos

The buildpack installs a custom git credential handler. Any tool that shells out to git (most do) should be able to transparently use this feature. Note: It has only been tested with Github repos over https using personal access tokens.

The custom git credential handler searches the application's config vars for vars that follow the following pattern: `GO_GIT_CRED__<PROTOCOL>__<HOSTNAME>`. Any periods (`.`) in the `HOSTNAME` must be replaces with double underscores (`__`).

The value of a matching var will be used as the username. If the value contains a ":", the value will be split on the ":" and the left side will be used as the username and the right side used as the password. When no password is present, `x-oauth-basic` is used.

The following example will cause git to use the `FakePersonalAccessTokenHere` as the username when authenticating to `github.com` via `https`:

```console
heroku config:set GO_GIT_CRED__HTTPS__GITHUB__COM=FakePersonalAccessTokenHere
```

## Hacking on this Buildpack

To change this buildpack, fork it on GitHub & push changes to your fork. Ensure
that tests have been added to `test/run.sh` and any corresponding fixtures to
`test/fixtures/<fixture name>`.

### Tests

[Make], [jq] & [docker] are required to run tests.

```console
make test
```

Run a specific test in `test/run.sh`:

```console
make test TEST=testModBasic
```

### Compiling a fixture locally

[Make] & [docker] are required to compile a fixture.

```console
make run
```

You can also specify a custom fixture (defaults to `test/fixtures/mod-basic-go126`) and stack (defaults to `heroku-24`):

```console
make run FIXTURE=test/fixtures/mod-basic-go125 STACK=heroku-22
```

This will run the buildpack's detect, compile, and release scripts against the specified fixture, simulating a complete buildpack execution.

Similarly, to test the buildpack's [testpack](#testpack) implementation:

```console
make run-ci [FIXTURE=<fixture>] [STACK=<stack>]
```

## Using with cgo

The buildpack supports building with C dependencies via [cgo][cgo]. You can set
config vars to specify CGO flags to specify paths for vendored dependencies. The
literal text of `${build_dir}` will be replaced with the directory the build is
happening in. For example, if you added C headers to an `includes/` directory,
add the following config to your app: `heroku config:set CGO_CFLAGS='-I${
build_dir}/includes'`. Note the usage of `''` to ensure they are not converted to
local environment variables.

## Using a development version of Go

The buildpack can install and use any specific commit of the Go compiler when
the specified go version is `devel-<short sha>`. The version can be set either
via the `go.mod` file or via the `$GOVERSION` environment variable. The specific
sha is downloaded from Github w/o git history. Builds may fail if GitHub is
down, but the compiled go version is cached.

When this is used the buildpack also downloads and installs the buildpack's
current default Go version for use in bootstrapping the compiler.

Build tests are NOT RUN. Go compilation failures will fail a build.

No official support is provided for unreleased versions of Go.

## Passing a symbol (and optional string) to the linker

This buildpack supports the go [linker's][go-linker] ability (`-X symbol value`)
to set the value of a string at link time. This can be done by setting
`GO_LINKER_SYMBOL` and `GO_LINKER_VALUE` in the application's config before
pushing code. If `GO_LINKER_SYMBOL` is set, but `GO_LINKER_VALUE` isn't set then
`GO_LINKER_VALUE` defaults to [`$SOURCE_VERSION`][source-version].

This can be used to embed the commit sha, or other build specific data directly
into the compiled executable.

## Testpack

This buildpack supports the [testpack] API used by [Heroku CI][herokuci].

### Golanglint-ci

If the source code contains a golanglint-ci configuration file in the root of
the source code (one of `/.golangci.yml`, `/.golangci.toml`, or
`/.golangci.json`) then golanci-lint is run at the start of the test phase.

Use one of those configuration files to configure the golanglint-ci run.

[app-engine-build-constraints]: http://blog.golang.org/2013/01/the-app-engine-sdk-and-workspaces-gopath.html
[build-constraint]: http://golang.org/pkg/go/build/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[cgo]: http://golang.org/cmd/cgo/
[curl]: https://curl.haxx.se/
[DefaultVersion]: https://github.com/heroku/heroku-buildpack-go/blob/main/data.json#L4
[docker]: https://www.docker.com/
[go-linker]: https://golang.org/cmd/ld/
[go]: http://golang.org/
[gomodules]: https://github.com/golang/go/wiki/Modules
[gopgsqldriver]: https://github.com/jbarham/gopgsqldriver
[herokuci]: https://devcenter.heroku.com/articles/heroku-ci
[jq]: https://github.com/stedolan/jq
[make]: https://www.gnu.org/software/make/
[Procfile]: https://devcenter.heroku.com/articles/procfile
[source-version]: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
[testpack]: https://devcenter.heroku.com/articles/testpack-api

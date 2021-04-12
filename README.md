# Heroku Buildpack for Go

[![CircleCI](https://circleci.com/gh/heroku/heroku-buildpack-go.svg?style=svg)](https://circleci.com/gh/heroku/heroku-buildpack-go)

![Heroku Buildpack for Go](https://cloud.githubusercontent.com/assets/51578/15877053/53506724-2cdf-11e6-878c-e2ef60ba741f.png)

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
vendor
Procfile
web.go

$ heroku create
Creating polar-waters-4785...
...

$ git push heroku main
...
-----> Go app detected
-----> Installing go1.11... done
-----> Running: go install -tags heroku .
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 1.6MB
-----> Launching... done, v4
       https://polar-waters-4785.herokuapp.com/ deployed to Heroku
```

This buildpack will detect your repository as Go if you are using either:

- [go modules][gomodules]
- [dep][dep]
- [govendor][govendor]
- [glide][glide]
- [GB][gb]
- [Godep][godep]

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

If a top level `vendor` directory exists and the `go.sum` file has a size
greater than zero, `go install` is invoked with `-mod=vendor`, causing the build
to skip downloading and checking of dependencies. This results in only the
dependencies from the top level `vendor` directory being used.

### Pre/Post Compile Hooks

If the file `bin/go-pre-compile` or `bin/go-post-compile` exists and is
executable then it will be executed either before compilation (go-pre-compile)
of the repo, or after compilation (go-post-compile).

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

## dep specifics

The `Gopkg.toml` file allows for arbitrary, tool specific fields. This buildpack
utilizes this feature to track build specific configuration which are encoded in
the following way:

- `metadata.heroku['root-package']` (String): the root package name of the
  packages you are pushing to Heroku.You can find this locally with `go list -e
  .`. There is no default for this and it must be specified.

- `metadata.heroku['go-version']` (String): the major version of go you would
  like Heroku to use when compiling your code. If not specified this defaults to
  the buildpack's [DefaultVersion]. Exact versions (ex `go1.9.4`) can also be
  specified if needed, but is not generally recommended. Since Go doesn't
  release `.0` versions, specifying a `.0` version will pin your code to the
  initial release of the given major version (ex `go1.10.0` == `go1.10` w/o auto
  updating to `go1.10.1` when it becomes available).

- `metadata.heroku['install']` (Array of Strings): a list of the packages you
  want to install. If not specified, this defaults to `["."]`. Other common
  choices are: `["./cmd/..."]` (all packages and sub packages in the `cmd`
  directory) and `["./..."]` (all packages and sub packages of the current
  directory). The exact choice depends on the layout of your repository though.
  Please note that `./...`, for versions of go < 1.9, includes any packages in
  your `vendor` directory.

- `metadata.heroku['ensure']` (String): if this is set to `false` then `dep
  ensure` is not run.

- `metadata.heroku['additional-tools']` (Array of Strings): a list of additional
  tools that the buildpack is aware of that you want it to install. If the tool
  has multiple versions an optional `@<version>` suffix can be specified to
  select that specific version of the tool. Otherwise the buildpack's default
  version is chosen. Currently the only supported tool is
  `github.com/golang-migrate/migrate` at `v3.4.0` (also the default version).

```toml
[metadata.heroku]
  root-package = "github.com/heroku/fixture"
  go-version = "go1.8.3"
  install = [ "./cmd/...", "./foo" ]
  ensure = "false"
  additional-tools = ["github.com/golang-migrate/migrate"]
...
```

## govendor specifics

The [vendor.json][vendor.json] spec that govendor follows for its metadata
file allows for arbitrary, tool specific fields. This buildpack uses this
feature to track build specific bits. These bits are encoded in the following
top level json keys:

- `rootPath` (String): the root package name of the packages you are pushing to
  Heroku. You can find this locally with `go list -e .`. There is no default for
  this and it must be specified. Recent versions of govendor automatically fill
  in this field for you. You can re-run `govendor init` after upgrading to have
  this field filled in automatically, or it will be filled the next time you use
   govendor to modify a dependency.

- `heroku.goVersion` (String): the major version of go you would like Heroku to
  use when compiling your code. If not specified this defaults to the
  buildpack's [DefaultVersion]. Exact versions (ex `go1.9.4`) can also be
  specified if needed, but is not generally recommended. Since Go doesn't
  release `.0` versions, specifying a `.0` version will pin your code to the
  initial release of the given major version (ex `go1.10.0` == `go1.10` w/o auto
  updating to `go1.10.1` when it becomes available).

- `heroku.install` (Array of Strings): a list of the packages you want to install.
  If not specified, this defaults to `["."]`. Other common choices are:
  `["./cmd/..."]` (all packages and sub packages in the `cmd` directory) and
  `["./..."]` (all packages and sub packages of the current directory). The exact
   choice depends on the layout of your repository though. Please note that `./...`
   includes any packages in your `vendor` directory.

- `heroku.additionalTools` (Array of Strings): a list of additional tools that
  the buildpack is aware of that you want it to install. If the tool has
  multiple versions an optional `@<version>` suffix can be specified to select
  that specific version of the tool. Otherwise the buildpack's default version
  is chosen. Currently the only supported tool is `github.com/golang-migrate/migrate` at
  `v3.4.0` (also the default version).

Example with everything, for a project using `go1.9`, located at
`$GOPATH/src/github.com/heroku/go-getting-started` and requiring a single package
spec of `./...` to install.

```json
{
    ...
    "rootPath": "github.com/heroku/go-getting-started",
    "heroku": {
        "install" : [ "./..." ],
        "goVersion": "go1.9"
         },
    ...
}
```

A tool like jq or a text editor can be used to inject these variables into
`vendor/vendor.json`.

## glide specifics

The `glide.yaml` and `glide.lock` files do not allow for arbitrary metadata, so
the buildpack relies solely on the glide command and environment variables to
control the build process.

The base package name is determined by running `glide name`.

The Go version used to compile code defaults to the buildpack's
[DefaultVersion]. This can be overridden by the `$GOVERSION` environment
variable. Setting `$GOVERSION` to a major version will result in the buildpack
using the latest released minor version in that series. Setting `$GOVERSION` to
a specific minor Go version will pin Go to that version. Since Go doesn't
release `.0` versions, specifying a `.0` version will pin your code to the
initial release of the given major version (ex `go1.10.0` == `go1.10` w/o auto
updating to `go1.10.1` when it becomes available).

Examples:

```console
heroku config:set GOVERSION=go1.9   # Will use go1.9.X, Where X is that latest minor release in the 1.9 series
heroku config:set GOVERSION=go1.7.5 # Pins to go1.7.5
```

`glide install` will be run to ensure that all dependencies are properly
installed. If you need the buildpack to skip the `glide install` you can set
`$GLIDE_SKIP_INSTALL` to `true`. Example:

```console
heroku config:set GLIDE_SKIP_INSTALL=true
git push heroku main
```

Installation defaults to `.`. This can be overridden by setting the
`$GO_INSTALL_PACKAGE_SPEC` environment variable to the package spec you want the
go tool chain to install. Example:

```console
heroku config:set GO_INSTALL_PACKAGE_SPEC=./...
git push heroku main
```

## Usage with other vendoring systems

If your vendor system of choice is not listed here or your project only uses
packages in the standard library, create `vendor/vendor.json` with the
following contents, adjusted as needed for your project's root path.

```json
{
    "comment": "For other heroku options see: https://devcenter.heroku.com/articles/go-support",
    "rootPath": "github.com/yourOrg/yourRepo",
    "heroku": {
        "sync": false
    }
}
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

Note: This buildpack should be able to figure out the name of the base package
in all cases, except when gb is being used.

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

[Make] & [docker] are required to run tests.

```console
make test
```

Run a specific test in `test/run.sh`:

```console
make BASH_COMMAND='test/run.sh -- testGBVendor' test
```

### Compiling a fixture locally

[Make] & [docker] are required to compile a fixture.

```console
make FIXTURE=<fixture name> compile
```

You will then be dropped into a bash prompt in the container that the fixture
was compiled in.

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
via the appropriate vendoring tools config file or via the `$GOVERSION`
environment variable. The specific sha is downloaded from Github w/o git
history. Builds may fail if GitHub is down, but the compiled go version is
cached.

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
[dep]: https://github.com/golang/dep
[docker]: https://www.docker.com/
[gb]: https://getgb.io/
[glide]: https://github.com/Masterminds/glide
[go-linker]: https://golang.org/cmd/ld/
[go]: http://golang.org/
[godep]: https://github.com/tools/godep
[gomodules]: https://github.com/golang/go/wiki/Modules
[gopgsqldriver]: https://github.com/jbarham/gopgsqldriver
[govendor]: https://github.com/kardianos/govendor
[herokuci]: https://devcenter.heroku.com/articles/heroku-ci
[LastPassCLI]: https://github.com/lastpass/lastpass-cli
[make]: https://www.gnu.org/software/make/
[Procfile]: https://devcenter.heroku.com/articles/procfile
[quickstart]: http://mmcgrana.github.com/2012/09/getting-started-with-go-on-heroku.html
[s3cmd]: https://s3tools.org/s3cmd
[shasum]: https://ss64.com/osx/shasum.html
[source-version]: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
[testpack]: https://devcenter.heroku.com/articles/testpack-api
[toolbelt]: https://devcenter.heroku.com/articles/heroku-cli
[vendor.json]: https://github.com/kardianos/vendor-spec

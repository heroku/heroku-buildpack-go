# Heroku Buildpack for Go

[![travis ci](https://travis-ci.org/heroku/heroku-buildpack-go.svg?branch=master)](https://travis-ci.org/heroku/heroku-buildpack-go)

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

$ git push heroku master
...
-----> Go app detected
-----> Installing go1.9... done
-----> Running: go install -tags heroku ./...
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 1.6MB
-----> Launching... done, v4
       https://polar-waters-4785.herokuapp.com/ deployed to Heroku
```

This buildpack will detect your repository as Go if you are using either:

- [dep][dep]
- [govendor][govendor]
- [glide][glide]
- [GB][gb]
- [Godep][godep]

This buildpack adds a `heroku` [build constraint][build-constraint], to enable
heroku-specific code. See the [App Engine build constraints
article][app-engine-build-constraints] for more info.

## dep specifics

The `Gopkg.toml` file allows for arbitrary, tool specific fields. This buildpack
utilizes this feature to track build specific configuration which are encoded in
the following way:

- `metadata.heroku['root-package']` (String): the root package name of the
  packages you are pushing to Heroku.You can find this locally with `go list -e
  .`. There is no default for this and it must be specified.

- `metadata.heroku['go-version']` (String): the major version of go you would
  like Heroku to use when compiling your code: if not specified defaults to the
  most recent supported version of Go.

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
  `github.com/mattes/migrate` at `v3.0.0` (also the default version).

```toml
[metadata.heroku]
  root-package = "github.com/heroku/fixture"
  go-version = "go1.8.3"
  install = [ "./cmd/...", "./foo" ]
  ensure = "false"
  additional-tools = ["github.com/mattes/migrate"]
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
  use when compiling your code: if not specified defaults to the most recent
  supported version of Go.

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
  is chosen. Currently the only supported tool is `github.com/mattes/migrate` at
  `v3.0.0` (also the default version).

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

The Go version used to compile code defaults to the latest released version of Go.
This can be overridden by the `$GOVERSION` environment variable. Setting
`$GOVERSION` to a major version will result in the buildpack using the
latest released minor version in that series. Setting `$GOVERSION` to a specific
minor Go version will pin Go to that version. Examples:

```console
heroku config:set GOVERSION=go1.9   # Will use go1.9.X, Where X is that latest minor release in the 1.9 series
heroku config:set GOVERSION=go1.7.5 # Pins to go1.7.5
```

`glide install` will be run to ensure that all dependencies are properly
installed. If you need the buildpack to skip the `glide install` you can set
`$GLIDE_SKIP_INSTALL` to `true`. Example:

```console
heroku config:set GLIDE_SKIP_INSTALL=true
git push heroku master
```

Installation defaults to `.`. This can be overridden by setting the
`$GO_INSTALL_PACKAGE_SPEC` environment variable to the package spec you want the
go tool chain to install. Example:

```console
heroku config:set GO_INSTALL_PACKAGE_SPEC=./...
git push heroku master
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
that tests have been added to the `test/run` script and any corresponding fixtures to
`test/fixtures/<fixture name>`.

### Tests

Requires docker.

```console
make test
```

### Compiling a fixture

Requires docker.

```console
make FIXTURE=<fixture name> compile
```

You will then be dropped into a bash prompt in the container in which the fixture was compiled in.

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

This buildpack also supports the testpack API.

## Deploying

```console
make publish # && follow the prompts
```

### New Go version

1. Edit `files.json`, and add an entry for the new version, including the SHA,
   which can be copied from golang.org.
1. Update `data.json`, to update the `VersionExpansion` object.
1. run `make ACCESS_KEY='THE KEY' SECRET_KEY='THE SECRET KEY' sync`.
   This will download everything from the bucket, plus any missing files from
   their source locations, and verify their SHAS, then upload anything missing
   from the bucket back to the s3 bucket. If a file doesn't verify this will
   error and it needs to be corrected.
1. Commit and push.

[go]: http://golang.org/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[go-linker]: https://golang.org/cmd/ld/
[dep]: https://github.com/golang/dep
[godep]: https://github.com/tools/godep
[govendor]: https://github.com/kardianos/govendor
[gb]: https://getgb.io/
[quickstart]: http://mmcgrana.github.com/2012/09/getting-started-with-go-on-heroku.html
[build-constraint]: http://golang.org/pkg/go/build/
[app-engine-build-constraints]: http://blog.golang.org/2013/01/the-app-engine-sdk-and-workspaces-gopath.html
[source-version]: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
[cgo]: http://golang.org/cmd/cgo/
[vendor.json]: https://github.com/kardianos/vendor-spec
[gopgsqldriver]: https://github.com/jbarham/gopgsqldriver
[glide]: https://github.com/Masterminds/glide

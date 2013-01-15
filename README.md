# Heroku Buildpack: Go

This is a [Heroku buildpack][buildpack] for Go.

This repository is useful if you want to inspect or
change the behavior of the buildpack itself. See the [Go
Buildpack Quickstart][quickstart] for a gentle
introduction suitable for all Heroku users.

## Example

    $ find . -type f -print
    ./.godir
    ./Procfile
    ./app.go

    $ heroku create --buildpack git://github.com/kr/heroku-buildpack-go.git
    ...

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom git buildpack... done
    -----> Go app detected
    -----> Using Go 1.0.2
    -----> Running: go get -tags heroku ./...
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 1.0MB
    -----> Launching... done, v1
           http://pure-sunrise-3607.herokuapp.com deployed to Heroku

The buildpack will detect your repository as Go if it
contains a `.go` file.

The buildpack adds a `heroku` [build constraint][build-constraint],
to enable heroku-specific code. See the [App Engine build constraints article][app-engine-build-constraints]
for more.

## Hacking

To change this buildpack, fork it on GitHub. Push
changes to your fork, then create a test app with
`--buildpack YOUR_GITHUB_GIT_URL` and push to it. If you
already have an existing app you may use `heroku config:add
BUILDPACK_URL=YOUR_GITHUB_GIT_URL` instead of `--buildpack`.

[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[quickstart]: http://mmcgrana.github.com/2012/09/getting-started-with-go-on-heroku.html
[build-constraint]: http://golang.org/pkg/go/build/
[app-engine-build-constraints]: http://blog.golang.org/2013/01/the-app-engine-sdk-and-workspaces-gopath.html


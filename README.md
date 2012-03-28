# Heroku Buildpak: Go

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

    $ heroku create -s cedar --buildpack git@github.com:kr/heroku-buildpack-go.git#rc
    ...

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack... done
    -----> Go app detected
    -----> Using Go weekly.2012-03-13
    -----> Running go get and go install
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 1.0MB
    -----> Launching... done, v1
           http://pure-sunrise-3607.herokuapp.com deployed to Heroku

The buildpack will detect your repository as Go if it
contains a `.go` file.

## Hacking

To change this buildpack, fork it on GitHub. Push
changes to your fork, then create a test app with
`--buildpack YOUR_GITHUB_GIT_URL` and push to it. If you
already have an existing app you may use `heroku config
add BUILDPACK_URL=YOUR_GITHUB_GIT_URL` instead of
`--buildpack`.

(example forthcoming)

[buildpack]: http://devcenter.heroku.com/articles/buildpack
[quickstart]: https://gist.github.com/299535bbf56bf3016cba

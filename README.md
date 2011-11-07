# Heroku Buildpak: Go

This is a [Heroku buildpack][buildpack] for Go apps. It
uses [goinstall][]. This repository is useful if you
want to inspect or change the behavior of the buildpack
itself. See the [Go Buildpack Quickstart][quickstart]
for a gentle introduction suitable for Heroku users.

## Usage

Example usage for an app already stored in git:

    $ find . -type f -print
    ./.gitignore
    ./Procfile
    ./src/hello/app.go

    $ heroku create -s cedar --buildpack http://github.com/kr/heroku-buildpack-go.git
    ...

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Go app detected
    -----> Using Go version release.r60.2
    -----> Go version release.r60.2 cached; Skipping clone
    -----> Go version release.r60.2 build; Skipping build
    -----> Running goinstall
    -----> Discovering process types
           Procfile declares types -> web
    -----> Compiled slug size is 912K
    -----> Launching... done, v1
    http://pure-sunrise-3607.herokuapp.com deployed to Heroku

The buildpack will detect your app as Go if it has a
`.go` file in the `src` directory, or any subdirectory.

## Hacking

To change this buildpack, fork it on GitHub. Push
changes to your fork, then create a test app with
`--buildpack YOUR_GITHUB_URL` and push to it. If you
already have an existing app you may use `heroku config
add BUILDPACK_URL=YOUR_GITHUB_URL` instead of
`--buildpack`.

(example forthcoming)

[buildpack]: http://devcenter.heroku.com/articles/buildpack
[goinstall]: http://golang.org/cmd/goinstall/
[quickstart]: https://gist.github.com/299535bbf56bf3016cba

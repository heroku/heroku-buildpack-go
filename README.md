# Heroku Buildpak: Go

This is a [Heroku buildpack][buildpack] for Go.

This repository is useful if you want to inspect or
change the behavior of the buildpack itself. See the [Go
Buildpack Quickstart][quickstart] for a gentle
introduction suitable for all Heroku users.

## Example

    $ tree
    .
    ├── Procfile
    └── src
        └── app
            └── main.go

    $ cat Procfile
    web: app

    $ cat src/app/main.go
    package main

    import (
        "fmt"
        "net/http"
        mustache "github.com/hoisie/mustache.go"
        "os"
    )

    func main() {
        http.HandleFunc("/", handler)
        e := http.ListenAndServe("0.0.0.0:"+os.Getenv("PORT"), nil)
        if e != nil {
            panic(e)
        }
    }

    const (
        TEMPLATE = `I can't believe it's not {{enginename}}`
    )
    func handler(w http.ResponseWriter, r *http.Request) {
        var msg = mustache.Render(TEMPLATE, map[string]string{"enginename":"GAE"})
        fmt.Fprintf(w, msg)
    }

    $ heroku create -s cedar --buildpack git@github.com:kr/heroku-buildpack-go.git
    ...

    $ git push heroku master
    ...

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

[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[quickstart]: https://gist.github.com/299535bbf56bf3016cba

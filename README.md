# Heroku Buildpack: Go

This is a [Heroku buildpack][buildpack] for [Go][go]. It currently supports Go v1.1.1.

## Getting Started

Follow the guide at
<http://mmcgrana.github.com/2012/09/getting-started-with-go-on-heroku.html>.

There's also a hello world sample app at
<https://github.com/kr/go-heroku-example>.

## Example

Create a new Heroku application with the buildpack:

`$ heroku create -b https://github.com/kr/heroku-buildpack-go.git`

You'll need these files to tell Heroku where your application is, and how to run it (see the [guide](http://mmcgrana.github.io/2012/09/getting-started-with-go-on-heroku.html)):

```
$ ls -A1
./.git
./.godir
./Procfile
./web.go

```

Push your application up to Heroku:

```
$ git push heroku master
...
-----> Fetching custom git buildpack... done
-----> Go app detected
-----> Installing Go 1.1.1... done
       Installing Virtualenv... done
       Installing Mercurial... done
       Installing Bazaar... done
-----> Running: go get -tags heroku ./...
-----> Discovering process types
       Procfile declares types -> web
-----> Compiled slug size: 1.0MB
-----> Launching... done, v5
       http://pure-sunrise-3607.herokuapp.com deployed to Heroku
```

The buildpack will detect your repository as Go if it contains a `.go` file.

The buildpack adds a `heroku` [build constraint][build-constraint],
to enable heroku-specific code. See the [App Engine build constraints article][app-engine-build-constraints]
for more.

## Hacking on this Buildpack

To change this buildpack, fork it on GitHub. Push
changes to your fork, then create a test app with
`--buildpack YOUR_GITHUB_GIT_URL` and push to it. If you
already have an existing app you may use `heroku config:add
BUILDPACK_URL=YOUR_GITHUB_GIT_URL` instead of `--buildpack`.

[go]: http://golang.org/
[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[quickstart]: http://mmcgrana.github.com/2012/09/getting-started-with-go-on-heroku.html
[build-constraint]: http://golang.org/pkg/go/build/
[app-engine-build-constraints]: http://blog.golang.org/2013/01/the-app-engine-sdk-and-workspaces-gopath.html

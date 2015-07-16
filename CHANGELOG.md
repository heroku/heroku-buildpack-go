### Unreleased

* Use a canonical import path if it exists.
* Respect apps current GO_VERSION if defined when not using Godeps.

### V14

* Basic validation of Godeps/Godeps.json file: 
    https://github.com/heroku/heroku-buildpack-go/commit/c01751fdfcd5476421a6229ac4168a9c76823d4b

### v13

* Set GOMAXPROCS based on dyno size.

### v12

* https://github.com/heroku/heroku-buildpack-go/pull/82
    fix GOPATH naming. Ended in 'g', now ends in 'go'
* Update vendored godep to the latest version


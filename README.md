# Heroku Buildpack: Go

This is a [Heroku buildpack][buildpack] for Go.

## Usage
This buildpack supports to directory structures to accomodate the two basic types of Go programmers.

### Layout 1
Either put your packages side by side in their own folder:

    $ tree
    .
    |-- Procfile
    |-- app
    |   `-- app.go
    `-- consts
        `-- consts.go

When using this layout, the repository will be copied to a prepared `$GOPATH`.

### Layout 2
The alternative is make the repository `$GOPATH` compliant:

    $ tree
    .
    |-- Procfile
    `-- src
        |-- app
        |   `-- app.go
        |-- consts
            `-- consts.go

When using this layout, `$GOPATH` will be set to your repository's path.

If you wrote a new app, create it on Heroku using:

    $ heroku create --stack cedar --buildpack git@github.com:surma/heroku-buildpack-go.git

If the app already exists on Heroku, do:

    $ heroku config:add BUILDPACK_URL=git@github.com:surma/heroku-buildpack-go.git


## Example Repository

An example Heroku-deployable App can be found at [heroku-buildpack-go-app](http://github.com/surma/heroku-buildpack-go-app)

Remote pacakges using `git` and `hg` are supported. `bzr` is next on the TODO list.

[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[quickstart]: https://gist.github.com/299535bbf56bf3016cba

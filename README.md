# Heroku Buildpack: Go

This is a [Heroku buildpack][buildpack] for Go.

## Usage 
Write your app in a folder which obeys the `$GOPATH` structure. Define your web and worker applications in the `Procfile` like usual.  
If you wrote a new app, create it on Heroku using:

    $ heroku create --stack cedar --buildpack git@github.com:surma/heroku-buildpack-go.git

If the app already exists on Heroku, do:

    $ heroku config:add BUILDPACK_URL=git@github.com:surma/heroku-buildpack-go.git


## Example Tree

    $ tree
    .
    |-- Procfile
    `-- src
        |-- app
        |   `-- app.go
        `-- consts
            `-- consts.go

For the contained sourcecode see [heroku-buildpack-go-app](http://github.com/surma/heroku-buildpack-go-app)

Remote pacakges using `git` and `hg` are supported. `bzr` is next on the TODO list.

[buildpack]: http://devcenter.heroku.com/articles/buildpacks
[quickstart]: https://gist.github.com/299535bbf56bf3016cba

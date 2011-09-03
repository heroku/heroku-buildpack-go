# Go language pack

*Use*

		$ cat all.sh
		#!/bin/sh
		set -e
		GOPATH="$PWD"
		export GOPATH
		goinstall ./src/prettydemo/prettydemo

		$ heroku create --stack cedar
		$ heroku config:add LANGUAGE_PACK_URL="https://user:pass@github.com/heroku/language-pack-go.git"
		$ git push heroku master
		Counting objects: 11, done.
		Delta compression using up to 2 threads.
		Compressing objects: 100% (7/7), done.
		Writing objects: 100% (11/11), 1.10 KiB, done.
		Total 11 (delta 0), reused 0 (delta 0)

		-----> Heroku receiving push
		-----> Fetching custom language pack... done
		-----> Go app detected
		-----> Using Go version release.r59
		-----> Cloning Go version release.r59.
		       adding changesets
		       adding manifests
		       adding file changes
		       added 8980 changesets with 33787 changes to 4602 files
		       updating to branch release-branch.r59
		       2885 files updated, 0 files merged, 0 files removed, 0 files unresolved
		-----> Building Go version release.r59.
		-----> Running all.sh
		-----> Discovering process types
		       Procfile declares types -> web
		-----> Compiled slug size is 1.0MB
		-----> Launching... done, v4
		       http://pure-journey-27.herokuapp.com deployed to Heroku


*Go versions*

You can use whichever version of Go you like; The default is `release.r59`. This language pack builds Go on your first deploy according to the `GOVERSION` environment variable set. You can change this with `heroku config:add GOVERSION=weekly.2011-1-1` for example, or even a SHA.

Once built, the language pack will keep it cached for future deploys, until you change the GOVERSION.

*Demo*
You can find the demo here:
https://gist.github.com/e4c1ceeb90624acc45b9

*TODO*

Create a cron job to build releases and cache in this repo to avoid the build step for tagged releases.

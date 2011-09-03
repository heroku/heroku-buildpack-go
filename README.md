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

*Go versions*

You can use whichever version of Go you like; The default is `release.r59`. This language pack builds Go on your first deploy according to the `GOVERSION` environment variable set. You can change this with `heroku config:add GOVERSION=weekly.2011-1-1` for example, or even a SHA.

Once built, the language pack will keep it cached for future deploys, until you change the GOVERSION.

*Demo*
You can find the demo here:
https://gist.github.com/e4c1ceeb90624acc45b9

*TODO*

Create a cron job to build releases and cache in this repo to avoid the build step for tagged releases.

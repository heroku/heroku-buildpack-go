#!/bin/bash

docker images | grep heroku/testrunner > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "You must first create the Docker image 'heroku/testrunner' from the heroku-buildpack-testrunner project"
fi

DIR=$(cd $(dirname $0)/..; pwd)

docker run -it -v $DIR:/app/buildpack:ro heroku/testrunner

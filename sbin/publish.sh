#!/bin/bash

set -e

BP_NAME=${1:-"heroku/go"}

curVersion=$(heroku buildpacks:versions "$BP_NAME" | awk 'FNR == 3 { print $1 }')
newVersion="v$((curVersion + 1))"

read -r -p "Deploy as version: $newVersion [y/n]? " choice
case "$choice" in
  y|Y ) echo "";;
  n|N ) exit 0;;
  * ) exit 1;;
esac

originMain=$(git rev-parse origin/main)
echo "Tagging commit $originMain with $newVersion... "
git tag "$newVersion" "${originMain:?}"
git push origin refs/tags/$newVersion

heroku buildpacks:publish "$BP_NAME" "$newVersion"

echo "Done."
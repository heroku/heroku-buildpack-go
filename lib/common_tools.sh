#!/bin/bash

# Ensure jq is installed.
ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Ensure we have a copy of stdlib.sh.v8 in the path
ensureInPath "stdlib.sh.v8" "$(mktemp -d -t go-buildpack-stdlib.XXXXX)" "chmod a+x"

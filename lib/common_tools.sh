#!/bin/bash

# Ensure jq is installed.
ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Ensure we have a copy of the stdlib
STDLIB_DIR=$(mktemp -d -t stdlib.XXXXX)
BPLOG_PREFIX="buildpack.go"
ensureFile "stdlib.sh.v8" "${STDLIB_DIR}" "chmod a+x"

source_stdlib() {
  source "${STDLIB_DIR}/stdlib.sh.v8"
}

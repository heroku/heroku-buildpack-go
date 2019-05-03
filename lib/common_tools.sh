#!/bin/bash

# Ensure jq is installed.
ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Ensure we have a copy of the stdlib
STDLIB_DIR="${TMPDIR:-"/tmp"}/go-buildpack-stdlib"
ensureFile "stdlib.sh.v8" "${STDLIB_DIR}" "chmod a+x"
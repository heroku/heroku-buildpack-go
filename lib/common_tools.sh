#!/bin/bash

# Ensure jq is installed.
ensureInPath "jq-linux64" "${cache}/.jq/bin"

# Ensure we have a copy of the stdlib
if [ -z "${TMPDIR}" ]; then
  STDLIB_DIR=$(mktemp -d -t stdlib.XXXXX)
else
  STDLIB_DIR="${TMPDIR}/go-buildpack-stdlib"
fi
ensureFile "stdlib.sh.v8" "${STDLIB_DIR}" "chmod a+x"

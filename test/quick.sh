#!/usr/bin/env bash

. $(pwd)/test/utils.sh

export SHUNIT_TMPDIR=/tmp
oneTimeSetUp
setUp

capture() {
  $@
}

quickSetup() {
  local fix=${1}
  fixture "${fix}"
  shift
  while (( "$#" )); do
    env=("$(echo ${1} | cut -d = -f 1)")
    val=("$(echo ${1} | cut -d = -f 2)")
    echo "${val}" > "${ENV_DIR}/${env}"
    shift
  done
  echo "Compiling ${fix}"
  echo "in ${BUILD_DIR}"
  echo "(caching in $CACHE_DIR)"
  echo "(env in ${ENV_DIR}): ${env[@]}"
}

cmd="${1:-compile}"
shift
fixture="${1:-govendor-basic}"
shift
r=("$@")

quickSetup "${fixture}" "${r[@]}"
$cmd "${fixture}" "${r[@]}"
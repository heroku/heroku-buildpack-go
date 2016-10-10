#!/bin/bash

# -----------------------------------------
# load environment variables
# allow apps to specify cgo flags. The literal text '${build_dir}' is substituted for the build directory

godepsJSON="${build}/Godeps/Godeps.json"
vendorJSON="${build}/vendor/vendor.json"
glideYAML="${build}/glide.yaml"

steptxt="----->"
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color
CURL="curl -s -L --retry 15 --retry-delay 2" # retry for up to 30 seconds

warn() {
    echo -e "${YELLOW} !!    $@${NC}"
}

err() {
    echo -e >&2 "${RED} !!    $@${NC}"
}

step() {
    echo "$steptxt $@"
}

start() {
    echo -n "$steptxt $@... "
}

finished() {
    echo "done"
}

loadEnvDir() {
    local env_dir="${1}"
    if [ ! -z "${env_dir}" ]
    then
        mkdir -p "${env_dir}"
        env_dir=$(cd "${env_dir}/" && pwd)
        for key in CGO_CFLAGS CGO_CPPFLAGS CGO_CXXFLAGS CGO_LDFLAGS GO_LINKER_SYMBOL GO_LINKER_VALUE GO15VENDOREXPERIMENT GOVERSION GO_INSTALL_PACKAGE_SPEC GO_INSTALL_TOOLS_IN_IMAGE GO_SETUP_GOPATH_IN_IMAGE
        do
            if [ -f "${env_dir}/${key}" ]
            then
                export "${key}=$(cat "${env_dir}/${key}" | sed -e "s:\${build_dir}:${build}:")"
            fi
        done
    fi
}

setGoVersionFromEnvironment() {
  if test -z "${GOVERSION}"
  then
    warn ""
    warn "'GOVERSION' isn't set, defaulting to '${DefaultGoVersion}'"
    warn ""
    warn "Run 'heroku config:set GOVERSION=goX.Y' to set the Go version to use"
    warn "for future builds"
    warn ""
  fi
  ver=${GOVERSION:-$DefaultGoVersion}
}

determineTool() {
    if test -f "${godepsJSON}"
    then
        TOOL="godep"
        step "Checking Godeps/Godeps.json file."
        if ! jq -r . < "${godepsJSON}" > /dev/null
        then
            err "Bad Godeps/Godeps.json file"
            exit 1
        fi
        name=$(<${godepsJSON} jq -r .ImportPath)
        ver=${GOVERSION:-$(<${godepsJSON} jq -r .GoVersion)}
        warnGoVersionOverride
    elif test -f "${vendorJSON}"
    then
        TOOL="govendor"
        step "Checking vendor/vendor.json file."
        if ! jq -r . < "${vendorJSON}" > /dev/null
        then
            err "Bad vendor/vendor.json file"
            exit 1
        fi
        name=$(<${vendorJSON} jq -r .rootPath)
        if [ "$name" = "null" -o -z "$name" ]
        then
            err "The 'rootPath' field is not specified in 'vendor/vendor.json'."
            err "'rootPath' must be set to the root package name used by your repository."
            err "Recent versions of govendor add this field automatically, please upgrade"
            err "and re-run 'govendor init'."
            err ""
            err "For more details see: https://devcenter.heroku.com/articles/go-apps-with-govendor#build-configuration"
            exit 1

        fi
        ver=${GOVERSION:-$(<${vendorJSON} jq -r .heroku.goVersion)}
        warnGoVersionOverride
        if [ "${ver}" =  "null" -o -z "${ver}" ]
        then
        ver=${DefaultGoVersion}
        warn "The 'heroku.goVersion' field is not specified in 'vendor/vendor.json'."
        warn ""
        warn "Defaulting to ${ver}"
        warn ""
        warn "For more details see: https://devcenter.heroku.com/articles/go-apps-with-govendor#build-configuration"
        warn ""
        fi
    elif test -f "${glideYAML}"
    then
        TOOL="glide"
        setGoVersionFromEnvironment
    elif (test -d "$build/src" && test -n "$(find "$build/src" -mindepth 2 -type f -name '*.go' | sed 1q)")
    then
        TOOL="gb"
        setGoVersionFromEnvironment
    else
        err "Godep, GB or govendor are required. For instructions:"
        err "https://devcenter.heroku.com/articles/go-support"
        exit 1
    fi
}
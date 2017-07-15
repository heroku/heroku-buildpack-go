#!/bin/bash

# -----------------------------------------
# load environment variables
# allow apps to specify cgo flags. The literal text '${build_dir}' is substituted for the build directory

if [ -z "${buildpack}" ]; then
    buildpack=$(cd "$(dirname $0)/.." && pwd)
fi

DataJSON="${buildpack}/data.json"
FilesJSON="${buildpack}/files.json"
godepsJSON="${build}/Godeps/Godeps.json"
vendorJSON="${build}/vendor/vendor.json"
herokuJSON="${build}/heroku.json"
glideYAML="${build}/glide.yaml"
gopkgLOCK="${build}/Gopkg.lock"

steptxt="----->"
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color
CURL="curl -s -L --retry 15 --retry-delay 2" # retry for up to 30 seconds

BucketURL="https://heroku-golang-prod.s3.amazonaws.com"

TOOL=""
# Default to $SOURCE_VERSION environment variable: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
GO_LINKER_VALUE=${SOURCE_VERSION}


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

determinLocalFileName() {
    local fileName="${1}"
    local localName="jq"
    if [ "${fileName}" != "jq-linux64" ]; then #jq is special cased here because we can't jq until we have jq'
        localName="$(<"${FilesJSON}" jq -r '."'${fileName}'".LocalName | if . == null then "'${fileName}'" else . end')"
    fi
    echo "${localName}"
}

downloadFile() {
    local fileName="${1}"
    local targetDir="${2}"
    local xCmd="${3}"
    local localName="$(determinLocalFileName "${fileName}")"
    local targetFile="${targetDir}/${localName}"

    mkdir -p "${targetDir}"
    pushd "${targetDir}" &> /dev/null
        start "Fetching ${localName}"
            ${CURL} -O "${BucketURL}/${fileName}"
            if [ "${fileName}" != "${localName}" ]; then
                mv "${fileName}" "${localName}"
            fi
            if [ -n "${xCmd}" ]; then
                ${xCmd} ${targetFile}
            fi
            if ! SHAValid "${fileName}" "${targetFile}"; then
                err ""
                err "Downloaded file (${fileName}) sha does not match recorded SHA"
                err "Unable to continue."
                err ""
                exit 1
            fi
        finished
    popd &> /dev/null
}

SHAValid() {
    local fileName="${1}"
    local targetFile="${2}"
    local sh=""
    local sw="$(<"${FilesJSON}" jq -r '."'${fileName}'".SHA')"
    if [ ${#sw} -eq 40 ]; then
        sh="$(shasum "${targetFile}" | cut -d \  -f 1)"
    else
        sh="$(shasum -a256 "${targetFile}" | cut -d \  -f 1)"
    fi
    [ "${sh}" = "${sw}" ]
}

ensureFile() {
    local fileName="${1}"
    local targetDir="${2}"
    local xCmd="${3}"
    local localName="$(determinLocalFileName "${fileName}")"
    local targetFile="${targetDir}/${localName}"
    local download="false"
    if [ ! -f "${targetFile}" ]; then
        download="true"
    elif ! SHAValid "${fileName}" "${targetFile}"; then
        download="true"
    fi
    if [ "${download}" = "true" ]; then
        downloadFile "${fileName}" "${targetDir}" "${xCmd}"
    fi
}

addToPATH() {
    local targetDir="${1}"
    if echo "${PATH}" | grep -v "${targetDir}" &> /dev/null; then
        PATH="${targetDir}:${PATH}"
    fi
}

ensureInPath() {
    local fileName="${1}"
    local targetDir="${2}"
    local xCmd="${3:-chmod a+x}"
    local localName="$(determinLocalFileName "${fileName}")"
    local targetFile="${targetDir}/${localName}"
    addToPATH "${targetDir}"
    ensureFile "${fileName}" "${targetDir}" "${xCmd}"
}

loadEnvDir() {
    local envFlags=()
    envFlags+=("CGO_CFLAGS")
    envFlags+=("CGO_CPPFLAGS")
    envFlags+=("CGO_CXXFLAGS")
    envFlags+=("CGO_LDFLAGS")
    envFlags+=("GO_LINKER_SYMBOL")
    envFlags+=("GO_LINKER_VALUE")
    envFlags+=("GO15VENDOREXPERIMENT")
    envFlags+=("GOVERSION")
    envFlags+=("GO_INSTALL_PACKAGE_SPEC")
    envFlags+=("GO_INSTALL_TOOLS_IN_IMAGE")
    envFlags+=("GO_SETUP_GOPATH_IN_IMAGE")
    envFlags+=("GO_TEST_SKIP_BENCHMARK")
    envFlags+=("GLIDE_SKIP_INSTALL")
    local env_dir="${1}"
    if [ ! -z "${env_dir}" ]; then
        mkdir -p "${env_dir}"
        env_dir=$(cd "${env_dir}/" && pwd)
        for key in ${envFlags[@]}; do
            if [ -f "${env_dir}/${key}" ]; then
                export "${key}=$(cat "${env_dir}/${key}" | sed -e "s:\${build_dir}:${build}:")"
            fi
        done
    fi
}

setGoVersionFromEnvironment() {
    if [ -z "${GOVERSION}" ]; then
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
    if [ -f "${gopkgLOCK}" ]; then
        TOOL="dep"
        step "Checking heroku.json file."
        if ! jq -r . < "${herokuJSON}" > /dev/null; then
            err "Bad heroku.json file"
            exit 1
        fi
        name=$(<${herokuJSON} jq -r .rootPath)
        setGoVersionFromEnvironment
    elif [ -f "${godepsJSON}" ]; then
        TOOL="godep"
        step "Checking Godeps/Godeps.json file."
        if ! jq -r . < "${godepsJSON}" > /dev/null; then
            err "Bad Godeps/Godeps.json file"
        exit 1
        fi
        name=$(<${godepsJSON} jq -r .ImportPath)
        ver=${GOVERSION:-$(<${godepsJSON} jq -r .GoVersion)}
        warnGoVersionOverride
    elif [ -f "${vendorJSON}" ]; then
        TOOL="govendor"
        step "Checking vendor/vendor.json file."
        if ! jq -r . < "${vendorJSON}" > /dev/null; then
            err "Bad vendor/vendor.json file"
            exit 1
        fi
        name=$(<${vendorJSON} jq -r .rootPath)
        if [ "$name" = "null" -o -z "$name" ]; then
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
        if [ "${ver}" =  "null" -o -z "${ver}" ]; then
            ver=${DefaultGoVersion}
            warn "The 'heroku.goVersion' field is not specified in 'vendor/vendor.json'."
            warn ""
            warn "Defaulting to ${ver}"
            warn ""
            warn "For more details see: https://devcenter.heroku.com/articles/go-apps-with-govendor#build-configuration"
            warn ""
        fi
    elif [ -f "${glideYAML}" ]; then
        TOOL="glide"
        setGoVersionFromEnvironment
    elif [ -d "$build/src" -a -n "$(find "$build/src" -mindepth 2 -type f -name '*.go' | sed 1q)" ]; then
        TOOL="gb"
        setGoVersionFromEnvironment
    else
        err "dep, Godep, GB, govendor, or glide are required. For instructions:"
        err "https://devcenter.heroku.com/articles/go-support"
        exit 1
    fi
}

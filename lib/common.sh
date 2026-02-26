#!/bin/bash

# -----------------------------------------
# load environment variables
# allow apps to specify cgo flags. The literal text '${build_dir}' is substituted for the build directory
DataJSON="${buildpack}/data.json"
FilesJSON="${buildpack}/files.json"
goMOD="${build}/go.mod"

steptxt="----->"
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color
CURL="curl --silent --show-error --location --fail --retry 15 --retry-delay 2 --retry-connrefused --connect-timeout 5" # retry for up to 30 seconds

if [ -z "${GO_BUCKET_URL}" ]; then
    BucketURL="https://heroku-golang-prod.s3.dualstack.us-east-1.amazonaws.com"
else
    BucketURL="${GO_BUCKET_URL}"
fi

TOOL=""
# Default to $SOURCE_VERSION environment variable: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
GO_LINKER_VALUE=${SOURCE_VERSION}

snapshotBinBefore() {
  if [ ! -d "${build}/bin" ]; then
    return 0
  fi
  _oifs=$IFS
  IFS=$'\n'
  _binBefore=()
  for f in ${build}/bin/*; do
    if [ -f $f ]; then
      _binBefore+=($(shasum $f))
    fi
  done
  IFS=$_oifs
}

binDiff() {
  _oifs=$IFS
  IFS=$'\n'
  local binAfter=()
  for f in ${build}/bin/*; do
    if [ -f $f ]; then
      binAfter+=($(shasum $f))
    fi
  done

  local new=()
  for a in "${binAfter[@]}"; do
    local let found=0

    for b in "${_binBefore[@]}"; do
        if [ "${a}" = "${b}" ]; then
        let found+=1
        fi
    done

    if [ $found -eq 0 ]; then
        new+=( "./bin/$(basename $(echo $a | awk '{print $2}' ) )" )
    fi
  done
  IFS=$_oifs
  echo ${new[@]}
}

info() {
    echo -e "${GREEN}       $@${NC}"
}

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

knownFile() {
    local fileName="${1}"
    <${FilesJSON} jq -e 'to_entries | map(select(.key == "'${fileName}'")) | any' &> /dev/null
}

downloadFile() {
    local fileName="${1}"

    if ! knownFile ${fileName}; then
        err ""
        err "The requested file (${fileName}) is unknown to the buildpack!"
        err ""
        err "The buildpack tracks and validates the SHA256 sums of the files"
        err "it uses. Because the buildpack doesn't know about the file"
        err "it likely won't be able to obtain a copy and validate the SHA."
        err ""
        err "To find out more info about this error please visit:"
        err "    https://devcenter.heroku.com/articles/unknown-go-buildack-files"
        err ""
        exit 1
    fi

    local targetDir="${2}"
    local xCmd="${3}"
    local targetFile="${targetDir}/${fileName}"

    mkdir -p "${targetDir}"
    pushd "${targetDir}" &> /dev/null
        start "Fetching ${fileName}"
            ${CURL} -O "${BucketURL}/${fileName}"
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
    local expected="$(<"${FilesJSON}" jq -r '."'${fileName}'".SHA')"
    local actual="$(shasum -a256 "${targetFile}" | cut -d \  -f 1)"
    [ "${actual}" = "${expected}" ]
}

ensureFile() {
    local fileName="${1}"
    local targetDir="${2}"
    local xCmd="${3}"
    local targetFile="${targetDir}/${fileName}"
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
    envFlags+=("GOFLAGS")
    envFlags+=("GOPROXY")
    envFlags+=("GOPRIVATE")
    envFlags+=("GONOPROXY")
    envFlags+=("GOVERSION")
    envFlags+=("GO_INSTALL_PACKAGE_SPEC")
    envFlags+=("GO_INSTALL_TOOLS_IN_IMAGE")
    envFlags+=("GO_SETUP_GOPATH_FOR_MODULE_CACHE")
    envFlags+=("GO_TEST_SKIP_BENCHMARK")
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

clearGitCredHelper() {
    git config --global --unset credential.helper
}

setGitCredHelper() {
    git config --global credential.helper '!#GoGitCredHelper
    env_dir="'$(cd ${1}/ && pwd)'"
    gitCredHelper() {
    #echo "${1}\n" >&2 #debug
    case "${1}" in
        setup|erase) # Read only, so ignore
        ;;
        get)
            local protocol=""
            local host=""
            local username=""
            local password=""
            local key=""
            local value=""
            while read LINE; do
                key=$(echo $LINE | cut -d = -f 1)
                value=$(echo $LINE | cut -d = -f 2)
                case "${key}" in
                    protocol)
                        protocol="$(echo ${value} | sed -e "s/.*/\U&/")"
                    ;;
                    host)
                        host="$(echo ${value} | sed -e "s/\./__/" -e "s/.*/\U&/")"
                    ;;
                    username)
                        username="${value}"
                    ;;
                    password)
                        password="${value}"
                    ;;
                    wwwauth[])
                        :
                    ;;
                    *)
                        echo "Unsupported key: ${key}=${value}" >&2
                        exit 1
                    ;;
                esac
                #echo LINE=$LINE >&2    #debug
                #echo key=$key >&2      #debug
                #echo value=$value >&2  #debug
            done
            local f="${env_dir}/GO_GIT_CRED__${protocol}__${host}"
            #echo f=${f} >&2  #debug
            #echo >&2         #debug
            if [ -f "${f}" ]; then
                echo "Using credentials from GO_GIT_CRED__${protocol}__${host}" >&2
                t=$(cat ${f})
                #echo "t=${t}" >&2  #debug
                case "${t}" in
                  *:*)
                    username="$(echo $t | cut -d : -f 1)"
                    password="$(echo $t | cut -d : -f 2)"
                  ;;
                  *)
                    username="${t}"
                    password="${t}"
                  ;;
                esac
                echo username=${username}
                #echo username=${username} >&2  #debug
                echo password=${password}
                #echo password=${password} >&2  #debug
            fi
        ;;
    esac
}; gitCredHelper'
}

supportsGoModules() {
    local version="${1}"
    # Ex:      "go1.10.4" | ["go1","10", "4"] | ["1","10","4"]     | [1,10,4]      |  [1]           [10]      == exit 1 (fail)
    echo "\"${version}\"" | jq -e 'split(".") | map(gsub("go";"")) | map(tonumber) | .[0] >= 1 and .[1] < 11' &> /dev/null
}

determineTool() {
    # Check GOVERSION first - it overrides all tool-specific configurations
    if [ -n "${GOVERSION}" ]; then
        ver="${GOVERSION}"
        go_version_origin="GOVERSION"
        build_data::set_string "go_version_origin" "${go_version_origin}"
        build_data::set_string "go_version_requested" "${ver}"
    fi

    if [ -f "${goMOD}" ]; then
        TOOL="gomodules"
        build_data::set_string "go_tool" "${TOOL}"

        step ""
        info "Detected go modules via go.mod"
        step ""

        # Determine Go version from go.mod if not already set by GOVERSION
        if [ -z "${ver}" ]; then
            ver=$(awk '{ if ($1 == "//" && $2 == "+heroku" && $3 == "goVersion" ) { print $4; exit } }' ${goMOD})
            if [ -n "${ver}" ]; then
                go_version_origin="go.mod (heroku comment)"
            else
                ver=$(awk '{ if ($1 == "go" ) { print "go" $2; exit } }' ${goMOD})
                if [ -n "${ver}" ]; then
                    go_version_origin="go.mod"
                else
                    ver=${DefaultGoVersion}
                    go_version_origin="default"
                fi
            fi
            build_data::set_string "go_version_origin" "${go_version_origin}"
            build_data::set_string "go_version_requested" "${ver}"
        fi

        name=$(awk '{ if ($1 == "module" ) { gsub(/"/, "", $2); print $2; exit } }' < ${goMOD})
        info "Detected Module Name: ${name}"
        step ""
        warnGoVersionOverride

        if [ "${go_version_origin}" = "default" ]; then
            warn "The go.mod file for this project does not specify a Go version"
            warn ""
            warn "Defaulting to ${ver}"
            warn ""
            warn "For more details see: https://devcenter.heroku.com/articles/go-apps-with-modules#build-configuration"
            warn ""
        fi

        if supportsGoModules "${ver}"; then
            err "You are using ${ver}, which does not support Go modules"
            err ""
            err "Go modules are supported by go1.11 and above."
            err ""
            err "Please add/update the comment in your go.mod file to specify a Go version >= go1.11 like so:"
            err "// +heroku goVersion ${DefaultGoVersion}"
            err ""
            err "Then commit and push again."
            exit 1
        fi
    else
        err "A go.mod file is required. For instructions:"
        err "https://devcenter.heroku.com/articles/go-support"
        exit 1
    fi
}

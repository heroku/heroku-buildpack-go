#!/usr/bin/env bash

# shellcheck disable=SC2034 # Variables like DataJSON, GO_LINKER_VALUE, TOOL are used by the caller (bin/compile)

# -----------------------------------------
# load environment variables
# allow apps to specify cgo flags. The literal text '${build_dir}' is substituted for the build directory

# shellcheck disable=SC2154 # buildpack, build, SOURCE_VERSION, DefaultGoVersion are set by the caller (bin/compile)
DataJSON="${buildpack}/data.json"
FilesJSON="${buildpack}/files.json"
goMOD="${build}/go.mod"

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/output.sh"
# We use --max-time/--retry-max-time for improved UX and metrics for hanging downloads compared to
# seconds relying on the build system timeout. Go tarballs are up to ~70 MB and typically download in a few
# seconds on Heroku, so we set relatively low timeouts to reduce delays before retries.
# We use --no-progress-meter rather than --silent so that retry status messages are printed.
CURL="curl --no-progress-meter --location --fail --max-time 30 --retry-max-time 200 --retry 5 --retry-connrefused --connect-timeout 5"

TOOL=""
# Default to $SOURCE_VERSION environment variable: https://devcenter.heroku.com/articles/buildpack-api#bin-compile
GO_LINKER_VALUE="${SOURCE_VERSION}"

snapshotBinBefore() {
	if [[ ! -d "${build}/bin" ]]; then
		return 0
	fi
	_oifs=${IFS}
	IFS=$'\n'
	_binBefore=()
	for f in "${build}"/bin/*; do
		if [[ -f "${f}" ]]; then
			# shellcheck disable=SC2207
			_binBefore+=("$(shasum "${f}")")
		fi
	done
	IFS=${_oifs}
}

binDiff() {
	_oifs=${IFS}
	IFS=$'\n'
	local binAfter=()
	for f in "${build}"/bin/*; do
		if [[ -f "${f}" ]]; then
			# shellcheck disable=SC2207
			binAfter+=("$(shasum "${f}")")
		fi
	done

	local new=()
	for a in "${binAfter[@]}"; do
		local found=0

		for b in "${_binBefore[@]}"; do
			if [[ "${a}" = "${b}" ]]; then
				((found += 1))
			fi
		done

		if [[ "${found}" -eq 0 ]]; then
			# shellcheck disable=SC2312
			new+=("./bin/$(basename "$(echo "${a}" | awk '{print $2}')")")
		fi
	done
	IFS=${_oifs}
	echo "${new[@]}"
}

knownFile() {
	local fileName="${1}"
	<"${FilesJSON}" jq -e 'to_entries | map(select(.key == "'"${fileName}"'")) | any' &>/dev/null
}

downloadFile() {
	local fileName="${1}"

	# shellcheck disable=SC2310
	if ! knownFile "${fileName}"; then
		output::error <<-EOF
			Error: The requested file (${fileName}) is unknown to the buildpack!

			The buildpack tracks and validates the SHA256 sums of the files
			it uses. Because the buildpack doesn't know about the file
			it likely won't be able to obtain a copy and validate the SHA.

			To find out more info about this error please visit:
			https://devcenter.heroku.com/articles/unknown-go-buildack-files
		EOF
		exit 1
	fi

	local targetDir="${2}"
	local xCmd="${3}"
	local targetFile="${targetDir}/${fileName}"

	mkdir -p "${targetDir}"
	pushd "${targetDir}" &>/dev/null || return 1
	output::step "Fetching ${fileName}"
	local url
	url="$(<"${FilesJSON}" jq -r '."'"${fileName}"'".URL')"
	# shellcheck disable=SC2312
	${CURL} -o "${fileName}" "${url}" 2>&1 | output::indent
	# shellcheck disable=SC2310
	if ! SHAValid "${fileName}" "${targetFile}"; then
		output::error <<-EOF
			Error: Downloaded file (${fileName}) SHA does not match recorded SHA.

			Unable to continue.
		EOF
		exit 1
	fi
	if [[ -n "${xCmd}" ]]; then
		# shellcheck disable=SC2312
		${xCmd} "${targetFile}" 2>&1 | output::indent
	fi
	popd &>/dev/null || return 1
}

SHAValid() {
	local fileName="${1}"
	local targetFile="${2}"
	local expected
	expected="$(<"${FilesJSON}" jq -r '."'"${fileName}"'".SHA')"
	local actual
	# shellcheck disable=SC2312
	actual="$(shasum -a256 "${targetFile}" | cut -d \  -f 1)"
	[[ "${actual}" = "${expected}" ]]
}

ensureFile() {
	local fileName="${1}"
	local targetDir="${2}"
	local xCmd="${3}"
	local targetFile="${targetDir}/${fileName}"
	local download="false"
	# shellcheck disable=SC2310
	if [[ ! -f "${targetFile}" ]]; then
		download="true"
	elif ! SHAValid "${fileName}" "${targetFile}"; then
		download="true"
	fi
	if [[ "${download}" = "true" ]]; then
		downloadFile "${fileName}" "${targetDir}" "${xCmd}"
	fi
}

addToPATH() {
	local targetDir="${1}"
	if echo "${PATH}" | grep -v "${targetDir}" &>/dev/null; then
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
	if [[ -n "${env_dir}" ]]; then
		mkdir -p "${env_dir}"
		env_dir=$(cd "${env_dir}/" && pwd)
		for key in "${envFlags[@]}"; do
			if [[ -f "${env_dir}/${key}" ]]; then
				export "${key}=$(sed -e "s:\${build_dir}:${build}:" <"${env_dir}/${key}")"
			fi
		done
	fi
}

clearGitCredHelper() {
	git config --global --unset credential.helper
}

# shellcheck disable=SC2016,SC2086,SC2250,SC2292,SC2002,SC2248,SC2312
setGitCredHelper() {
	git config --global credential.helper '!#GoGitCredHelper
    env_dir="'"$(cd "${1}"/ && pwd)"'"
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
	echo "\"${version}\"" | jq -e 'split(".") | map(gsub("go";"")) | map(tonumber) | .[0] >= 1 and .[1] < 11' &>/dev/null
}

determineTool() {
	# Check GOVERSION first - it overrides all tool-specific configurations
	if [[ -n "${GOVERSION}" ]]; then
		ver="${GOVERSION}"
		go_version_origin="GOVERSION"
		build_data::set_string "go_version_origin" "${go_version_origin}"
		build_data::set_string "go_version_requested" "${ver}"
	fi

	if [[ -f "${goMOD}" ]]; then
		TOOL="gomodules"
		build_data::set_string "go_tool" "${TOOL}"

		output::step "Detected go modules via go.mod"

		# Determine Go version from go.mod if not already set by GOVERSION
		if [[ -z "${ver}" ]]; then
			ver=$(awk '{ if ($1 == "//" && $2 == "+heroku" && $3 == "goVersion" ) { print $4; exit } }' "${goMOD}")
			if [[ -n "${ver}" ]]; then
				go_version_origin="go.mod (heroku comment)"
			else
				ver=$(awk '{ if ($1 == "go" ) { print "go" $2; exit } }' "${goMOD}")
				if [[ -n "${ver}" ]]; then
					go_version_origin="go.mod"
				else
					ver=${DefaultGoVersion}
					go_version_origin="default"
				fi
			fi
			build_data::set_string "go_version_origin" "${go_version_origin}"
			build_data::set_string "go_version_requested" "${ver}"
		fi

		name=$(awk '{ if ($1 == "module" ) { gsub(/"/, "", $2); print $2; exit } }' <"${goMOD}")
		output::step "Detected Module Name: ${name}"
		warnGoVersionOverride

		if [[ "${go_version_origin}" = "default" ]]; then
			output::warning <<-EOF
				The go.mod file for this project does not specify a Go version.

				Defaulting to ${ver}

				For more details see:
				https://devcenter.heroku.com/articles/go-apps-with-modules#build-configuration
			EOF
		fi

		# shellcheck disable=SC2310
		if supportsGoModules "${ver}"; then
			output::error <<-EOF
				Error: You are using ${ver}, which does not support Go modules.

				Go modules are supported by go1.11 and above.

				Please add/update the comment in your go.mod file to specify
				a Go version >= go1.11 like so:
				// +heroku goVersion ${DefaultGoVersion}

				Then commit and push again.
			EOF
			exit 1
		fi
	else
		local legacy_tool=""
		# shellcheck disable=SC2312
		if [[ -f "${build}/Gopkg.lock" ]]; then
			legacy_tool="dep"
		elif [[ -f "${build}/Godeps/Godeps.json" ]]; then
			legacy_tool="godep"
		elif [[ -f "${build}/vendor/vendor.json" ]]; then
			legacy_tool="govendor"
		elif [[ -f "${build}/glide.yaml" ]]; then
			legacy_tool="glide"
		elif [[ -d "${build}/src" ]] && [[ -n "$(find "${build}/src" -mindepth 2 -type f -name '*.go' | sed 1q)" ]]; then
			legacy_tool="gb"
		fi

		if [[ -n "${legacy_tool}" ]]; then
			build_data::set_string "go_tool" "${legacy_tool}"
			output::error <<-EOF
				Error: Your app appears to use '${legacy_tool}' for dependency management,
				but support for ${legacy_tool} has been removed.

				Go modules (go.mod) is now the only supported dependency
				management solution on Heroku.

				To migrate, run 'go mod init <module-name>' in your project
				directory and commit the resulting go.mod file.

				For more details see:
				https://devcenter.heroku.com/articles/go-modules
			EOF
		else
			output::error <<-EOF
				Error: A go.mod file is required.

				For help with using Go on Heroku, see:
				https://devcenter.heroku.com/articles/go-support
			EOF
		fi
		exit 1
	fi
}

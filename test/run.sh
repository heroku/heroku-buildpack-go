#!/usr/bin/env bash
# See README.md for info on running these tests.

testTestPackModulesVendoredGolangLintCI() {
	fixture "mod-deps-vendored-with-tests"

	dotest
	assertCapturedExitSuccess
	assertCaptured "RUN   Test_BasicTest"
	assertCaptured "PASS: Test_BasicTest"
	assertCaptured "/.golangci.{yml,toml,json} detected"
	assertCaptured "Running: golangci-lint -v --build-tags heroku run"
}

testTestPackModulesGolangLintCI() {
	fixture "mod-deps-with-tests"

	dotest
	assertCapturedExitSuccess

	# The other deps are downloaded/installed
	assertCaptured "
go: finding github.com/gorilla/mux v1.6.2
go: finding github.com/gorilla/context v1.1.1
go: downloading github.com/gorilla/mux v1.6.2
go: extracting github.com/gorilla/mux v1.6.2
github.com/gorilla/mux
"
	assertCaptured "RUN   Test_BasicTest"
	assertCaptured "PASS: Test_BasicTest"
	assertCaptured "/.golangci.{yml,toml,json} detected"
	assertCaptured "Running: golangci-lint -v --build-tags heroku run"
}

testTestPackModulesGolangLintCI116() {
	fixture "mod-deps-with-tests-116"

	dotest
	assertCapturedExitSuccess

	# The other deps are downloaded/installed
	assertCaptured "
go: finding github.com/gorilla/mux v1.6.2
go: finding github.com/gorilla/context v1.1.1
go: downloading github.com/gorilla/mux v1.6.2
go: extracting github.com/gorilla/mux v1.6.2
github.com/gorilla/mux
"
	assertCaptured "RUN   Test_BasicTest"
	assertCaptured "PASS: Test_BasicTest"
	assertCaptured "/.golangci.{yml,toml,json} detected"
	assertCaptured "Running: golangci-lint -v --build-tags heroku run"
}

testModProcfileCreation() {
	fixture "mod-cmd-web"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured "go1.12.17"
	assertCaptured "Running: go install -v -tags heroku github.com/heroku/fixture/cmd/web
github.com/heroku/fixture/cmd/other"

	assertCapturedExitSuccess
	assertFile "other: bin/other
web: bin/web" "Procfile"
}

testModDepsRecompile() {
	fixture "mod-deps"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	# The other deps are downloaded/installed
	assertCaptured "
go: finding github.com/gorilla/mux v1.6.2
go: finding github.com/gorilla/context v1.1.1
go: downloading github.com/gorilla/mux v1.6.2
go: extracting github.com/gorilla/mux v1.6.2
github.com/gorilla/mux
"
	assertCapturedExitSuccess
	assertInstalledFixtureBinary

	# Second compile
	compile
	assertModulesBoilerplateCaptured
	assertGoInstallOnlyFixturePackageCaptured

	# On the second compile go should already be fetched and installed & the packages should be downloaded already.
	assertNotCaptured "Fetching ${DEFAULT_GO_VERSION}"
	assertNotCaptured "Installing ${DEFAULT_GO_VERSION}"
	assertNotCaptured "go: finding github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: finding github.com/gorilla/context v1.1.1"
	assertNotCaptured "go: downloading github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: extracting github.com/gorilla/mux v1.6.2"

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModWithQuotesModule() {
	fixture "mod-with-quoted-module"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured "go1.12.17"
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
	assertFile "web: bin/fixture" "Procfile"
}

testModWithNonFilesInBin() {
	fixture "mod-with-non-files-in-bin"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	assertNotCaptured "go: finding github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: finding github.com/gorilla/context v1.1.1"
	assertNotCaptured "go: downloading github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: extracting github.com/gorilla/mux v1.6.2"

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModcmdDetection() {
	fixture "mod-cmd"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured "go1.12.17"
	assertCaptured "Detected the following main packages to install:
github.com/heroku/fixture/cmd/fixture
github.com/heroku/fixture/cmd/other"
	assertCaptured "Running: go install -v -tags heroku github.com/heroku/fixture/cmd/fixture github.com/heroku/fixture/cmd/other
github.com/heroku/fixture/cmd/fixture
github.com/heroku/fixture/cmd/other"

	assertCaptured "Installed the following binaries:
./bin/fixture
./bin/other"

	assertFile "fixture: bin/fixture
other: bin/other" "Procfile"

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
	assertCompiledBinaryExists other
}

testModWithHooks() {
	fixture "mod-basic-with-hooks"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured

	assertCaptured "Running bin/go-pre-compile hook
PRE COMPILE"

	assertGoInstallOnlyFixturePackageCaptured
	assertCaptured "Running bin/go-post-compile hook
POST COMPILE"

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModNoVersion() {
	fixture "mod-no-version"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertCapturedStderr "does not specify a Go version"
	assertInstalledFixtureBinary
}

testModOldVersion() {
	fixture "mod-old-version"

	assertDetected

	compile
	assertCaptured "Detected go modules via go.mod"
	assertCaptured "Detected Module Name: github.com/heroku/fixture"
	assertCapturedError 1 "a Go version >= go1.11 like so:"
}

testModInstall() {
	fixture "mod-install"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured

	assertCaptured "Running: go install -v -tags heroku ./cmd/... ./other
github.com/heroku/fixture/cmd/fixture1
github.com/heroku/fixture/cmd/fixture2
github.com/heroku/fixture/other"

	assertCaptured "Installed the following binaries:
./bin/fixture1
./bin/fixture2
./bin/other"

	assertCapturedExitSuccess
	assertCompiledBinaryExists "fixture1"
	assertCompiledBinaryExists "fixture2"
	assertCompiledBinaryExists "other"
}

testModBasic() {
	fixture "mod-basic"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModBasicGo111() {
	fixture "mod-basic-go111"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertCaptured "Installing go1.11.13"
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModBasicGo125() {
	fixture "mod-basic-go125"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertCaptured "Installing go1.25"
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModBasicGo126() {
	fixture "mod-basic-go126"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertCaptured "Installing go1.26"
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModBasicWithoutProcfile() {
	fixture "mod-basic-wo-procfile"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
	assertFile "web: bin/fixture" "Procfile"
}

testModPrivateProxy() {
	local repo="${BUILDPACK_HOME}/test/fixtures/mod-private-proxy/repo"
	fixture "mod-private-proxy/app"

	env "GOPROXY" "file://${repo}"
	env "GOPRIVATE" "git.fury.io/*"
	env "GONOPROXY" "none"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured "go1.15.15"
	assertGoInstallOnlyFixturePackageCaptured

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

# Regression test for #683: git >= 2.46 announces `capability[]=authtype` to
# credential helpers (and can follow with `state[]`) when it authenticates over
# HTTP. The helper installed by setGitCredHelper must ignore these the same way it
# already ignores `wwwauth[]`; before the fix it hit the catch-all `case` branch
# and died with "Unsupported key: capability[]=authtype" before ever returning
# credentials, breaking every private-repo fetch on stacks shipping git >= 2.46.
#
# We drive the installed helper directly — the same way git does: `sh -c "<body>
# get"` with the request attributes on stdin, each newline-terminated and closed
# with EOF. This exercises the exact parser that regressed, with a fixed input
# matching git's documented credential-helper protocol, rather than depending on
# `git credential fill` to relay a caller-injected capability (which the CLI path
# does not announce on its own, so such a test could silently stop reproducing).
testGitCredHelperIgnoresCapabilityAttributes() {
	echo "fake-token" >"${ENV_DIR}/GO_GIT_CRED__HTTPS__GITHUB__COM"

	# Run in a subprocess with an isolated HOME: common.sh enables `set -euo
	# pipefail` at source time and setGitCredHelper installs the helper via `git
	# config --global`, neither of which should leak into the test runner or other
	# tests. `command env` bypasses the `env` test helper defined in test/utils.sh.
	# shellcheck disable=SC2016 # the single-quoted body is expanded by the inner bash, not here
	capture command env \
		BUILDPACK_DIR="${BUILDPACK_HOME}" \
		BUILD_DIR="${BUILD_DIR}" \
		ENV_DIR="${ENV_DIR}" \
		HOME="${OUTPUT_DIR}/githome" \
		bash -c '
			set -euo pipefail
			mkdir -p "${HOME}"
			# shellcheck disable=SC1091
			source "${BUILDPACK_DIR}/lib/common.sh"
			setGitCredHelper "${ENV_DIR}"
			# git stores a shell helper prefixed with "!" and invokes it as
			# `sh -c "<body> <operation>"`; strip the "!" and do the same.
			helper="$(git config --global credential.helper)"
			printf "capability[]=authtype\nprotocol=https\nhost=github.com\nstate[]=helper:0\n" \
				| sh -c "${helper#!} get"
		'

	assertCapturedExitSuccess
	assertCaptured "username=fake-token"
	assertCaptured "password=fake-token"
	assertCapturedStderr "Using credentials from GO_GIT_CRED__HTTPS__GITHUB__COM"
	assertFileNotContains "Unsupported key" "${STD_ERR}"
}

testModDeps() {
	fixture "mod-deps"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	# The other deps are downloaded/installed
	assertCaptured "
go: finding github.com/gorilla/mux v1.6.2
go: finding github.com/gorilla/context v1.1.1
go: downloading github.com/gorilla/mux v1.6.2
go: extracting github.com/gorilla/mux v1.6.2
github.com/gorilla/mux
"
	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

# Ensure that a project works when:
#
# * no vendor directory is present
# * Go release of 1.14 or greater is used (eg `// +heroku goVersion 1.14` in go.mod)
# * Go language version of 1.14 or greater is used (eg `go 1.14` in go.mod)
#
# The use of language version 1.14 or greater in particular
# activates new consistency checks between go.mod and the vendor
# directory, described at https://golang.org/doc/go1.14#vendor.
testModDeps114() {
	fixture "mod-deps-114"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertCaptured "Installing go1.14.2"
	assertGoInstallOnlyFixturePackageCaptured

	# The other deps are downloaded/installed
	assertCaptured "
go: finding github.com/gorilla/mux v1.6.2
go: finding github.com/gorilla/context v1.1.1
go: downloading github.com/gorilla/mux v1.6.2
go: extracting github.com/gorilla/mux v1.6.2
github.com/gorilla/mux
"
	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModDepsVendored() {
	fixture "mod-deps-vendored"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured

	assertNotCaptured "go: finding github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: finding github.com/gorilla/context v1.1.1"
	assertNotCaptured "go: downloading github.com/gorilla/mux v1.6.2"
	assertNotCaptured "go: extracting github.com/gorilla/mux v1.6.2"

	assertCapturedExitSuccess
	assertInstalledFixtureBinary
}

testModPackageSpecOverride() {
	fixture "mod-cmd"

	env "GO_INSTALL_PACKAGE_SPEC" "./cmd/fixture"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured "go1.12.17"
	assertCapturedStderr "Using \$GO_INSTALL_PACKAGE_SPEC override."
	assertCaptured "Running: go install -v -tags heroku ./cmd/fixture"
	assertCapturedExitSuccess
	assertCompiledBinaryExists "fixture"
	assertBuildDirFileDoesNotExist "bin/other"
}

testModGOVERSIONOverride() {
	fixture "mod-basic"

	env "GOVERSION" "go1.24"

	assertDetected

	compile
	assertCaptured "Installing go1.24"
	assertCapturedStderr "Using \$GOVERSION override."
	assertGoInstallOnlyFixturePackageCaptured
	assertCapturedExitSuccess
	assertCompiledBinaryExists
}

testModBinFile() {
	fixture "mod-bin-file"

	assertDetected

	compile
	assertCapturedError 1 "File bin exists and is not a directory."
}

testModLDSymbolValue() {
	fixture "mod-ld-symbol-value"

	env "GO_LINKER_SYMBOL" "main.fixture"
	env "GO_LINKER_VALUE" "fixture"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertCaptured "Running: go install -v -tags heroku -ldflags -X main.fixture=fixture"
	assertCaptured "github.com/heroku/fixture"
	assertCapturedExitSuccess
	assertCompiledBinaryExists
	assertCompiledBinaryOutputs "fixture" "fixture"
}

testModBasicWithTools() {
	fixture "mod-basic"

	env "GO_INSTALL_TOOLS_IN_IMAGE" "true"

	assertDetected

	compile
	assertModulesBoilerplateCaptured
	assertGoInstallCaptured
	assertGoInstallOnlyFixturePackageCaptured
	assertCaptured "Copying go tool chain to"
	assertCapturedExitSuccess
	assertCompiledBinaryExists
	assertBuildDirFileExists ".heroku/go/bin/go"
}

testDeprecatedToolDetected() {
	fixture "dep-deprecated"

	assertDetected

	compile
	assertCapturedError 1 "support for dep has been removed"
}

BUILDPACK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "${BUILDPACK_DIR}/test/utils.sh"
# shellcheck disable=SC1091
source "${BUILDPACK_DIR}/test/shunit2.sh"

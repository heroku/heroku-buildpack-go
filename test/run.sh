#!/usr/bin/env bash
# See README.md for info on running these tests.

testTestPackModulesVendoredGolangLintCI() {
  fixture "mod-deps-vendored-with-tests"

  dotest
  assertCapturedSuccess
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

  assertCapturedSuccess
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
  assertNotCaptured "Fetching ${DEFAULT_GO_VERSION}.linux-amd64.tar.gz... done"
  assertNotCaptured "Installing ${DEFAULT_GO_VERSION}"
  assertNotCaptured "go: finding github.com/gorilla/mux v1.6.2"
  assertNotCaptured "go: finding github.com/gorilla/context v1.1.1"
  assertNotCaptured "go: downloading github.com/gorilla/mux v1.6.2"
  assertNotCaptured "go: extracting github.com/gorilla/mux v1.6.2"

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModWithQuotesModule() {
  fixture "mod-with-quoted-module"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertGoInstallCaptured "go1.12.17"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
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

  assertCapturedSuccess
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

  assertCapturedSuccess
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

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModNoVersion() {
  fixture "mod-no-version"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertGoInstallCaptured
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModOldVersion() {
  fixture "mod-old-version"

  assertDetected

  compile
  assertCaptured "Detected go modules via go.mod"
  assertCaptured "Detected Module Name: github.com/heroku/fixture"
  assertCapturedError 1 "Please add/update the comment in your go.mod file to specify a Go version >= go1.11 like so:"
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

  assertCapturedSuccess
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

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo115() {
  fixture "mod-basic-go115"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.15"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo116() {
  fixture "mod-basic-go116"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.16"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo117() {
  fixture "mod-basic-go117"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.17"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo118() {
  fixture "mod-basic-go118"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.18"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo119() {
  fixture "mod-basic-go119"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.19"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo120() {
  fixture "mod-basic-go120"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.20"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo121() {
  fixture "mod-basic-go121"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.21"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo122() {
  fixture "mod-basic-go122"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.22"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo123() {
  fixture "mod-basic-go123"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.23"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo124() {
  fixture "mod-basic-go124"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.24"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo125() {
  fixture "mod-basic-go125"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.25"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicGo126() {
  fixture "mod-basic-go126"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertCaptured "Installing go1.26"
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModBasicWithoutProcfile() {
  fixture "mod-basic-wo-procfile"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertGoInstallCaptured
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
  assertFile "web: bin/fixture" "Procfile"
}

testModPrivateProxy() {
  local repo="${BUILDPACK_HOME}/test/fixtures/mod-private-proxy/repo"
  fixture "mod-private-proxy/app"

  env "GOPROXY" "file://$repo"
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

  assertCapturedSuccess
  assertInstalledFixtureBinary
}

testModPackageSpecOverride() {
  fixture "mod-cmd"

  env "GO_INSTALL_PACKAGE_SPEC" "./cmd/fixture"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertGoInstallCaptured "go1.12.17"
  assertCaptured "Using \$GO_INSTALL_PACKAGE_SPEC override."
  assertCaptured "Running: go install -v -tags heroku ./cmd/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists "fixture"
  assertBuildDirFileDoesNotExist "bin/other"
}

testModGOVERSIONOverride() {
  fixture "mod-basic"

  env "GOVERSION" "go1.24"

  assertDetected

  compile
  assertCaptured "Installing go1.24"
  assertCaptured "Using \$GOVERSION override."
  assertGoInstallOnlyFixturePackageCaptured
  assertCapturedSuccess
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
  assertCapturedSuccess
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
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists ".heroku/go/bin/go"
}

pushd $(dirname 0) >/dev/null
popd >/dev/null

source $(pwd)/test/utils.sh
source $(pwd)/test/shunit2.sh

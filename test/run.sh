#!/usr/bin/env bash
# See README.md for info on running these tests.

testModWithBZRDep() {
  if [ "${IMAGE}" = "heroku/cedar:14" ]; then
    echo "!!!"
    echo "!!! Skipping this test on heroku/cedar:14"
    echo "!!! (image doesn't contain bzr)"
    echo "!!!"
    return 0
  fi
  fixture "mod-with-bzr-dep"

  assertDetected

  compile
  assertModulesBoilerplateCaptured
  assertGoInstallCaptured
  assertGoInstallOnlyFixturePackageCaptured

  assertCapturedSuccess
  assertInstalledFixtureBinary
  assertFile "web: bin/fixture" "Procfile"
}

testTestPackModulesVendoredGolangLintCI() {
  fixture "mod-deps-vendored-with-tests"

  assertDetected

  compile
  dotest
  assertCapturedSuccess
  assertCaptured "RUN   Test_BasicTest"
  assertCaptured "PASS: Test_BasicTest"
  assertCaptured "/.golangci.{yml,toml,json} detected"
  assertCaptured "Running: golangci-lint -v --build-tags heroku run"
}

testTestPackModulesGolangLintCI() {
  fixture "mod-deps-with-tests"

  assertDetected

  compile
  dotest
  assertCapturedSuccess

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
  assertGoInstallCaptured
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
  assertCapturedSuccess
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
  assertGoInstallCaptured
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
  assertGoInstallCaptured
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

testDepWithGolangMigrate() {
  fixture "dep-golang-migrate"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "Installing github.com/golang-migrate/migrate"
  assertCaptured "Fetching migrate"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryExists "migrate"
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
  assertCapturedSuccess
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
  assertCapturedSuccess
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

testGovendorWithPrivateDepsGithub() {
  if [ -z "${GITHUB_TOKEN}" ]; then
    echo "!!!"
    echo "!!! Skipping private Github repo test"
    echo "!!!"
    return 0
  fi

  fixture "govendor-private-github"

  env "GO_GIT_CRED__HTTPS__GITHUB__COM" "${GITHUB_TOKEN}"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "github.com/go-test-user/go-private-repo-test"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "This is in a string from a Private Repo"
}

testGovendorWithPrivateDepsGitlab() {
  if [ -z "${GITLAB_TOKEN}" ]; then
    echo "!!!"
    echo "!!! Skipping private Gitlab repo test"
    echo "!!!"
    return 0
  fi

  fixture "govendor-private-gitlab"

  env "GO_GIT_CRED__HTTPS__GITLAB__COM" "${GITLAB_TOKEN}"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "gitlab.com/freeformz/private-go-test"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "This is in a string from a Private Repo"
}

testDepWithMattesMigrate() {
  fixture "dep-mattes-migrate"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "Installing github.com/mattes/migrate"
  assertCaptured "Fetching migrate"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryExists "migrate"
}

testDepWithDepsPruned() {
  fixture "dep-with-dep-pruned"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/x/scrub"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testDepWithDep() {
  fixture "dep-with-dep"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/x/scrub"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testDepNoEnsure() {
  fixture "dep-no-ensure"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertNotCaptured "Fetching dep"
  assertNotCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testDepInstallMulti() {
  fixture "dep-install-multi"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture/a"
  assertCaptured "github.com/heroku/fixture/b"
  assertCapturedSuccess
  assertCompiledBinaryExists "a"
  assertCompiledBinaryOutputs "a" "a"
  assertCompiledBinaryExists "b"
  assertCompiledBinaryOutputs "b" "b"
}

testDepNakedGoVersion() {
  fixture "dep-naked-go-version"

  assertDetected

  compile
  assertCaptured "Installing go1.8.3"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testDepGoVersion() {
  fixture "dep-go-version"

  assertDetected

  compile
  assertCaptured "Installing go1.8.3"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testDepNoDeps() {
  fixture "dep-no-deps"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGovendorMattesMigrateCLI() {
  fixture "govendor-mattes-migrate"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Fetching govendor"
  assertCaptured "Fetching any unsaved dependencies (govendor sync)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing github.com/mattes/migrate"
  assertCaptured "Fetching migrate"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "fixture" "hello"
  assertCompiledBinaryExists "migrate"
}

testTestPackGovendorWithTestsSkipBenchmark() {
  fixture "govendor-with-tests"

  env "GO_TEST_SKIP_BENCHMARK" "nope"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertNotCaptured "BenchmarkHello"
}

testTestPackGlideWithTestsSkipBenchmark() {
  fixture "glide-with-tests"

  env "GO_TEST_SKIP_BENCHMARK" "nope"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertNotCaptured "BenchmarkHello"
}

testTestPackGodepWithTestsSkipBenchmark() {
  fixture "godep-with-tests"

  env "GO_TEST_SKIP_BENCHMARK" "nope"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertNotCaptured "BenchmarkHello"
}

testTestPackGBWithTestsSkipBenchmark() {
  fixture "gb-with-tests"

  env "GO_TEST_SKIP_BENCHMARK" "nope"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertNotCaptured "BenchmarkHello"
}

testTestPackGovendorWithTests() {
  fixture "govendor-with-tests"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertCaptured "BenchmarkHello"
}

testTestPackGlideWithTests() {
  fixture "glide-with-tests"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertCaptured "BenchmarkHello"
}

testTestPackGodepWithTests() {
  fixture "godep-with-tests"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertCaptured "BenchmarkHello"
}

testTestPackGBWithTests() {
  fixture "gb-with-tests"

  dotest
  assertCapturedSuccess
  assertCaptured "RUN   TestHello"
  assertCaptured "PASS: TestHello"
  assertCaptured "RUN   ExampleHello"
  assertCaptured "PASS: ExampleHello"
  assertCaptured "BenchmarkHello"
}

testGlideWithHgDep() {
    if [ "${IMAGE}" = "heroku/cedar:14" ]; then
    echo "!!!"
    echo "!!! Skipping this test on heroku/cedar:14"
    echo "!!! See: https://www.mercurial-scm.org/wiki/SecureConnections (3.1)"
    echo "!!!"
    return 0
  fi

  fixture "glide-with-hg-dep"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "github.com/heroku/fixture/vendor/bitbucket.org/pkg/inflect"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGovendorCmds() {
  fixture "govendor-cmd"

  assertDetected

  compile
  assertCapturedSuccess
  assertCompiledBinaryExists "fixture"
  assertCompiledBinaryOutputs "fixture" "fixture"
  assertCompiledBinaryExists "other"
  assertCompiledBinaryOutputs "other" "other"
}

testGovendorCmdsOverride() {
  fixture "govendor-cmd"

  env "GO_INSTALL_PACKAGE_SPEC" "./cmd/fixture"

  assertDetected

  compile
  assertCapturedSuccess
  assertCaptured "Using \$GO_INSTALL_PACKAGE_SPEC override."
  assertCompiledBinaryExists "fixture"
  assertCompiledBinaryOutputs "fixture" "fixture"
  assertBuildDirFileDoesNotExist "bin/other"
}

testGodepCmds() {
  fixture "godep-cmd"

  assertDetected

  compile
  assertCapturedSuccess
  assertCompiledBinaryExists "fixture"
  assertCompiledBinaryOutputs "fixture" "fixture"
  assertCompiledBinaryExists "other"
  assertCompiledBinaryOutputs "other" "other"
}

testGodepCmdsOverride() {
  fixture "godep-cmd"

  env "GO_INSTALL_PACKAGE_SPEC" "./cmd/fixture"

  assertDetected

  compile
  assertCompiledBinaryExists "fixture"
  assertCompiledBinaryOutputs "fixture" "fixture"
  assertBuildDirFileDoesNotExist "bin/other"
}

testGodepBasicGo14WithGOVERSIONOverride() {
  fixture "godep-basic-go14"

  env "GOVERSION" "go1.6"

  assertDetected

  compile
  assertCaptured "Installing go1.6"
  assertCaptured "Using \$GOVERSION override."
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileDoesNotExist ".profile.d/concurrency.sh"
}

testGovendorGo14WithGOVERSIONOverride() {
  fixture "govendor-go15"

  env "GOVERSION" "go1.6"

  assertDetected

  compile
  assertCaptured "Installing go1.6"
  assertCaptured "Using \$GOVERSION override."
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGlideMassageVendor() {
  fixture "glide-massage-vendor"

  env "GO_INSTALL_PACKAGE_SPEC" ". github.com/mattes/migrate"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku . github.com/heroku/fixture/vendor/github.com/mattes/migrate"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/fatih/color/vendor/github.com/mattn/go-colorable"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/fatih/color/vendor/github.com/mattn/go-isatty"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/fatih/color"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/migrate/direction"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/file"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/bash"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/gocql/gocql/internal/lru"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/golang/snappy"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/hailocab/go-hostpool"
  assertCaptured "github.com/heroku/fixture/vendor/gopkg.in/inf.v0"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/go-sql-driver/mysql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/gocql/gocql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/mysql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/lib/pq/oid"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/lib/pq"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/cassandra"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/postgres"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattn/go-sqlite3"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/pipe"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/sqlite3"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/migrate"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryExists "migrate"
}

testGlideWithOutDeps() {
  fixture "glide-wo-deps"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGlideWithDeps() {
  fixture "glide-with-deps"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGlideBasic() {
  fixture "glide-basic"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGlideBasicWithTools() {
  fixture "glide-basic"

  env "GO_INSTALL_TOOLS_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists ".heroku/go/bin/go"
}

testGlideBasicInGOPATH() {
  fixture "glide-basic"

  env "GO_SETUP_GOPATH_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing glide"
  assertCaptured "Fetching any unsaved dependencies (glide install)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists "src/github.com/heroku/fixture/main.go"
  assertBuildDirFileDoesNotExist "main.go"
}

testGodepVendorGo17() {
  fixture "godep-vendor-go17"

  assertDetected

  compile
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepBasicGo17() {
  fixture "godep-basic-go17"

  assertDetected

  compile
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileDoesNotExist ".profile.d/concurrency.sh"
  assertCompiledBinaryOutputs "fixture" "go1.7beta1"
}

testGodepBasicGo17WithGO15VENDOREXPERIMENT() {
  fixture "godep-basic-go17"

  env "GO15VENDOREXPERIMENT" "1"

  assertDetected

  compile
  assertCaptured "GO15VENDOREXPERIMENT is set, but is not supported by go"
  assertCaptured "run \`heroku config:unset GO15VENDOREXPERIMENT\` to unset."
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGovendorExcluded() {
  fixture "govendor-excluded"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Fetching govendor"
  assertCaptured "Installing package '.' (default)"
  assertCaptured "Fetching any unsaved dependencies (govendor sync)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture/vendor/github.com/heroku/slog"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepBasicGo14() {
  fixture "godep-basic-go14"

  assertDetected

  compile
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists ".profile.d/concurrency.sh"
}

testGodepCGOVendored(){
  fixture "godep-cgo-vendored"

  env "CGO_CFLAGS" '-I${build_dir}/vendor/include'
  env "CGO_LDFLAGS" '-L${build_dir}/vendor/lib -lyara'

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture/vendor/github.com/hillu/go-yara"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepMassageVendor() {
  fixture "godep-massage-vendor"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku . github.com/heroku/fixture/vendor/github.com/mattes/migrate"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattn/go-isatty"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/shiena/ansicolor"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/fatih/color"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/migrate/direction"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/file"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/bash"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/gocql/gocql/lru"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/golang/snappy"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/hailocab/go-hostpool"
  assertCaptured "github.com/heroku/fixture/vendor/gopkg.in/inf.v0"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/go-sql-driver/mysql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/gocql/gocql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/mysql"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/lib/pq/oid"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/lib/pq"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/cassandra"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/postgres"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattn/go-sqlite3"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/pipe"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver/sqlite3"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/driver"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate/migrate"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/mattes/migrate"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryExists "migrate"
}

testGodepWithPackageNames() {
  fixture "godep-with-package-names"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertNotCaptured "Installing package '.' (default)"
  assertCaptured "Running: go install -v -tags heroku github.com/heroku/fixture/pkg"
  assertCaptured "github.com/heroku/fixture/vendor/github.com/heroku/slog"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists "pkg"
}

testGodepCGOBasic() {
  fixture "godep-cgo-basic"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing package '.' (default)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepDevelGo() {
  fixture "godep-devel-go"

  assertDetected

  compile
  assertCaptured "You are using a development build of Go."
  assertCaptured "Installing bootstrap go"
  assertCaptured "Downloading development Go version devel-15f7a66"
  assertCaptured "Compiling development Go version devel-15f7a66"
  assertCaptured "Installed Go for linux/amd64"
  assertCaptured "go version devel +15f7a66"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "fixture" "devel +15fa66"
  #assertTrue "Binary has the right value" '[[ "$(${BUILD_DIR}/bin/fixture)" = *"devel +15f7a66"* ]]'
}

testGodepBinFile() {
  fixture "godep-bin-file"

  assertDetected

  compile
  assertCapturedError 1 "File bin exists and is not a directory."
}

testGovendorMissingRootPath() {
  fixture "govendor-missing-rootPath"

  assertDetected

  compile
  assertCapturedError 1 "The 'rootPath' field is not specified in 'vendor/vendor.json'."
}

testGovendorMalformed() {
  fixture "govendor-malformed"

  assertDetected

  compile
  assertCapturedError 1 "Bad vendor/vendor.json file"
}

testGodepMalformed() {
  fixture "godep-malformed"

  assertDetected

  compile
  assertCapturedError 1 "Bad Godeps/Godeps.json file"
}

testGBVendor() {
  fixture "gb-vendor"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing GB"
  assertCaptured "Running: gb build -tags heroku"
  assertCaptured "cmd/fixture"
  assertCaptured "Post Compile Cleanup"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGBBasic() {
  fixture "gb-basic"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing GB"
  assertCaptured "Running: gb build -tags heroku"
  assertCaptured "cmd/fixture"
  assertCaptured "Post Compile Cleanup"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGBBasicWithTools() {
  fixture "gb-basic"

  env "GO_INSTALL_TOOLS_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCaptured "Installing GB"
  assertCaptured "Running: gb build -tags heroku"
  assertCaptured "cmd/fixture"
  assertCaptured "Post Compile Cleanup"
  assertCaptured "Copying go tool chain to"
  assertCaptured "Copying gb binary"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists ".heroku/go/bin/go"
}

testGodepLDSymbolValue() {
  fixture "godep-ld-symbol-value"

  env "GO_LINKER_SYMBOL" "main.fixture"
  env "GO_LINKER_VALUE" "fixture"

  assertDetected

  compile
  assertCaptured "Running: go install -v -tags heroku -ldflags -X main.fixture=fixture ."
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "fixture" "fixture"
#  assertTrue "Binary has the right value" '[ "$(${compile_dir}/bin/fixture)" = "fixture" ]'
}

# # Older versions of Go have a different format for specifying linked flags
testGodepLDSymbolGo14Value() {
  fixture "godep-ld-symbol-value-go14"

  env "GO_LINKER_SYMBOL" "main.fixture"
  env "GO_LINKER_VALUE" "fixture"

  assertDetected

  compile
  assertCaptured "Running: go install -v -tags heroku -ldflags -X main.fixture fixture ." #Nothing vendored
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertCompiledBinaryOutputs "fixture" "fixture"
  #assertTrue "Binary has the right value" '[ "$(${compile_dir}/bin/fixture)" = "fixture" ]'
}

testGodepBasic() {
  fixture "godep-basic"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileDoesNotExist ".profile.d/concurrency.sh"
}

testGodepBasicWithTools() {
  fixture "godep-basic"

  env "GO_INSTALL_TOOLS_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "Copying go tool chain to"
  assertNotCaptured "Copying godep binary" #We don't copy the binary when a workspace isn't present
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileDoesNotExist ".profile.d/concurrency.sh"
  assertBuildDirFileExists ".heroku/go/bin/go"
}

testGodepBasicInGOPATH() {
  fixture "godep-basic"

  env "GO_SETUP_GOPATH_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileDoesNotExist ".profile.d/concurrency.sh"
  assertBuildDirFileExists "src/github.com/heroku/fixture/main.go"
  assertBuildDirFileDoesNotExist "main.go"
}

testGodepCreateProcfile() {
  fixture "godep-basic-wo-procfile"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertFile "web: fixture" "Procfile"
}

testGovendorBasic() {
  fixture "govendor-basic"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGovendorBasicWithTools() {
  fixture "govendor-basic"

  env "GO_INSTALL_TOOLS_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCaptured "Copying go tool chain to"
  assertCaptured "Copying govendor binary"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists ".heroku/go/bin/go"
}

testGovendorBasicInGOPATH() {
  fixture "govendor-basic"

  env "GO_SETUP_GOPATH_IN_IMAGE" "true"

  assertDetected

  compile
  assertCaptured "Checking vendor/vendor.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertBuildDirFileExists "src/github.com/heroku/fixture/main.go"
  assertBuildDirFileDoesNotExist "main.go"
}

testGovendorCreateProcfile() {
  fixture "govendor-basic-wo-procfile"

  assertDetected

  compile
  assertCaptured "Installing go"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertFile "web: fixture" "Procfile"
}

testGodepOldWorkspace() {
  fixture "godep-old-workspace"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: godep go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepVendor() {
  fixture "godep-vendor"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGodepPackageSpec() {
  fixture "godep-package-spec"

  assertDetected

  compile
  assertCaptured "Checking Godeps/Godeps.json file."
  assertCaptured "Installing go"
  assertCaptured "Running: go install -v -tags heroku ./cmd/..."
  assertNotCaptured "Installing package '.' (default)"
  assertCaptured "github.com/heroku/fixture/cmd/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
}

testGoCacheGoVersionGreaterThanOrEqualTo110() {
  local cache_dir="${CACHE_DIR}/go-build-cache"

  fixture "dep-go-1-10"

  assertDetected
  assertDirDoesNotExist $cache_dir

  compile
  assertCaptured "Installing go1.10"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertDirExists "${cache_dir}"
  assertFileExists "${cache_dir}/README"
}

testGoCacheGoVersionLessThan110() {
  local cache_dir="${CACHE_DIR}/go-build-cache"

  fixture "dep-go-version"

  assertDetected
  assertDirDoesNotExist $cache_dir

  compile
  assertCaptured "Installing go1.8.3"
  assertCaptured "Fetching dep"
  assertCaptured "Fetching any unsaved dependencies (dep ensure)"
  assertCaptured "Running: go install -v -tags heroku ."
  assertCaptured "github.com/heroku/fixture"
  assertCapturedSuccess
  assertCompiledBinaryExists
  assertDirDoesNotExist "${cache_dir}"
}

pushd $(dirname 0) >/dev/null
popd >/dev/null

source $(pwd)/test/utils.sh
source $(pwd)/test/shunit2.sh

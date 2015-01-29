#!/bin/sh
. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

_createSimpleGoMain()
{
  cat > ${BUILD_DIR}/main.go <<EOF
package main

func main() {
	println("ok")
}
EOF
}

_createGodirProject()
{
_createSimpleGoMain

  cat > ${BUILD_DIR}/.godir <<EOF
test
EOF
}

_createGodepsProject()
{
_createSimpleGoMain

  mkdir -p ${BUILD_DIR}/Godeps
  cat > ${BUILD_DIR}/Godeps/Godeps.json <<EOF
{
	"ImportPath": "mytest",
	"GoVersion": "go1.1",
	"Deps": []
}
EOF
}

testCompileGodepsApp() {
  _createGodepsProject

  compile

  assertCapturedSuccess

  assertCaptured "should install GoVersion from Godeps.json" "-----> Installing go1.1... done"
  assertCaptured "should run godep go install" "-----> Running: godep go install -tags heroku ./..."

  assertTrue "mytest exists" "[ -f ${BUILD_DIR}/bin/mytest ]"
  assertTrue "mytest is executable" "[ -x ${BUILD_DIR}/bin/mytest ]"

  assertEquals "running mytest should print 'ok'" "ok" "$(${BUILD_DIR}/bin/mytest 2>&1)"
}

testCompileGodirApp() {
  _createGodirProject

  compile

  assertCapturedSuccess
  assertCaptured "should install default Go version" "-----> Installing go1.4.1... done"
  assertCaptured "should recommend godep" "Try github.com/kr/godep for faster deploys."
  assertCaptured "should install Virtualenv" "Installing Virtualenv... done"
  assertCaptured "should install Mercurial" "Installing Mercurial... done"
  assertCaptured "should install Bazaar" "Installing Bazaar... done"
  assertCaptured "should run go get" "-----> Running: go get -tags heroku ./..."
}

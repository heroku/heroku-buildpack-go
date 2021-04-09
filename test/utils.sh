##############
## shunit2 setup/teardown functions
##

oneTimeSetUp() {
   TEST_SUITE_CACHE="$(mktemp -d ${SHUNIT_TMPDIR}/test_suite_cache.XXXX)"
   BUILDPACK_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
   # jq isn't in the docker image, so need to do this the hard way
   DEFAULT_GO_VERSION=$(head < $BUILDPACK_HOME/data.json | grep DefaultVersion | cut -d : -f 2 | cut -d , -f 1 | sed -e s:\"::g -e s:\ ::g)
   export GO_BUCKET_URL="file://${BUILDPACK_HOME}/test/assets"
}

oneTimeTearDown() {
  rm -rf ${TEST_SUITE_CACHE}
}

setUp() {
  OUTPUT_DIR="$(mktemp -d ${SHUNIT_TMPDIR}/output.XXXX)"
  STD_OUT="${OUTPUT_DIR}/stdout"
  STD_ERR="${OUTPUT_DIR}/stderr"
  BUILD_DIR="${OUTPUT_DIR}/build"
  CACHE_DIR="${OUTPUT_DIR}/cache"
  ENV_DIR="${OUTPUT_DIR}/env"
  mkdir -p ${OUTPUT_DIR}
  mkdir -p ${BUILD_DIR}
  mkdir -p ${CACHE_DIR}
  mkdir -p ${ENV_DIR}

}

tearDown() {
  rm -rf ${OUTPUT_DIR}
}

##############
## Helpers
##

capture() {
  resetCapture

  LAST_COMMAND="$@"

  $@ >${STD_OUT} 2>${STD_ERR}
  RETURN=$?
  rtrn=${RETURN} # deprecated
}

continue_capture() {
  LAST_COMMAND="$@"

  $@ >>${STD_OUT} 2>>${STD_ERR}
  local cr=$?
  if [ "$RETURN" = "0" ]; then
    RETURN=$cr
  fi
  rtrn=${RETURN} # deprecated
}

resetCapture() {
  if [ -f ${STD_OUT} ]; then
    rm ${STD_OUT}
  fi

  if [ -f "${STD_OUT}_no_color" ]; then
    rm "${STD_OUT}_no_color"
  fi

  if [ -f ${STD_ERR} ]; then
    rm ${STD_ERR}
  fi

  unset LAST_COMMAND
  unset RETURN
  unset rtrn # deprecated
}

fixture() {
  local fixture="${1}"
  echo "* fixture: ${fixture}"
  local fp="${BUILDPACK_HOME}/test/fixtures/${fixture}"
  tar -cf - -C $fp . | tar -x -C ${BUILD_DIR}
}

env() {
  local var="${1}"
  local val="${2}"
  if [ -z "${var}" ]; then
    fail "set env var w/o specifying name"
    exit 1
  fi
  echo -n "${val}" > "${ENV_DIR}/${var}"
}

detect() {
  echo "* detect"
  capture ${BUILDPACK_HOME}/bin/detect ${BUILD_DIR}
}

assertDetected() {
  detect
  assertCaptured "Go"
  assertCapturedSuccess
}

compile() {
  echo "* compile"
  capture ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR} ${ENV_DIR}
}

dotest() {
  # On Heroku CI, test-compile and test are run in such a way that the
  # provided BUILD_DIR is the same as HOME. Simulate that here to get
  # better fidelity. For example, this ensures that the default GOPATH of
  # $HOME/go doesn't cause issues.
  echo "* test-compile"
  HOME="${BUILD_DIR}" capture "${BUILDPACK_HOME}/bin/test-compile" "${BUILD_DIR}" "${CACHE_DIR}" "${ENV_DIR}"
  echo "* test"
  HOME="${BUILD_DIR}" continue_capture "${BUILDPACK_HOME}/bin/test" "${BUILD_DIR}" "${ENV_DIR}"
}

release() {
  capture ${BUILDPACK_HOME}/bin/release ${BUILD_DIR}
}

assertFile() {
  local content="${1}"
  local name="${2}"
  local tgt="${BUILD_DIR}/${name}"
  assertEquals "${content}" "$(cat ${tgt})"
}

assertBuildDirFileDoesNotExist() {
  local name="${1}"
  local tgt="${BUILD_DIR}/${name}"
  assertTrue "File ${name} exists" "[ ! -f ${tgt} ]"
}

assertBuildDirFileExists() {
  local name="${1}"
  local tgt="${BUILD_DIR}/${name}"
  assertTrue "File ${name} does not exist" "[ -f ${tgt} ]"
}

assertFileExists() {
  local name="${1}"
  assertTrue "File ${name} does not exist" "[ -f ${name} ]"
}

assertDirExists() {
  local path="${1}"
  assertTrue "Dir ${path} does not exist" "[ -d ${path} ]"
}

assertDirDoesNotExist() {
  local path="${1}"
  assertTrue "Dir ${path} exists" "[ ! -d ${path} ]"
}

assertCompiledBinaryExists() {
  local name="${1:-fixture}"
  local tgt="${BUILD_DIR}/bin/${name}"
  assertTrue "Compiled binary (${tgt}) exists" "[ -x ${tgt} ]"
}

assertCompiledBinaryOutputs() {
  local name="${1}"
  local output="${2}"
  capture "${BUILD_DIR}/bin/${name}"
}

assertCapturedEquals() {
  assertEquals "$@" "$(cat ${STD_OUT})"
}

assertCapturedNotEquals() {
  assertNotEquals "$@" "$(cat ${STD_OUT})"
}

assertCaptured() {
  assertFileContains "$@" "${STD_OUT}"
}

assertNotCaptured() {
  assertFileNotContains "$@" "${STD_OUT}"
}

assertCapturedSuccess() {
  assertEquals "Expected captured exit code to be 0; was <${RETURN}>" "0" "${RETURN}"
  assertEquals "Expected STD_ERR to be empty; was <$(cat ${STD_ERR})>" "" "$(cat ${STD_ERR})"
}

# assertCapturedError [[expectedErrorCode] expectedErrorMsg]
assertCapturedError() {
  if [ $# -gt 1 ]; then
    local expectedErrorCode="${1}"
    shift
  fi

  local expectedErrorMsg="${1:-""}"

  if [ -z ${expectedErrorCode} ]; then
    assertTrue "Expected captured exit code to be greater than 0; was <${RETURN}>" "[ ${RETURN} -gt 0 ]"
  else
    assertTrue "Expected captured exit code to be <${expectedErrorCode}>; was <${RETURN}>" "[ ${RETURN} -eq ${expectedErrorCode} ]"
  fi

  if [ "${expectedErrorMsg}" != "" ]; then
    assertFileContains "Expected STD_ERR to contain error <${expectedErrorMsg}>" "${expectedErrorMsg}" "${STD_ERR}"
  fi
}

_assertContains() {
  if [ 5 -eq $# ]; then
    local msg="${1}"
    shift
  elif [ ! 4 -eq $# ]; then
    fail "Expected 4 or 5 parameters; Receieved $# parameters"
  fi

  local needle=$1
  local haystack=$2
  local expectation=$3
  local haystack_type=$4

  case "${haystack_type}" in
    "file")
      local haystack_no_color="${haystack}_no_color"
      if [ ! -e ${haystack_no_color} ]; then
        sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" < ${haystack} > ${haystack_no_color}
      fi
      ## echo grep -q -F -e "${needle}" ${haystack_no_color}
      grep -q -F -e "${needle}" ${haystack_no_color} ;;
    "text") echo "${haystack}" | grep -q -F -e "${needle}" ;;
  esac

  if [ "${expectation}" != "$?" ]; then
    case "${expectation}" in
      0) default_msg="Expected <${haystack}> to contain <${needle}>" ;;
      1) default_msg="Did not expect <${haystack}> to contain <${needle}>" ;;
    esac

    fail "${msg:-${default_msg}}"
  fi
}

assertContains() {
  _assertContains "$@" 0 "text"
}

assertNotContains() {
  _assertContains "$@" 1 "text"
}

assertFileContains() {
  _assertContains "$@" 0 "file"
}

assertFileNotContains() {
  _assertContains "$@" 1 "file"
}

command_exists () {
    type "$1" > /dev/null 2>&1 ;
}

assertFileMD5() {
  expectedHash=$1
  filename=$2

  if command_exists "md5sum"; then
    md5_cmd="md5sum ${filename}"
    expected_md5_cmd_output="${expectedHash}  ${filename}"
  elif command_exists "md5"; then
    md5_cmd="md5 ${filename}"
    expected_md5_cmd_output="MD5 (${filename}) = ${expectedHash}"
  else
    fail "no suitable MD5 hashing command found on this system"
  fi

  assertEquals "${expected_md5_cmd_output}" "`${md5_cmd}`"
}

assertModulesBoilerplateCaptured() {
  assertCaptured "Detected go modules via go.mod"
  assertCaptured "Detected Module Name: github.com/heroku/fixture"
  assertCaptured "Determining packages to install"
}

assertGoInstallOnlyFixturePackageCaptured(){
  assertCaptured "Running: go install -v -tags heroku github.com/heroku/fixture
github.com/heroku/fixture"
}

assertInstalledFixtureBinary() {
  assertCaptured "Installed the following binaries:
./bin/fixture"
  assertCompiledBinaryExists fixture
}

assertGoInstallCaptured() {
  local go_ver=${1:-${DEFAULT_GO_VERSION}}
  assertCaptured "Installing ${go_ver}
Fetching ${go_ver}.linux-amd64.tar.gz... done"
}

#!/bin/sh
. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testDetect_NotFound()
{
  detect  
  
  assertNoAppDetected
}

testDetect_Go()
{
  touch ${BUILD_DIR}/main.go
  
  detect  

  assertAppDetected "Go"
}
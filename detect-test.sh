before() {
  cp -r test detect-test
}

after() {
  rm -rf detect-test
}

it_is_go_if_go_files() {
  sh -x bin/detect detect-test/
}

it_is_not_go_without_go_files() {
  rm -rf detect-test/*
  ! sh -x bin/detect detect-test/
}

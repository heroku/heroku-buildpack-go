before() {
  cp -r test detect-test
}

after() {
  rm -rf detect-test
}

it_is_go_if_all_sh() {
  sh -x bin/detect detect-test/
}

it_is_go_if_go_files_under_src() {
  rm -rf detect-test/all.sh 
  sh -x bin/detect detect-test/
}

it_is_not_go_without_all_sh_or_go_files() {
  rm -rf detect-test/all.sh
  rm -rf detect-test/src
  ! sh -x bin/detect detect-test/
}

#!/bin/sh

ver=1.1.1

before() {
  rm -rf build cache
  cp -r test build
  mkdir cache
}

after() {
  rm -rf build cache
}

compile() {
  sh bin/compile build cache 2>&1
}

it_installs_go() {
  compile
  test -f cache/go-$ver/go/bin/go
  test -x cache/go-$ver/go/bin/go
}

it_skips_go_compile_if_exists() {
  mkdir -p cache/go-$ver/go
  compile | grep Using
}

it_compiles_app() {
  compile
  test -f build/bin/mytest
  test -x build/bin/mytest
  test "$(./build/bin/mytest 2>&1)" = "ok"
}

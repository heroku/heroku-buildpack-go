#!/bin/sh

# Default Go version is r59
rdir=$PWD/cache/src/go/release.r59

before() {
  mkdir -p build cache
  cp -r test/* build
}

after() {
  rm -rf tmp build
}

compile() {
  : === Compiling
  sh bin/compile build cache 2>&1
  : === Done compiling
}

# You can skip the long compile test by setting GOROOT
[ -n "$GOROOT" ] &&
  mkdir -p $(dirname $rdir) &&
  rm -f $rdir &&
  # Fake a compile
  ln -s $GOROOT $rdir

it_compiles_go() {
  # Skip this test if GOROOT is set
  [ -n "$GOROOT" ] && exit 0

  rm -rf cache
  mkdir cache
  ! test -f cache/src/go/release.r59/bin/gofmt
  compile
  test -f cache/src/go/release.r59/bin/gofmt
}

it_skips_go_compile_if_exists() {
  # We don't delete the cache dir in the tests so this
  # doesn't need to rebuild Go.
  test -f cache/src/go/release.r59/bin/gofmt
  compile | grep "Skipping build"
}

it_compiles_app() {
  compile
  test -f build/bin/mytest
  test -x build/bin/mytest
  test "$(./build/bin/mytest 2>&1)" = "ok"
}

it_deletes_cache() {
  # Here only to delete the cache dir
  rm -rf cache
}

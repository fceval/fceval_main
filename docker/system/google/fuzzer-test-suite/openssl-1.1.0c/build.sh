#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  #(cd BUILD && CC="$CC $CFLAGS" ./config && make clean && make -j $JOBS)
  ( cd BUILD && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" test/recipes/90-test_fuzz.t && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" test/recipes/80-test_ssl_new.t && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" test/recipes/40-test_rehash.t && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" test/build.info && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" test/run_tests.pl && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" util/process_docs.pl && sed -i "s#'File::Glob' => qw/glob/;#'File::Glob' => qw/bsd_glob/;#g" Configure
  )
  (cd BUILD && CC="$CC $CFLAGS" ./config -no-asm && make clean && make -j $JOBS)
}

get_git_tag https://github.com/openssl/openssl.git OpenSSL_1_1_0c SRC
build_lib
build_fuzzer

if [[ $FUZZING_ENGINE == "hooks" ]]; then
  # Link ASan runtime so we can hook memcmp et al.
  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
fi
set -x
for f in bignum x509; do
  $CC $CFLAGS -DFuzzerTestOneInput=LLVMFuzzerTestOneInput -c -g BUILD/fuzz/$f.c -I BUILD/include
  #$CXX $CXXFLAGS $f.o BUILD/libssl.a BUILD/libcrypto.a $LIB_FUZZING_ENGINE -lgcrypt -o $EXECUTABLE_NAME_BASE-$f
  $CXX $CXXFLAGS $f.o BUILD/libssl.a BUILD/libcrypto.a $LIB_FUZZING_ENGINE -lgcrypt -ldl -lpthread -o $EXECUTABLE_NAME_BASE-$f
done

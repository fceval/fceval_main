#!/usr/bin/env bash

set -e

cd /work/lava_corpus/LAVA-M
cp -rf  /work/lava_corpus/LAVA-M /work/lava_corpus/LAVA-M-asan
do_afl_bin() {
    cd "/work/lava_corpus/LAVA-M/$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/afl-lava/$1" LIBS="-lacl" --disable-shared
    make -j`nproc`
    make install
    make clean
    cd ../../
}

do_afl_bin_asan() {
    #export AFL_USE_ASAN=1
    cd "/work/lava_corpus/LAVA-M-asan/$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/afl-lava/asan/$1" LIBS="-lacl" --disable-shared
    make -j`nproc` 
    make install
    make clean
    cd ../../
    #unset AFL_USE_ASAN
}


do_afl_bin "base64"
do_afl_bin "md5sum"
do_afl_bin "uniq"
do_afl_bin "who"
cd /work/lava_corpus/LAVA-M-asan
do_afl_bin_asan "base64"
do_afl_bin_asan "md5sum"
do_afl_bin_asan "uniq"
do_afl_bin_asan "who"

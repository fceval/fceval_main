#!/usr/bin/env bash

set -e

cd /work/lava_corpus/LAVA-M

mkdir -p /targets/symcc-lava/afl
mkdir -p /targets/symcc-lava/symcc
 

do_afl_bin() {
    export CC=afl-clang-fast CXX=afl-clang-fast++   AFL_USE_ASAN=1
    cd /work/lava_corpus/LAVA-M
    mkdir "afl-$1"
    cp -r "$1/coreutils-8.24-lava-safe" "afl-$1/coreutils-8.24-lava-safe"     
    cd "afl-$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/symcc-lava/afl/$1" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../
    rm -rf "afl-$1/coreutils-8.24-lava-safe"
    cd ../
    unset CC CXX
}
 

do_symcc_bin() {
    export CC=symcc CXX=sym++
    cd /work/lava_corpus/LAVA-M
    cd "$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/symcc-lava/symcc/$1" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../../
    unset CC CXX
}

 
#do_afl_bin "base64"
#do_afl_bin "md5sum"
#do_afl_bin "uniq"
#do_afl_bin "who"
do_symcc_bin "base64"
do_symcc_bin "md5sum"
do_symcc_bin "uniq"
do_symcc_bin "who"




 

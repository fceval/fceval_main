#!/usr/bin/env bash

set -e

cd /work/lava_corpus/LAVA-M

 

do_bcfirst_bin() {
    export CC=gclang CXX=gclang++     
    cd "$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/parmesan-lava/bcfirst/" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../../
    unset CC CXX
}


do_bcfirst_bin "base64"
do_bcfirst_bin "md5sum"
do_bcfirst_bin "uniq"
do_bcfirst_bin "who"
cd /work



 

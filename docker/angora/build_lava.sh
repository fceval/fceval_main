#!/usr/bin/env bash

set -e



mkdir -p /targets/angora-lava/afl
mkdir -p /targets/angora-lava/fast
mkdir -p /targets/angora-lava/track

do_afl_bin() {
    export CC=afl-clang-fast CXX=afl-clang-fast++
    cd /work/lava_corpus/LAVA-M
    mkdir "afl-$1"
    cp -r "$1/coreutils-8.24-lava-safe" "afl-$1/coreutils-8.24-lava-safe"     
    cd "afl-$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/angora-lava/afl/$1" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../
    rm -rf "afl-$1/coreutils-8.24-lava-safe"
    cd ../
    unset CC CXX
}

do_angora_fast_bin() {
    export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++
    cd /work/lava_corpus/LAVA-M
    cd "$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/angora-lava/fast/$1" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../../
    unset CC CXX
}

do_angora_track_bin() {
    ldd /targets/angora-lava/fast/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /angora/tools/gen_library_abilist.sh '{}' discard >> /tmp/abilist.txt


    export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++ USE_TRACK=1
    # ANGORA_TAINT_RULE_LIST=/tmp/abilist.txt
    cd /work/lava_corpus/LAVA-M
    cd "$1/coreutils-8.24-lava-safe"
    #git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    ./configure --prefix="/targets/angora-lava/track/$1" LIBS="-lacl"
    make -j`nproc`
    make install
    make clean
    cd ../../
    unset CC CXX USE_TRACK ANGORA_TAINT_RULE_LIST
}


do_bin() {
    cd "$1/coreutils-8.24-lava-safe"
    #git apply "~/patches/coreutils-8.24-on-glibc-2.28.patch"
    CC=gclang ./configure --prefix="`pwd`/lava-install" LIBS="-lacl"
    make -j`nproc`
    make install
    get-bc -o "../../$1.bc" "lava-install/bin/$1"
    make clean
    cd ../../
    mkdir -p "/analysis_bin/$1.analysis_binaries"
    collab_fuzz_wrapper "$1.analysis_binaries" "$1.bc"
}

#do_afl_bin "base64"
#do_afl_bin "md5sum"
#do_afl_bin "uniq"
#do_afl_bin "who"
do_angora_fast_bin "base64"
do_angora_fast_bin "md5sum"
do_angora_fast_bin "uniq"
do_angora_fast_bin "who"
do_angora_track_bin "base64"
do_angora_track_bin "md5sum"
do_angora_track_bin "uniq"
do_angora_track_bin "who"




 

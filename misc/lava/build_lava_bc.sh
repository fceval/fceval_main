#!/usr/bin/env bash

set -euo pipefail

mkdir /work/lava-bc
cd lava_corpus/LAVA-M

do_bin() {
    cd "$1/coreutils-8.24-lava-safe"
    git apply "../../../../coreutils-8.24-on-glibc-2.28.patch"
    echo "zxy debug start"
    CC=gclang ./configure --prefix="$(pwd)/lava-install" LIBS="-lacl -lm"
    make -j $(nproc)
    make install
    echo "zxy debug end"
    get-bc -o "/work/lava-bc/$1.bc" "lava-install/bin/$1"
    cp "lava-install/bin/$1" "/work/lava/$1"
    cd ../../
}

do_bin "base64" &
do_bin "md5sum" &
do_bin "uniq" &
do_bin "who" &
wait;

cd ../../

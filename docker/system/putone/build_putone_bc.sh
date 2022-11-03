#!/bin/bash
set -euo pipefail
export CC=gclang
export CXX=gclang++

cd putone && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r *.tar.gz *.zip &&\
    mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh
mkdir -p /work/targets/afl-putone

cd /work/putone/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /work/targets/afl-putone/ &&\
    make clean && cd /work




#cd /work/putone/cflow-1.6 && ./configure &&\
#    make -j &&\
#    cp src/cflow /work/targets/afl-putone/ &&\
#    make clean && cd /work


ls -alh /work/targets/afl-putone/*

mkdir /work/putone-bc
cd /work/targets/afl-putone
for t in *; do (
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /work/putone-bc/
    )
done;

unset CC
unset CXX

wait;






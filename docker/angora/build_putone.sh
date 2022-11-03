#!/usr/bin/env bash

set -e
export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++ 
cd /work/putone && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r *.tar.gz *.zip &&\
    mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh 
cd /work  && cp -r putone putone-afl

cd /work/putone/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/angora-putone/fast/ &&\
    make clean

  

# build angora track bins
RUN ldd /targets/angora-putone/fast/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /angora/tools/gen_library_abilist.sh '{}' discard >> /tmp/abilist.txt


export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++ USE_TRACK=1 ANGORA_TAINT_RULE_LIST=/tmp/abilist.txt
#ANGORA_TAINT_RULE_LIST=/tmp/abilist.txt

cd /work/putone/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/angora-putone/track/ &&\
    make clean


unset USE_TRACK ANGORA_TAINT_RULE_LIST CC CXX

 
 

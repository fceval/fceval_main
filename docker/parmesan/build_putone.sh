#!/usr/bin/env bash

set -e

# build angora fast bins
export ENV CC=gclang CXX=gclang++ 

cd /work/putone && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r *.tar.gz *.zip &&\
    mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh 
 



cd /work/putone/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/parmesan-putone/bcfirst/ &&\
    make clean

 


unset USE_TRACK ANGORA_TAINT_RULE_LIST CC CXX

 
ls -alh /targets/parmesan-putone/bcfirst/*

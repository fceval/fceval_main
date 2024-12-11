#!/bin/bash
set -euo pipefail
export CC=gclang
export CXX=gclang++

cd /work/unibench
mkdir -p /work/targets/tmp-unibench

#for f in /work/unibench/*.tar.gz; do \
#    tar xvf "$f"
#done
ls *.zip|xargs -i unzip -q '{}' && ls *.tar.gz|xargs -i tar xf '{}' && rm -r *.tar.gz *.zip

cd /work/unibench/Bento4-1.5.1-628 && cmake . &&\
    make -j &&\
    cp mp42aac /work/targets/tmp-unibench/ &&\
    make clean && cd /work

cd /work/unibench/cflow-1.6 && ./configure &&\
    make -j &&\
    cp src/cflow /work/targets/tmp-unibench/ &&\
    make clean && cd /work

    
#cd /work/unibench/tcpdump-4.8.1 && ./configure &&\
#    make -j &&\
#    cp tcpdump /work/targets/tmp-unibench/ && make clean && cd /work

cd /work/unibench/exiv2-0.26 && cmake -DEXIV2_ENABLE_SHARED=OFF . && make -j && cp bin/exiv2 /work/targets/tmp-unibench/ && make clean && cd /work

cd /work/unibench/lame-3.99.5 && ./configure --disable-shared &&\
    make -j &&\
    cp frontend/lame /work/targets/tmp-unibench/ &&\
    make clean && cd /work 

cd /work/unibench/jq-1.5 && ./configure --disable-shared &&\
    make -j &&\
    cp jq /work/targets/tmp-unibench/ &&\
    make clean && cd /work
    
cd /work/unibench/swftools-0.9.2 && ./configure  &&\
    make -j &&\
    cp src/wav2swf /work/targets/tmp-unibench/ &&\
    make clean && cd /work
 
 cd /work/unibench/jasper-2.0.12 && cmake -DJAS_ENABLE_SHARED=OFF -DALLOW_IN_SOURCE_BUILD=ON . && make -j && cp src/appl/imginfo /work/targets/tmp-unibench/ && make clean && cd /work   
        
ls -alh /work/targets/tmp-unibench/*

mkdir -p /work/unibench-bc
cd /work/targets/tmp-unibench
for t in *; do (
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /work/unibench-bc/
    )
done;

unset CC
unset CXX

wait;






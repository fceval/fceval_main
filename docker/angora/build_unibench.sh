#!/usr/bin/env bash

set -e
export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++ 
cd /work/unibench && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r *.tar.gz *.zip &&\
    mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh 
cd /work  && cp -r unibench unibench-afl

cd /work/unibench/exiv2-0.26 && cmake -DEXIV2_ENABLE_SHARED=OFF . && make -j && cp bin/exiv2 /targets/angora-unibench/fast/ &&\
    make clean

apt-get install -y libglib2.0-dev gtk-doc-tools libtiff-dev libpng-dev &&\
    cd /work/unibench/gdk-pixbuf-2.31.1 &&\
    ./autogen.sh --enable-static=yes --enable-shared=no --with-included-loaders=yes && make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/jasper-2.0.12 && cmake -DJAS_ENABLE_SHARED=OFF -DALLOW_IN_SOURCE_BUILD=ON . &&\
    make -j &&\
    cp src/appl/imginfo /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/jhead-3.00 &&\
    make -j &&\
    cp jhead /targets/angora-unibench/fast/ &&\
    make clean


cd /work/unibench/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/angora-unibench/fast/ &&\
    make clean

 

cd /work/unibench/flvmeta-1.2.1 && cmake . &&\
    make -j &&\
    cp src/flvmeta /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/Bento4-1.5.1-628 && cmake . &&\
    make -j &&\
    cp mp42aac /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/cflow-1.6 && ./configure &&\
    make -j &&\
    cp src/cflow /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/ncurses-6.1 && ./configure --disable-shared &&\
    make -j &&\
    cp progs/tic /targets/angora-unibench/fast/infotocap &&\
    make clean

cd /work/unibench/jq-1.5 && ./configure --disable-shared &&\
    make -j &&\
    cp jq /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/mujs-1.0.2 &&\
    build=debug make -j &&\
    cp build/debug/mujs /targets/angora-unibench/fast/ &&\
    make clean

cd /work/unibench/xpdf-4.00 && cmake . &&\
    make -j &&\
    cp xpdf/pdftotext /targets/angora-unibench/fast/ &&\
    make clean

# build angora track bins
RUN ldd /targets/angora-unibench/fast/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /angora/tools/gen_library_abilist.sh '{}' discard >> /tmp/abilist.txt


export CC=/angora/bin/angora-clang CXX=/angora/bin/angora-clang++ USE_TRACK=1 USE_DFSAN=1  ANGORA_TAINT_RULE_LIST=/tmp/abilist.txt
#ANGORA_TAINT_RULE_LIST=/tmp/abilist.txt

cd /work/unibench/exiv2-0.26 && cmake -DEXIV2_ENABLE_SHARED=OFF . && make -j && cp bin/exiv2 /targets/angora-unibench/track/ &&\
    make clean

apt-get install -y libglib2.0-dev gtk-doc-tools libtiff-dev libpng-dev &&\
    cd /work/unibench/gdk-pixbuf-2.31.1 &&\
    ./autogen.sh --enable-static=yes --enable-shared=no --with-included-loaders=yes && make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/jasper-2.0.12 && cmake -DJAS_ENABLE_SHARED=OFF -DALLOW_IN_SOURCE_BUILD=ON . &&\
    make -j &&\
    cp src/appl/imginfo /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/jhead-3.00 &&\
    make -j &&\
    cp jhead /targets/angora-unibench/track/ &&\
    make clean


cd /work/unibench/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/angora-unibench/track/ &&\
    make clean

 

cd /work/unibench/flvmeta-1.2.1 && cmake . &&\
    make -j &&\
    cp src/flvmeta /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/Bento4-1.5.1-628 && cmake . &&\
    make -j &&\
    cp mp42aac /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/cflow-1.6 && ./configure &&\
    make -j &&\
    cp src/cflow /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/ncurses-6.1 && ./configure --disable-shared &&\
    make -j &&\
    cp progs/tic /targets/angora-unibench/track/infotocap &&\
    make clean

cd /work/unibench/jq-1.5 && ./configure --disable-shared &&\
    make -j &&\
    cp jq /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/mujs-1.0.2 &&\
    build=debug make -j &&\
    cp build/debug/mujs /targets/angora-unibench/track/ &&\
    make clean

cd /work/unibench/xpdf-4.00 && cmake . &&\
    make -j &&\
    cp xpdf/pdftotext /targets/angora-unibench/track/ &&\
    make clean

unset USE_TRACK ANGORA_TAINT_RULE_LIST CC CXX

 
 

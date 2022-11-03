#!/usr/bin/env bash

set -e


mkdir -p /targets/honggfuzz-unibench && mkdir -p /targets/honggfuzz-unibench/aflasan && apt-get update && apt-get install -y zip flex bison

cd /work/unibench && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r *.tar.gz *.zip &&\
    mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh

cd /work/unibench/exiv2-0.26 && cmake -DEXIV2_ENABLE_SHARED=OFF . && make -j && cp bin/exiv2 /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j && cp bin/exiv2 /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

apt-get install -y libglib2.0-dev gtk-doc-tools libtiff-dev libpng-dev &&\
    cd /work/unibench/gdk-pixbuf-2.31.1 &&\
    ./autogen.sh --enable-static=yes --enable-shared=no --with-included-loaders=yes && make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/jasper-2.0.12 && cmake -DJAS_ENABLE_SHARED=OFF -DALLOW_IN_SOURCE_BUILD=ON . &&\
    make -j &&\
    cp src/appl/imginfo /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/appl/imginfo /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/jhead-3.00 &&\
    make -j &&\
    cp jhead /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp jhead /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/libtiff-3.9.7 && ./autogen.sh && ./configure --disable-shared &&\
    make -j &&\
    cp tools/tiffsplit /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp tools/tiffsplit /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/lame-3.99.5 && ./configure --disable-shared &&\
    make -j &&\
    cp frontend/lame /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp frontend/lame /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp mp3gain /targets/honggfuzz-unibench/aflasan/ &&\
    make clean



# Comment out ffmpeg for building under travis-ci
# The memory usage seems to exceed 3GB and may make the whole build job timeout (50 minutes)
#RUN apt install -y nasm &&\
#    cd unibench/ffmpeg-4.0.1 && ./configure --disable-shared --cc="$CC" --cxx="$CXX" &&\
#    make -j &&\
#    cp ffmpeg_g /targets/honggfuzz-unibench/ffmpeg &&\
#    make clean && AFL_USE_ASAN=1 make -j &&\
#    cp ffmpeg_g /targets/honggfuzz-unibench/aflasan/ffmpeg &&\
#    make clean

cd /work/unibench/flvmeta-1.2.1 && cmake . &&\
    make -j &&\
    cp src/flvmeta /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/flvmeta /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/Bento4-1.5.1-628 && cmake . &&\
    make -j &&\
    cp mp42aac /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp mp42aac /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/cflow-1.6 && ./configure &&\
    make -j &&\
    cp src/cflow /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/cflow /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/ncurses-6.1 && ./configure --disable-shared &&\
    make -j &&\
    cp progs/tic /targets/honggfuzz-unibench/infotocap &&\
    make clean && AFL_USE_ASAN=1 ASAN_OPTIONS="detect_leaks=0" make -j &&\
    cp progs/tic /targets/honggfuzz-unibench/aflasan/infotocap &&\
    make clean

cd /work/unibench/jq-1.5 && ./configure --disable-shared &&\
    make -j &&\
    cp jq /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp jq /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/mujs-1.0.2 &&\
    build=debug make -j &&\
    cp build/debug/mujs /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 build=debug make -j &&\
    cp build/debug/mujs /targets/honggfuzz-unibench/aflasan/ &&\
    make clean

cd /work/unibench/xpdf-4.00 && cmake . &&\
    make -j &&\
    cp xpdf/pdftotext /targets/honggfuzz-unibench/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp xpdf/pdftotext /targets/honggfuzz-unibench/aflasan/ &&\
    make clean


cd /work/unibench/libpcap-1.8.1 && ./configure --disable-shared &&\
    make -j
cd /work/unibench/tcpdump-4.8.1 && ./configure &&\
    make -j &&\
    cp tcpdump /targets/honggfuzz-unibench/
cd /work/unibench/libpcap-1.8.1 &&\
    make clean && AFL_USE_ASAN=1 make -j
cd /work/unibench/tcpdump-4.8.1 &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp tcpdump /targets/honggfuzz-unibench/aflasan/ &&\
    make clean
cd /work/unibench/libpcap-1.8.1 && make clean

apt-get install -y nasm &&\
    cd /work/unibench/ffmpeg-4.0.1 && ./configure --disable-shared &&\
    make -j &&\
    cp ffmpeg_g /targets/honggfuzz-unibench/ffmpeg &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp ffmpeg_g /targets/honggfuzz-unibench/aflasan/ffmpeg &&\
    make clean 

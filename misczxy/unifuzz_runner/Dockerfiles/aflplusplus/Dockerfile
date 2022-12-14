FROM aflplusplus/aflplusplus

ARG APT

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONIOENCODING=utf8 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# install proper tools
RUN ([ "$APT" == "" ] || (sed -i "s/security.ubuntu.com/$APT/g" /etc/apt/sources.list && sed -i "s/archive.ubuntu.com/$APT/g" /etc/apt/sources.list) ) &&\
    apt-get update && \
    apt-get install -y vim nano htop autoconf automake build-essential libtool cmake git sudo software-properties-common gperf libselinux1-dev  bison texinfo flex zlib1g-dev libexpat1-dev libmpg123-dev wget curl python3-pip python2 unzip pkg-config clang llvm-dev libglib2.0-dev gtk-doc-tools libtiff-dev libpng-dev autopoint gettext&&\
    python -m pip install -U pip &&\
    python3 -m pip install -U pip &&\
    sed -i 's/python3/python/' /usr/local/bin/pip

WORKDIR /

RUN git clone https://github.com/UNIFUZZ/unibench &&\
    cd unibench && \
    mkdir mp3gain-1.5.2 && cd mp3gain-1.5.2 && mv ../mp3gain-1.5.2.zip ./ && unzip -q mp3gain-1.5.2.zip && rm mp3gain-1.5.2.zip && cd .. &&\
    ls *.zip|xargs -i unzip -q '{}' &&\
    ls *.tar.gz|xargs -i tar xf '{}' &&\
    rm -r .git/ *.tar.gz *.zip &&\
    mv SQLite-8a8ffc86 SQLite-3.8.9 && mv binutils_5279478 binutils-5279478 && mv libtiff-Release-v3-9-7 libtiff-3.9.7 &&\
    ls -alh
RUN mkdir -p /d/p/justafl /d/p/aflasan

ENV CC=afl-clang-fast \
    CXX=afl-clang-fast++

RUN cd /unibench/binutils-2.28 && ./configure --disable-shared &&\
    make -j &&\
    cp binutils/objdump /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 ASAN_OPTIONS="detect_leaks=0" make -j &&\
    cp binutils/objdump /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/exiv2-0.26 && cmake -DEXIV2_ENABLE_SHARED=OFF . && make -j && cp bin/exiv2 /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j && cp bin/exiv2 /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/gdk-pixbuf-2.31.1 &&\
    ./autogen.sh --enable-static=yes --enable-shared=no --with-included-loaders=yes && make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp gdk-pixbuf/gdk-pixbuf-pixdata /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/jasper-2.0.12 && cmake -DJAS_ENABLE_SHARED=OFF -DALLOW_IN_SOURCE_BUILD=ON . &&\
    make -j &&\
    cp src/appl/imginfo /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/appl/imginfo /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/jhead-3.00 &&\
    make -j &&\
    cp jhead /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp jhead /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/libtiff-3.9.7 && ./autogen.sh && ./configure --disable-shared &&\
    make -j &&\
    cp tools/tiffsplit /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp tools/tiffsplit /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/lame-3.99.5 && ./configure --disable-shared &&\
    make -j &&\
    cp frontend/lame /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp frontend/lame /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/mp3gain-1.5.2 && sed -i 's/CC=/CC?=/' Makefile &&\
    make -j &&\
    cp mp3gain /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp mp3gain /d/p/aflasan/ &&\
    make clean

# Comment out ffmpeg for building under travis-ci
# The memory usage seems to exceed 3GB and may make the whole build job timeout (50 minutes)
#RUN apt install -y nasm &&\
#    cd /unibench/ffmpeg-4.0.1 && ./configure --disable-shared --cc="$CC" --cxx="$CXX" &&\
#    make -j &&\
#    cp ffmpeg_g /d/p/justafl/ffmpeg &&\
#    make clean && AFL_USE_ASAN=1 make -j &&\
#    cp ffmpeg_g /d/p/aflasan/ffmpeg &&\
#    make clean

RUN cd /unibench/flvmeta-1.2.1 && cmake . &&\
    make -j &&\
    cp src/flvmeta /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/flvmeta /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/Bento4-1.5.1-628 && cmake . &&\
    make -j &&\
    cp mp42aac /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp mp42aac /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/cflow-1.6 && ./configure &&\
    make -j &&\
    cp src/cflow /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp src/cflow /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/ncurses-6.1 && ./configure --disable-shared &&\
    make -j &&\
    cp progs/tic /d/p/justafl/infotocap &&\
    make clean && AFL_USE_ASAN=1 ASAN_OPTIONS="detect_leaks=0" make -j &&\
    cp progs/tic /d/p/aflasan/infotocap &&\
    make clean

RUN cd /unibench/jq-1.5 && ./configure --disable-shared &&\
    make -j &&\
    cp jq /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp jq /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/mujs-1.0.2 &&\
    build=debug make -j &&\
    cp build/debug/mujs /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 build=debug make -j &&\
    cp build/debug/mujs /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/xpdf-4.00 && cmake . &&\
    make -j &&\
    cp xpdf/pdftotext /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp xpdf/pdftotext /d/p/aflasan/ &&\
    make clean

#--disable-amalgamation can be used for coverage build
RUN apt install -y tcl-dev &&\
    cd /unibench/SQLite-3.8.9 && ./configure --disable-shared &&\ 
    make -j &&\
    cp sqlite3 /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 ASAN_OPTIONS="detect_leaks=0" make -j &&\
    cp sqlite3 /d/p/aflasan/ &&\
    make clean

RUN cd /unibench/binutils-5279478 &&\
    ./configure --disable-shared &&\
    for i in bfd libiberty opcodes libctf; do cd $i; ./configure --disable-shared && make -j; cd ..; done  &&\
    cd binutils  &&\
    ./configure --disable-shared &&\
    make nm-new &&\
    cp nm-new /d/p/justafl/nm &&\
    cd /unibench/binutils-5279478 &&\
    for i in bfd libiberty opcodes libctf; do cd $i; make clean && AFL_USE_ASAN=1 make -j; cd ..; done  &&\
    cd binutils  && make clean &&\
    AFL_USE_ASAN=1 make nm-new &&\
    cp nm-new /d/p/aflasan/nm &&\
    cd .. && make distclean

RUN cd /unibench/libpcap-1.8.1 && ./configure --disable-shared &&\
    make -j &&\
    cd /unibench/tcpdump-4.8.1 && ./configure &&\
    make -j &&\
    cp tcpdump /d/p/justafl/ &&\
    cd /unibench/libpcap-1.8.1 &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cd /unibench/tcpdump-4.8.1 &&\
    make clean && AFL_USE_ASAN=1 make -j &&\
    cp tcpdump /d/p/aflasan/ &&\
    make clean && cd /unibench/libpcap-1.8.1 && make clean

RUN cd /unibench/swftools-0.9.2/ && ./configure &&\
    sed -i 's/int inline ActionTagSize/int ActionTagSize/' ./lib/modules/swfaction.c &&\
    sed -i 's/byte inline PaethPredictor/byte PaethPredictor/' ./src/png2swf.c &&\
    make -j || echo "done!"&&\
    cp src/wav2swf /d/p/justafl/ &&\
    make clean && AFL_USE_ASAN=1 make -j || echo "done!"&&\
    cp src/wav2swf /d/p/aflasan/ &&\
    make clean

# this will add /d/p/justafl/ffmpeg and /d/p/aflasan/ffmpeg
RUN wget --quiet https://gitlab.com/unifuzz/unibench_build/raw/master/ffmpeg/afl.tar.gz &&\
    tar xf afl.tar.gz -C / &&\
    rm afl.tar.gz

RUN ls -alh /d/p/*
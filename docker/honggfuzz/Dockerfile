###FROM fuzzer-system AS fuzzer-system-honggfuzz

###ARG CC=clang CXX=clang++

###WORKDIR  /work


# honggfuzz requires libfd and libunwid.
###RUN apt-get update -y && \
###    apt-get install -y wget git  make build-essential  \
###    libbfd-dev \
###    libunwind-dev \
###    libblocksruntime-dev \
###    liblzma-dev \
###    libarchive-dev libxml2-dev libgcrypt-dev libssl-dev libbz2-dev liblzma-dev libvorbis-dev libogg-dev  nasm autoconf-archive lcov subversion zlib1g-dev libdbus-1-dev pkg-config rsync
#### Download honggfuz version 2.3.1 + 0b4cd5b1c4cf26b7e022dc1deb931d9318c054cb
#### Set CFLAGS use honggfuzz's defaults except for -mnative which can build CPU
#### dependent code that may not work on the machines we actually fuzz on.
#### Create an empty object file which will become the FUZZER_LIB lib (since
#### honggfuzz doesn't need this when hfuzz-clang(++) is used).
####RUN git clone https://github.com/google/honggfuzz.git /honggfuzz && \
####    cd /honggfuzz && \
####    git checkout 0b4cd5b1c4cf26b7e022dc1deb931d9318c054cb && \
####    CFLAGS="-O3 -funroll-loops" make && make install && \
####    touch empty_lib.c && \
####    cc -c -o empty_lib.o empty_lib.c

#### install Honggfuzz
####RUN git clone --depth=1 --single-branch --branch 2.0_w_sync https://github.com/phi-go/honggfuzz.git && cd honggfuzz && make -j && make install && ls && ./honggfuzz --help
####RUN git clone --depth=1 https://github.com/google/honggfuzz.git && cd honggfuzz && CFLAGS="-O3 -funroll-loops" make -j && make install && ls && ./honggfuzz --help
###RUN git clone --depth=1 --single-branch --branch 2.0_w_sync https://github.com/phi-go/honggfuzz.git && cd honggfuzz && make -j && make install && ls && ./honggfuzz --help

###COPY afl_converter.py .


###FROM fuzzer-system-honggfuzz AS fuzzer-honggfuzz-binutils
###ENV CC=hfuzz-clang CXX=hfuzz-clang++

# build binutils 
###WORKDIR  /work
###RUN mkdir -p /targets/honggfuzz-binutils && tar xfv binutils-2.26.1.tar.gz && cd binutils-2.26.1/ && ./configure --prefix=/targets/honggfuzz-binutils/ && make -j`nproc` && make install


###FROM fuzzer-system-honggfuzz AS fuzzer-honggfuzz-google
###WORKDIR  /work
# build fuzzer-test-suite
###RUN mv compiler-rt-12.0.1.src.tar.xz  compiler-rt.tar.xz && ls -lah && tar xfv compiler-rt.tar.xz
####&& git clone https://github.com/google/fuzzer-test-suite.git && cd fuzzer-test-suite && git checkout b2e885706d6
###COPY   build.sh fuzzer-test-suite/build.sh
###RUN mkdir build-test-suite && mkdir /targets/honggfuzz-google
###COPY   build_fuzzer_test_suite.py build-test-suite/build_fuzzer_test_suite.py
###RUN cd build-test-suite && python3 build_fuzzer_test_suite.py serial
###RUN cd build-test-suite && find . -name "*-honggfuzz" -executable | xargs cp -t  /targets/honggfuzz-google/ && rsync -avr --exclude=RUNDIR-*/BUILD --exclude=RUNDIR-*/SRC RUNDIR-* /targets/honggfuzz-google
 
 

###FROM fuzzer-system-honggfuzz AS fuzzer-honggfuzz-lava
###ENV CC=hfuzz-clang CXX=hfuzz-clang++


# build LAVA-M
###WORKDIR  /work
####RUN mkdir -p /targets/honggfuzz-lava && tar xfv lava_corpus.tar.xz
####RUN wget http://panda.moyix.net/~moyix/lava_corpus.tar.xz && tar xfv lava_corpus.tar.xz
####RUN tar xfv lava_corpus.tar.xz

###COPY build_lava.sh build_lava.sh
###COPY coreutils-8.24-on-glibc-2.28.patch coreutils-8.24-on-glibc-2.28.patch
###RUN mkdir -p /targets/honggfuzz-lava && tar xfv lava_corpus.tar.xz && FORCE_UNSAFE_CONFIGURE=1 ./build_lava.sh


###FROM fuzzer-system-honggfuzz AS fuzzer-honggfuzz-unibench
###ENV CC=hfuzz-clang CXX=hfuzz-clang++
# build unibench
###WORKDIR  /work
###COPY build_unibench.sh build_unibench.sh
###RUN FORCE_UNSAFE_CONFIGURE=1 ./build_unibench.sh
####RUN ls -alh /targets/aflplusplus-unibench/*


###FROM fuzzer-system-honggfuzz AS fuzzer-honggfuzz-putone
###ENV CC=hfuzz-clang CXX=hfuzz-clang++
# build putone
###WORKDIR  /work
###COPY build_putone.sh build_putone.sh
###RUN FORCE_UNSAFE_CONFIGURE=1 ./build_putone.sh
####RUN ls -alh /targets/aflplusplus-putone/*



#FROM fuzzer-system-honggfuzz
#RUN rm -rf /work && apt-get update && apt-get install -y build-essential libunwind-dev libipt-dev libblocksruntime-dev libarchive-dev libglib2.0 libgss3
##  && cd /work/honggfuzz && make install && rm -rf /work
#ENV DEBIAN_FRONTEND=noninteractive


#COPY --from=fuzzer-honggfuzz-binutils /targets/honggfuzz-binutils /targets/binutils
#COPY --from=fuzzer-honggfuzz-lava /targets/honggfuzz-lava /targets/lava
#RUN apt-get update && apt-get install -y libarchive-dev libglib2.0 libgss3
#COPY --from=fuzzer-honggfuzz-google /targets/honggfuzz-google /targets/google
#COPY --from=fuzzer-honggfuzz-unibench /targets/honggfuzz-unibench /targets/unibench
#COPY --from=fuzzer-honggfuzz-putone /targets/honggfuzz-putone /targets/putone

FROM magma/honggfuzz_asan/libpng
RUN apt-get update && apt-get install -y build-essential libunwind-dev libipt-dev libblocksruntime-dev libarchive-dev libglib2.0 libgss3  libasound2-dev libflac-dev libogg-dev libtool libvorbis-dev libopus-dev libmp3lame-dev libmpg123-dev nasm zlib1g-dev liblzma-dev libjpeg-turbo8-dev libreadline-dev 

ENV DEBIAN_FRONTEND=noninteractive


COPY magma /targets/magma
COPY magma/binutils /targets/binutils
COPY magma/unibench /targets/unibench
#COPY --from=fuzzer-honggfuzz-lava /targets/honggfuzz-lava /targets/lava
#RUN apt-get update && apt-get install -y libarchive-dev libglib2.0 libgss3
#COPY --from=fuzzer-honggfuzz-google /targets/honggfuzz-google /targets/google
#COPY --from=fuzzer-honggfuzz-unibench /targets/honggfuzz-unibench /targets/unibench
#COPY --from=fuzzer-honggfuzz-putone /targets/honggfuzz-putone /targets/putone

COPY afl_converter.py .

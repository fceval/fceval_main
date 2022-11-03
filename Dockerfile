FROM fedora:31 AS base
RUN dnf install -y --refresh net-tools nano texinfo zip flex bison findutils glib2-devel nasm

### Downloader image to download sources
FROM alpine AS downloader
RUN apk add git wget

### Base image used to build stuff
FROM base AS base-builder
RUN dnf install -y --refresh \
        cmake \
        clang \
        file \
        gcc-c++ \
        git \
        llvm-devel \
        make \
        wget \
        unzip \
        xz && \
    sed --in-place=.orig \
        's/if (ARG_SHARED)/if (ARG_SHARED OR ARG_MODULE)/' \
        /usr/lib64/cmake/llvm/AddLLVM.cmake
WORKDIR /work
RUN llvm-config --version > /work/llvm-version
WORKDIR /work
#COPY misc/compiler-rt-9.0.1.src compiler-rt-9.0.1.src
#RUN cd compiler-rt-9.0.1.src/lib/fuzzer && \
#    bash build.sh && \
#    cp libFuzzer.a /usr/lib && \
#    cp libFuzzer.a /work/
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/compiler-rt-9.0.1.src.tar.xz && tar xfv compiler-rt-9.0.1.src.tar.xz && cd compiler-rt-9.0.1.src/lib/fuzzer && \
    bash build.sh && \
    cp libFuzzer.a /usr/lib && \
    cp libFuzzer.a /work/

RUN dnf install -y --refresh python3-pip texinfo boost-static boost-program-options git make autoconf automake libtool  zlib-devel zlib-static python3-pip  cmake nasm xz-devel  libjpeg-turbo-devel wget libarchive-devel glib2-devel libxml2-devel libgcrypt-devel openssl-devel zlib-devel bzip2-devel xz-devel libvorbis-devel libogg-devel ragel-devel nasm autoconf-archive dbus-devel readline-devel lcov subversion rsync lzma && pip3 install pylddwrap && yum -y install perl-CPAN perl-IPC-Cmd
RUN dnf install -y --refresh texinfo zip flex bison findutils glib2-devel gtk-doc libtiff-devel libpng-devel nasm boost-static boost-program-options && yum install -y expat expat-devel libpcap libpcap-devel


### gllvm image
#FROM golang:1.14 AS gllvm
FROM golang:1.17 AS gllvm
RUN go get github.com/SRI-CSL/gllvm/cmd/...

### LLVM passes image
FROM base-builder AS llvm-passes
ENV HOME /root
RUN dnf install -y --refresh \
        boost \
        boost-devel \
        boost-static \
        boost-program-options \
        ninja-build
ENV PATH="${HOME}/.cargo/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf --output /tmp/rustup-init \
        https://sh.rustup.rs && \
    chmod +x /tmp/rustup-init && \
    /tmp/rustup-init -y && \
    rustup install nightly
COPY llvm-passes llvm-passes/
WORKDIR /work/llvm-passes/build
RUN rm -f CMakeCache.txt && \
    rustup override set nightly \
        --path ../input-bytes-tracer-pass && \
    cmake \
        -GNinja \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DBUILD_TESTING=OFF \
        .. && \
    ninja && \
    cpack
 

### LAVA bitcode image
FROM base-builder AS lava
ENV FORCE_UNSAFE_CONFIGURE=1
WORKDIR /work
COPY --from=gllvm /go/bin /usr/bin
RUN dnf install -y --refresh libacl-devel boost-static boost-program-options
#RUN wget http://panda.moyix.net/~moyix/lava_corpus.tar.xz && \
#    tar xf lava_corpus.tar.xz
COPY misc/lava /work/lava
WORKDIR /work/lava
RUN tar xf lava_corpus.tar.xz && ./build_lava_bc.sh
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
RUN ./build_lava_ab.sh


### binutils bitcode
FROM base-builder AS binutils
WORKDIR /work
COPY --from=gllvm /go/bin /usr/bin
RUN dnf install -y --refresh texinfo boost-static boost-program-options
COPY misc/binutils  /work/binutils
WORKDIR /work/binutils
RUN ./build_binutils_bc.sh
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
RUN ./build_binutils_ab.sh



### putonemp3gain bitcode
### putone bitcode
FROM base-builder AS putone
WORKDIR /work
COPY --from=gllvm /go/bin /usr/bin
RUN dnf install -y --refresh texinfo zip flex bison findutils glib2-devel gtk-doc libtiff-devel libpng-devel nasm make autoconf automake libtool shtool zlib-devel zlib-static patch boost-static boost-program-options 
COPY  misc/putone /work/putone
WORKDIR /work/putone
RUN  ./build_putone_bc.sh
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
RUN ./build_putone_ab.sh

### llvm-project-src
FROM downloader AS llvm-project-src
WORKDIR /work/llvm-project
COPY --from=base-builder /work/llvm-version /work/llvm-version
RUN export LLVM_VER=`cat /work/llvm-version` && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/llvm-$LLVM_VER.src.tar.xz && \
    tar xf llvm-$LLVM_VER.src.tar.xz && \
    rm llvm-$LLVM_VER.src.tar.xz && \
    mv llvm-$LLVM_VER.src llvm
RUN export LLVM_VER=`cat /work/llvm-version` && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/libcxx-$LLVM_VER.src.tar.xz && \
    tar xf libcxx-$LLVM_VER.src.tar.xz && \
    rm libcxx-$LLVM_VER.src.tar.xz && \
    mv libcxx-$LLVM_VER.src libcxx
RUN export LLVM_VER=`cat /work/llvm-version` && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/libcxxabi-$LLVM_VER.src.tar.xz && \
    tar xf libcxxabi-$LLVM_VER.src.tar.xz && \
    rm libcxxabi-$LLVM_VER.src.tar.xz && \
    mv libcxxabi-$LLVM_VER.src libcxxabi
RUN export LLVM_VER=`cat /work/llvm-version` && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/compiler-rt-$LLVM_VER.src.tar.xz && \
    tar xf compiler-rt-$LLVM_VER.src.tar.xz && \
    rm compiler-rt-$LLVM_VER.src.tar.xz && \
    mv compiler-rt-$LLVM_VER.src compiler-rt
RUN apk add patch
COPY misc/google/0001-Add-support-to-build-libcxx-and-libcxxabi-with-DFSan.patch llvm_dfsan.patch
RUN patch -p1 < llvm_dfsan.patch

### llvm-project
FROM base-builder AS llvm-project
WORKDIR /work
RUN dnf install -y --refresh ninja-build
COPY --from=llvm-project-src /work/llvm-project /work/llvm-project/

### dfsan_libcxx
FROM llvm-project AS dfsan-libcxx
RUN mkdir llvm-build && \
    cd llvm-build && \
    cmake -G Ninja ../llvm-project/llvm \
        -DLLVM_LIBDIR_SUFFIX=64 \
        -DLLVM_ENABLE_PROJECTS='libcxx;libcxxabi' \
        -DLLVM_USE_SANITIZER=DataFlow \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_C_FLAGS="-fsanitize-blacklist=/usr/lib64/clang/`llvm-config --version`/dfsan_abilist.txt" \
        -DCMAKE_CXX_FLAGS="-fsanitize-blacklist=/usr/lib64/clang/`llvm-config --version`/dfsan_abilist.txt" \
        -DLIBCXX_ENABLE_SHARED=OFF \
        -DLIBCXXABI_ENABLE_SHARED=OFF && \
    ninja cxx cxxabi
RUN cp llvm-build/lib64/libc++abi.a /usr/lib64/dfsan_libc++abi.a && \
    cp llvm-build/lib64/libc++.a /usr/lib64/dfsan_libc++.a && \
    rm -rf llvm-build

### icount_libcxx
FROM llvm-project AS icount-libcxx
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
RUN mkdir llvm-build-icount && \
    cd llvm-build-icount && \
    ICOUNT_WRAPPER_FORWARD=1 cmake -G Ninja ../llvm-project/llvm \
        -DLLVM_LIBDIR_SUFFIX=64 \
        -DLLVM_ENABLE_PROJECTS='libcxx;libcxxabi' \
        -DCMAKE_C_COMPILER=clang_icount \
        -DCMAKE_CXX_COMPILER=clang_icount++ \
        -DLIBCXX_ENABLE_SHARED=OFF \
        -DLIBCXXABI_ENABLE_SHARED=OFF && \
    ninja cxx cxxabi
RUN cp llvm-build-icount/lib64/libc++abi.a /usr/lib64/icount_libc++abi.a && \
    cp llvm-build-icount/lib64/libc++.a /usr/lib64/icount_libc++.a && \
    rm -r llvm-build-icount


### magma bitcode
FROM base-builder AS magma
WORKDIR /work
COPY --from=gllvm /go/bin /usr/bin
RUN dnf install -y --refresh python3-pip texinfo boost-static boost-program-options git make autoconf automake libtool  zlib-devel zlib-static python3-pip  cmake nasm xz-devel  libjpeg-turbo-devel wget libarchive-devel glib2-devel libxml2-devel libgcrypt-devel openssl-devel zlib-devel bzip2-devel xz-devel libvorbis-devel libogg-devel ragel-devel nasm autoconf-archive dbus-devel readline-devel lcov subversion rsync lzma && pip3 install pylddwrap && yum -y install perl-CPAN perl-IPC-Cmd

 

COPY misc/magma  /work/magma
WORKDIR /work/magma
ENV ASAN_OPTIONS="detect_leaks=0"
RUN ./build_magma_bc.sh
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++.a /usr/lib64/dfsan_libc++.a
COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++abi.a /usr/lib64/dfsan_libc++abi.a
COPY --from=icount-libcxx /usr/lib64/icount_libc++.a /usr/lib64/icount_libc++.a
COPY --from=icount-libcxx /usr/lib64/icount_libc++abi.a /usr/lib64/icount_libc++abi.a
COPY --from=gllvm /go/bin/get-bc /usr/bin/get-bc
ENV LD_LIBARY_PATH=/usr/local/lib64
RUN python3 build_magma_ab.py
RUN ./build_magma_ab.sh



### unibench bitcode
FROM base-builder AS unibench
WORKDIR /work
COPY --from=gllvm /go/bin /usr/bin
RUN dnf install -y --refresh python3-pip texinfo boost-static boost-program-options git make autoconf automake libtool  zlib-devel zlib-static python3-pip  cmake nasm xz-devel  libjpeg-turbo-devel wget libarchive-devel glib2-devel libxml2-devel libgcrypt-devel openssl-devel zlib-devel bzip2-devel xz-devel libvorbis-devel libogg-devel ragel-devel nasm autoconf-archive dbus-devel readline-devel lcov subversion rsync lzma && pip3 install pylddwrap && yum -y install perl-CPAN perl-IPC-Cmd
RUN dnf install -y --refresh texinfo zip flex bison findutils glib2-devel gtk-doc libtiff-devel libpng-devel nasm boost-static boost-program-options && yum install -y expat expat-devel libpcap libpcap-devel libjpeg libjpeg-devel
COPY misc/unibench /work/unibench
WORKDIR /work/unibench
RUN  ./build_unibench_bc.sh
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++.a /usr/lib64/dfsan_libc++.a
COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++abi.a /usr/lib64/dfsan_libc++abi.a
COPY --from=icount-libcxx /usr/lib64/icount_libc++.a /usr/lib64/icount_libc++.a
COPY --from=icount-libcxx /usr/lib64/icount_libc++abi.a /usr/lib64/icount_libc++abi.a
COPY --from=gllvm /go/bin/get-bc /usr/bin/get-bc
ENV LD_LIBARY_PATH=/usr/local/lib64
RUN python3 gen_abilist.py
RUN ./build_unibench_ab.sh  



###### Google fuzzer test suite source
###FROM downloader AS google-src
###WORKDIR /work
###RUN git clone https://github.com/google/fuzzer-test-suite.git
####COPY misc/google/fuzzer-test-suite fuzzer-test-suite/
###COPY misc/google/build.sh /work/fuzzer-test-suite/build.sh
###COPY misc/google/001-fedora-build.patch /work/fuzzer-test-suite/
###RUN cd fuzzer-test-suite && git apply 001-fedora-build.patch

### GSS build, because apparently not in fedora repo
FROM base AS gss-build
RUN dnf install -y --refresh \
        gcc \
        make \
        wget
WORKDIR /work
RUN wget ftp://ftp.gnu.org/gnu/gss/gss-1.0.3.tar.gz && \
    tar xf gss-1.0.3.tar.gz && \
    rm gss-1.0.3.tar.gz && \
    mv gss-1.0.3 gss && \
    cd gss && \
    ./configure --prefix=/usr --libdir=/usr/lib64 && \
    make -j

###### Google fuzzer test suite bitcode
###FROM base-builder AS google-build
###RUN dnf install -y --refresh \
###        libcxx libcxx-devel \
###        libtool \
###        which \
###        golang \
###        libarchive-devel glib2-devel libxml2-devel libgcrypt-devel \
###        openssl-devel zlib-devel bzip2-devel xz-devel \
###        libvorbis-devel libogg-devel ragel-devel nasm \
###        autoconf-archive dbus-devel readline-devel lcov subversion rsync
###COPY --from=gss-build /work/gss /work/gss
###RUN cd /work/gss && make install
###COPY --from=google-src /work/fuzzer-test-suite /work/fuzzer-test-suite
###COPY --from=gllvm /go/bin/gclang /usr/bin/gclang
###COPY --from=gllvm /go/bin/gclang++ /usr/bin/gclang++
###COPY --from=llvm-project-src /work/llvm-project /work/llvm-project/
###WORKDIR /work/build-test-suite
###COPY misc/google/gen_library_abilist.sh /work/build-test-suite
###COPY misc/google/build_fuzzer_test_suite.py /work/build-test-suite/build_fuzzer_test_suite.py
###RUN python3 build_fuzzer_test_suite.py parallel
#### "${i%-afl}" delete right -afl from string i
#### ${i#RUNDIR-} delete left RUNDIR- from string i
###RUN rsync -avr --exclude=RUNDIR-*/BUILD --exclude=RUNDIR-*/SRC /work/build-test-suite/RUNDIR-* /work/google &&  cd /work/google && for i in RUNDIR-*;do j=${i#RUNDIR-}; mv -f "$i/$j-coverage" "${j%-coverage}" ;done

### Google fuzzer test suite analysis_binaries
###FROM google-build AS google
###RUN dnf install -y --refresh \
###        python3-pip \
###        boost-static \
###        boost-program-options && \
###    pip3 install pylddwrap
###COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
###RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
###COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++.a /usr/lib64/dfsan_libc++.a
###COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++abi.a /usr/lib64/dfsan_libc++abi.a
###COPY --from=icount-libcxx /usr/lib64/icount_libc++.a /usr/lib64/icount_libc++.a
###COPY --from=icount-libcxx /usr/lib64/icount_libc++abi.a /usr/lib64/icount_libc++abi.a
###COPY --from=gllvm /go/bin/get-bc /usr/bin/get-bc
###COPY misc/google/llvm.cpp llvm.cpp
###COPY misc/google/llvm.c llvm.c
###COPY misc/google/build_fuzzer_test_suite_bc.py /work/build-test-suite/build_fuzzer_test_suite_bc.py
###ENV LD_LIBARY_PATH=/usr/local/lib64
###RUN python3 build_fuzzer_test_suite_bc.py



### Google fuzzbench bitcode
### FROM base-builder AS fuzzbench-build
### RUN dnf install -y --refresh \
###         libcxx libcxx-devel \
###         libtool \
###         which \
###         golang \
###         libarchive-devel glib2-devel libxml2-devel libgcrypt-devel \
###         openssl-devel zlib-devel bzip2-devel xz-devel \
###         libvorbis-devel libogg-devel ragel-devel nasm \
###         autoconf-archive dbus-devel readline-devel lcov subversion rsync
### COPY --from=gss-build /work/gss /work/gss
### RUN cd /work/gss && make install
### COPY misc/google/fuzzbench /work/fuzzbench
### COPY misc/google/build.sh /work/fuzzbench/build.sh
### COPY --from=gllvm /go/bin/gclang /usr/bin/gclang
### COPY --from=gllvm /go/bin/gclang++ /usr/bin/gclang++
### COPY --from=llvm-project-src /work/llvm-project /work/llvm-project/
### WORKDIR /work/build_fuzzbench
### ENV ASAN_OPTIONS="detect_leaks=0"
### COPY misc/google/gen_library_abilist.sh /work/build_fuzzbench
### COPY misc/google/build_fuzzbench.py /work/build_fuzzbench/build_fuzzbench.py
### RUN python3 build_fuzzbench.py serial
### # "${i%-afl}" delete right -afl from string i
### # ${i#RUNDIR-} delete left RUNDIR- from string i
### RUN rsync -avr --exclude=RUNDIR-*/BUILD --exclude=RUNDIR-*/SRC /work/build_fuzzbench/RUNDIR-* /work/fuzzbench &&  cd /work/fuzzbench && for i in RUNDIR-*;do j=${i#RUNDIR-}; mv -f "$i/$j-coverage" "${j%-coverage}" ;done


# Google fuzzer test suite analysis_binaries
### FROM fuzzbench-build AS fuzzbench
### RUN dnf install -y --refresh \
###         python3-pip \
###         boost-static \
###         boost-program-options && \
###     pip3 install pylddwrap
### COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
### RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
### COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++.a /usr/lib64/dfsan_libc++.a
### COPY --from=dfsan-libcxx /usr/lib64/dfsan_libc++abi.a /usr/lib64/dfsan_libc++abi.a
### COPY --from=icount-libcxx /usr/lib64/icount_libc++.a /usr/lib64/icount_libc++.a
### COPY --from=icount-libcxx /usr/lib64/icount_libc++abi.a /usr/lib64/icount_libc++abi.a
### COPY --from=gllvm /go/bin/get-bc /usr/bin/get-bc
### WORKDIR /work/build_fuzzbench
### COPY misc/google/llvm.cpp llvm.cpp
### COPY misc/google/llvm.c llvm.c
### COPY misc/google/build_fuzzbench_bc.py build_fuzzbench_bc.py
### ENV LD_LIBARY_PATH=/usr/local/lib64
### RUN python3 build_fuzzbench_ab.py


### Framework
FROM base-builder AS framework
RUN dnf install -y --refresh \
        cargo \
        protobuf-compiler \
        sqlite-devel \
        zeromq-devel
COPY  framework /work/collab-fuzz/framework/
WORKDIR /work/collab-fuzz/framework
RUN cargo install --root /work/.local --locked --path .

### Base runtime image
FROM base AS runtime
RUN dnf install -y --refresh zeromq
WORKDIR /work
COPY --from=llvm-passes /work/llvm-passes/build/AnalysisPasses-0.1.1-Linux.sh /work
RUN /work/AnalysisPasses-0.1.1-Linux.sh --skip-license --prefix=/usr
RUN mkdir /in
RUN mkdir /data
COPY docker/server/entry.sh /entry.sh
RUN mkdir analysis_binaries
ENV INPUT_DIR=in OUTPUT_DIR=out ANALYSIS_BIN_DIR=/work/analysis_binaries/ SCHEDULER=casefc
ENV LD_LIBRARY_PATH=/usr/local/lib64
ENV PATH=/work/.local/bin/:$PATH
CMD ["/entry.sh"]


                      
### Framework + all:lava,binutils,putzxy,unibench,google
FROM runtime AS framework-all
RUN dnf install -y --refresh \
        make \
        libcxx \
        libarchive glib2 libxml2 libgcrypt \
        openssl zlib bzip2 xz \
        libvorbis libogg ragel nasm \
        autoconf dbus readline lcov iputils
COPY --from=gss-build /work/gss /work/gss
RUN cd /work/gss && make install
#COPY --from=google /work/analysis_binaries /work/analysis_binaries/
#COPY --from=google /work/google /work/google
#COPY --from=lava /work/lava /work/lava
#COPY --from=lava /work/analysis_binaries /work/analysis_binaries/
COPY --from=binutils /work/analysis_binaries /work/analysis_binaries/
COPY --from=binutils /work/binutils  /work/binutils
#COPY --from=putzxy /work/analysis_binaries /work/analysis_binaries/

# zhaoxy add putonemp3gain
#COPY --from=putone /work/analysis_binaries /work/analysis_binaries/
#COPY --from=putone /work/targets/afl-putone /work/putone
#COPY --from=unibench /work/analysis_binaries /work/analysis_binaries/
#COPY --from=unibench /work/targets/afl-unibench /work/unibench
COPY --from=framework /work/.local/bin/collab_fuzz_server \
                      /work/.local/bin/collab_fuzz_server
COPY --from=framework /work/.local/bin/collab_fuzz_pass_runner \
                      /work/.local/bin/collab_fuzz_pass_runner
COPY --from=magma /work/magma /work/magma
COPY --from=magma /work/analysis_binaries /work/analysis_binaries/
COPY --from=unibench /work/unibench /work/unibench
COPY --from=unibench /work/analysis_binaries /work/analysis_binaries/
#COPY --from=fuzzbench /work/fuzzbench /work/fuzzbench
#COPY --from=fuzzbench /work/analysis_binaries /work/analysis_binaries/
                   
# zhaoxy add for framework image simplication end  












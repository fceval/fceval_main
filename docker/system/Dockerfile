FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive   && apt-get update  && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  && dpkg-reconfigure --frontend noninteractive tzdata
ENV GOPROXY='https://mirrors.aliyun.com/goproxy/' GO111MODULE=on DEBIAN_FRONTEND=noninteractive
RUN (sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list && sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list)   &&\
    apt-get update -y \
    &&  apt-get install -y --reinstall ca-certificates && apt-get install -y wget make build-essential gcc libbfd-dev libunwind-dev libipt-dev binutils-dev git libtool libtool-bin automake bison libglib2.0-dev python python-pip cmake curl libc-ares-dev libfreetype6-dev libarchive-dev ragel bzip2 libgss-dev subversion libgcrypt-dev autoconf-archive virtualenv libdbus-glib-1-dev libgirepository1.0-dev libturbojpeg libssh-dev libssl-dev nasm libbz2-dev libxml2-dev software-properties-common libacl1-dev sudo && env python -m pip install -U pip && env python -m pip install -U setuptools && pip install watchdog && env python -m pip install watchdog && add-apt-repository -y ppa:longsleep/golang-backports && apt-get update && apt-get install -y --reinstall ca-certificates && apt-get install -y golang-go && GO111MODULE=off go get github.com/SRI-CSL/gllvm/cmd/... &&  mkdir /targets
 

WORKDIR /work
#COPY compiler-rt-9.0.1.src.tar.xz compiler-rt-9.0.1.src.tar.xz
#COPY fuzzer-test-suite fuzzer-test-suite/
#COPY fuzzbench fuzzbench/
#COPY binutils-2.31.1.tar.gz binutils-2.31.1.tar.gz
COPY lava_corpus.tar.xz lava_corpus.tar.xz
COPY afl-2.56b.tar.gz afl-2.56b.tar.gz
COPY unibench unibench/
COPY putone putone/
COPY google google
COPY aflplusplus_3.11c.tar.gz aflplusplus_3.11c.tar.gz
COPY checkout_build_install_llvm.sh checkout_build_install_llvm.sh
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/binutils/binutils-2.26.1.tar.gz && tar xfv afl-2.56b.tar.gz && mv AFL-2.56b afl && wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/compiler-rt-12.0.1.src.tar.xz --no-check-certificate && ./checkout_build_install_llvm.sh && tar xfv compiler-rt-12.0.1.src.tar.xz && cd compiler-rt-12.0.1.src/lib/fuzzer && \
    bash build.sh && \
    cp libFuzzer.a /usr/lib && \
    cp libFuzzer.a /work/
WORKDIR /work/afldriver
RUN clang -Wno-pointer-sign -c /work/afl/llvm_mode/afl-llvm-rt.o.c -I/work/afl && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /work/compiler-rt-12.0.1.src/lib/fuzzer/afl/afl_driver.cpp && \
    ar r /libAFL.a *.o












###FROM fuzzer-system:aflplusplus AS fuzzer-aflplusplus-binutils
###ENV CC=afl-clang-fast CXX=afl-clang-fast++

# build binutils 
###WORKDIR  /work
###RUN mkdir -p /targets/aflplusplus-binutils && tar xfv binutils-2.26.1.tar.gz && cd binutils-2.26.1/ && ./configure --prefix=/targets/aflplusplus-binutils/ && make -j`nproc` && make install


###FROM fuzzer-system:aflplusplus AS fuzzer-aflplusplus-google

###ENV CC=clang CXX=clang++

###WORKDIR  /work
#### build fuzzer-test-suite
###RUN apt-get update && apt-get install -y libarchive-dev libxml2-dev libgcrypt-dev libssl-dev libbz2-dev liblzma-dev libvorbis-dev libogg-dev  nasm autoconf-archive lcov subversion zlib1g-dev libdbus-1-dev pkg-config wget rsync
#### && git clone https://github.com/google/fuzzer-test-suite.git && cd fuzzer-test-suite && git checkout b2e885706d6
###COPY build.sh fuzzer-test-suite/build.sh
###COPY fuzzer-test-suite/common.sh fuzzer-test-suite/common.sh 
####COPY  aflplusplus-google.patch fuzzer-test-suite/aflplusplus-google.patch
####RUN cd fuzzer-test-suite && git apply aflplusplus-google.patch
###RUN mkdir build-test-suite
###COPY  build_fuzzer_test_suite.py build-test-suite/build_fuzzer_test_suite.py
###RUN cd build-test-suite && python build_fuzzer_test_suite.py
###RUN mkdir /targets/aflplusplus-google && find . -name "*-afl" -executable | xargs cp -t  /targets/aflplusplus-google/  && rsync -avr --exclude=RUNDIR-*/BUILD --exclude=RUNDIR-*/SRC build-test-suite/RUNDIR-* /targets/aflplusplus-google &&  cd /targets/aflplusplus-google && for i in *-afl;do mv "$i" "${i%-afl}" ;done
####RUN cp -r build-test-suite/RUNDIR-*/seeds /inputs/google



###FROM fuzzer-system:aflplusplus AS fuzzer-aflplusplus-lava

###ENV CC=afl-clang-fast CXX=afl-clang-fast++

# build LAVA-M
###WORKDIR  /work
###RUN mkdir -p /targets/aflplusplus-lava && tar xfv lava_corpus.tar.xz
####RUN wget http://panda.moyix.net/~moyix/lava_corpus.tar.xz && tar xfv lava_corpus.tar.xz
####RUN tar xfv lava_corpus.tar.xz
###COPY build_lava.sh build_lava.sh
###COPY coreutils-8.24-on-glibc-2.28.patch coreutils-8.24-on-glibc-2.28.patch
###RUN FORCE_UNSAFE_CONFIGURE=1 ./build_lava.sh


###FROM fuzzer-system:aflplusplus AS fuzzer-aflplusplus-putone
###ENV CC=afl-clang-fast CXX=afl-clang-fast++
#### build putone
###WORKDIR  /work
###COPY build_putone.sh build_putone.sh
###RUN FORCE_UNSAFE_CONFIGURE=1 ./build_putone.sh
 
###FROM fuzzer-system:aflplusplus AS fuzzer-aflplusplus-unibench
###ENV CC=afl-clang-fast CXX=afl-clang-fast++
#### build unibench
###WORKDIR  /work
###COPY build_unibench.sh build_unibench.sh
###RUN FORCE_UNSAFE_CONFIGURE=1 ./build_unibench.sh


#FROM fuzzer-system:aflplusplus
FROM magma/aflplusplus/libpng
USER root
#ENV DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive   && apt-get update  && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  && dpkg-reconfigure --frontend noninteractive tzdata
RUN rm -rf /work && apt-get update && apt-get install -y build-essential python2.7-dev python3.7-dev python3-dev automake flex bison libglib2.0-dev libpixman-1-dev python3-setuptools  gcc-$(gcc --version|head -n1|sed 's/.* //'|sed 's/\..*//')-plugin-dev libstdc++-$(gcc --version|head -n1|sed 's/.* //'|sed 's/\..*//')-dev  libasound2-dev libflac-dev libogg-dev libtool libvorbis-dev libopus-dev libmp3lame-dev libmpg123-dev nasm zlib1g-dev liblzma-dev libjpeg-turbo8-dev libreadline-dev 

#COPY --from=fuzzer-aflplusplus-binutils /targets/aflplusplus-binutils /targets/binutils
#COPY --from=fuzzer-aflplusplus-lava /targets/aflplusplus-lava /targets/lava
#RUN apt-get update && apt-get install -y libarchive-dev libglib2.0 libgss3
#COPY --from=fuzzer-aflplusplus-google /targets/aflplusplus-google /targets/google
#COPY --from=fuzzer-aflplusplus-unibench /targets/aflplusplus-unibench /targets/unibench

#COPY --from=fuzzer-aflplusplus-putone /targets/aflplusplus-putone /targets/putone

COPY magma /targets/magma
COPY magma/binutils /targets/binutils
COPY magma/unibench /targets/unibench
WORKDIR /work




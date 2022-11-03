#!/bin/bash
set -euo pipefail

export CC="gclang"
export CXX="gclang++"

export CFLAGS="-fprofile-instr-generate -fcoverage-mapping"
export CXXFLAGS="-fprofile-instr-generate -fcoverage-mapping"
export LDFLAGS="-fprofile-instr-generate -fcoverage-mapping"

mkdir -p /work/magma-bc

#export LIBS="-l:StandaloneFuzzTargetMain.o -lstdc++"
cd /work/magma/libpng/libpng
mkdir -p /targets/magma/libpng
autoreconf -f -i
CC=gclang CXX=gclang++ ./configure --with-libpng-prefix=MAGMA_ --disable-shared
make -j$(nproc) clean
make -j$(nproc) libpng16.la

cp .libs/libpng16.a /targets/magma/libpng/

# compile standalone driver
$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o /targets/magma/libpng/StandaloneFuzzTargetMain.o
    
# build libpng_read_fuzzer. -l:magma.o

gclang++ -std=c++11 -I. \
     contrib/oss-fuzz/libpng_read_fuzzer.cc  \
     -o /targets/magma/libpng/libpng \
     -L/targets/magma/libpng -g .libs/libpng16.a  -lrt -lz -l:StandaloneFuzzTargetMain.o -lstdc++
cd /targets/magma/libpng
get-bc libpng
cp libpng.bc /work/magma-bc/


##build for libtiff
##export LIBS="-l:StandaloneFuzzTargetMain.o -lstdc++"
#cd /work/magma/libtiff/libtiff
#mkdir -p /targets/magma/libtiff
#./autogen.sh
#CC=gclang CXX=gclang++ ./configure --disable-shared --prefix=/targets/magma/libtiff
#make -j$(nproc) clean
#make -j$(nproc)
#make install

# compile standalone driver
#$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o /targets/magma/libtiff/StandaloneFuzzTargetMain.o

#$CXX $CXXFLAGS -std=c++11 -I/targets/magma/libtiff/include \
#    contrib/oss-fuzz/tiff_read_rgba_fuzzer.cc -o /targets/magma/libtiff/libtiff \
#    -L/targets/magma/libtiff -g /targets/magma/libtiff/lib/libtiffxx.a /targets/magma/libtiff/lib/libtiff.a -lz -ljpeg -llzma -l:StandaloneFuzzTargetMain.o -lstdc++

#cd /targets/magma/libtiff
#get-bc libtiff




#build for libxml2
cd /work/magma/libxml2/libxml2
mkdir -p /targets/magma/libxml2
./autogen.sh --with-http=no --with-python=no --with-lzma=yes --with-threads=no --disable-shared
make -j$(nproc) clean
make -j$(nproc) all
cp .libs/libxml2.a /targets/magma/libxml2/
# compile standalone driver
$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o /targets/magma/libxml2/StandaloneFuzzTargetMain.o

$CXX $CXXFLAGS -std=c++11 -Iinclude/ -I/work/magma/libxml2/src/ \
      /work/magma/libxml2/src/libxml2_xml_read_memory_fuzzer.cc -o /targets/magma/libxml2/libxml2 \
      -L/targets/magma/libxml2 -g .libs/libxml2.a  -lz -llzma -l:StandaloneFuzzTargetMain.o -lstdc++

cd /targets/magma/libxml2
get-bc libxml2



#build for lua
cd /work/magma/lua/lua
mkdir -p /targets/magma/lua
make -j$(nproc) clean
make -j$(nproc) liblua.a
cp liblua.a /targets/magma/lua/
# compile standalone driver
$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o /targets/magma/lua/StandaloneFuzzTargetMain.o

# build driver
make -j$(nproc) lua
cp lua  /targets/magma/lua/


#$CXX $CXXFLAGS -std=c++11 -Iinclude/ -I/work/magma/libxml2/src/ \
#      /work/magma/libxml2/src/libxml2_xml_read_memory_fuzzer.cc -o /targets/magma/libxml2/libxml2 \
#      -L/targets/magma/libxml2 -g .libs/libxml2.a  -lz -llzma -l:StandaloneFuzzTargetMain.o -lstdc++

cd /targets/magma/lua
get-bc lua


#build for openssl
cd /work/magma/openssl/openssl
mkdir -p /targets/magma/openssl
# the config script supports env var LDLIBS instead of LIBS
$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o /targets/magma/openssl/StandaloneFuzzTargetMain.o
$CC -c ../StandaloneFuzzTargetMain.c -fPIC -o StandaloneFuzzTargetMain.o
export LDLIBS="-L/targets/magma/openssl -l:StandaloneFuzzTargetMain.o -lstdc++"
CC=gclang CXX=gclang++ ./config --debug enable-fuzz-libfuzzer enable-fuzz-afl disable-tests -DPEDANTIC \
    -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION no-shared no-module \
    enable-tls1_3 enable-rc5 enable-md2 enable-ec_nistp_64_gcc_128 enable-ssl3 \
    enable-ssl3-method enable-nextprotoneg enable-weak-ssl-ciphers \
    $CFLAGS -fno-sanitize=alignment
make -j$(nproc) clean
make -j$(nproc) LDCMD="$CXX $CXXFLAGS"

cp libcrypto.a /targets/magma/openssl/libcrypto.a
cp libssl.a /targets/magma/openssl/libssl.a
fuzzers=$(find fuzz -executable -type f '!' -name \*.py '!' -name \*-test '!' -name \*.pl)
for f in $fuzzers; do
    fuzzer=$(basename $f)
    cp $f /targets/magma/openssl/
done
cp /targets/magma/openssl/x509 /targets/magma/openssl/openssl
cd /targets/magma/openssl
get-bc openssl


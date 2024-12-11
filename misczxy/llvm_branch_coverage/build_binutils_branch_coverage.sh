#!/bin/bash
set -euo pipefail
export CFLAGS="-fprofile-instr-generate -fcoverage-mapping  -O1 -fno-omit-frame-pointer -g"
export CXXFLAGS="-fprofile-instr-generate -fcoverage-mapping  -O1 -fno-omit-frame-pointer -g"
export CC=clang 
export CXX=clang++ 
export LIBCFLAGS=$CFLAGS
export ASAN_OPTIONS=detect_leaks=0

#CFLAGS="-fsanitize=address -DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -g -Wno-error" LDFLAGS="-ldl -lutil" ../configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-ld


#wget https://ftp.gnu.org/gnu/binutils/binutils-2.26.1.tar.gz && tar xfv binutils-2.26.1.tar.gz
cd binutils-2.26.1/ 
#./configure --prefix="$(pwd)/binutils-prefix/"
./configure --disable-gdb --disable-gdbserver --disable-gdbsupport \
	    --disable-libdecnumber --disable-readline --disable-sim \
	    --disable-libbacktrace --disable-gas --disable-ld --disable-werror \
      --enable-targets=all  --prefix="$(pwd)/binutils-prefix/"
make clean
#make MAKEINFO=true
make MAKEINFO=true -j"$(nproc)"
make install

mkdir -p /work/binutils/branch_coverage
cd binutils-prefix/bin/
for t in *; do (
#    get-bc "$t"
    mv "$t" /work/binutils/branch_coverage/
    ) &
done;
wait;

unset CFLAGS CXXFLAGS  CC  CXX LIBCFLAGS ASAN_OPTIONS

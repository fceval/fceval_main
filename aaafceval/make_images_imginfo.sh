#!/usr/bin/env bash

set -e

#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

#fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "qsym" "radamsa" "honggfuzz" "libfuzzer" "radamsa" "parmesan" "symcc")
fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "mopt" "symcc")
#bms=("ld" "nm" "objdump" "readelf" "libpng" "size" "libtiff" "libxml2" "lua" "openssl")
bms=("imginfo")
cur_dir=$(pwd)
for fuzzer in ${fuzzers[@]}
do
	for bm in ${bms[@]}
	do
	    echo "${fuzzer}---${bm}"
	    cd $cur_dir/../docker/${fuzzer}
	    python3 afl_setting.py
	    echo $pwd
	    collab_fuzz_build -f $fuzzer -t $bm
	done
done



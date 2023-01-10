#!/bin/bash
set -e

fuzzers=("casefc" "enfuzz")
#bms=("binutils") # "imginfo"
bms=("nm" "objdump" "readelf" "libpng" "libxml2" "openssl" "lua" "cflow" "jq" "mp42aac" "size" "strings" "strip") # "imginfo"
#fuzzers=("afl" "aflplusplus" "aflfast")
#parmesan php sqlite3 error
#bms=("libtiff")
# Build the docker image for AFL and a Magma target (e.g., libpng)

 
for fuzzer in ${fuzzers[@]}
do
	for bm in ${bms[@]}
	do
		cd $bm$fuzzer
		collab_fuzz_run ./experiment.yml
		cd ..
	done
done

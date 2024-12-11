#!/usr/bin/env bash

set -e

source ../venv/bin/activate
#bms=("ld" "nm" "objdump" "readelf" "libpng" "libxml2" "lua" "openssl"   "cflow" "jq" "exiv2" "mp42aac")
bms=("ld" "nm" "objdump" "readelf" "libpng" "libxml2" "lua" "openssl"   "cflow" "jq" "exiv2" "mp42aac")
curdir=$(pwd)
for bm in ${bms[@]}
do
    cd $curdir
    echo "${bm}${curdir}"
    cd ../runners/exp${bm}/fca && collab_fuzz_run ./experiment.yml && cd ../fcb && collab_fuzz_run ./experiment.yml && cd ../../exp${bm}_enfuzz/fca && collab_fuzz_run ./experiment.yml
done



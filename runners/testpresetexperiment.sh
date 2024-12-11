#!/usr/bin/env bash

set -e

 
fuzzers=("expstrip" "expnm" "expstrings" "expsize" "expreadelf" "expobjdump")
for fuzzer in ${fuzzers[@]}
do
    echo ${fuzzer}
    cd ~/zhaoxy/casefs/runners/${fuzzer}
    ./testpreset.sh
    echo $pwd
done



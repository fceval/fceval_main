#!/bin/bash
set -euo pipefail
if [ ! -d "/work/analysis_binaries" ]; then
  mkdir /work/analysis_binaries
fi

cd /work/unibench-bc
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor putzxy start"
    echo $fb
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    mkdir "$fb".analysis_binaries
    echo "$fb.analysis_binaries" 
    echo "$t"
    echo "zxytestfor putzxy end"
    #add -lm for compile error
    collab_fuzz_wrapper  --custom-abilist /work/unibench-bc/custom_abilist.txt "$fb.analysis_binaries" "$t" -ldl -lz -lpthread -lexpat -lpcap -lm -lncurses -ljpeg
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
    ls /work/analysis_binaries
done

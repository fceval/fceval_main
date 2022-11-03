#!/bin/bash
export PARMESAN_BASE=/work/parmesan
source $PARMESAN_BASE/parmesan.env

targets=("nm" "objdump" "readelf" "size" "strings" "strip")
cd /targets/parmesan-binutils/bcfirst/bin/
#for t in *; do (
for t in ${targets[@]}; do ( 
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /targets/parmesan-binutils/full/
    python3 $PARMESAN_BASE/tools/compile_bc_zxy.py binutils "$t".bc -s -d @@
    )
done;

 


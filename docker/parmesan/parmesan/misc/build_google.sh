#!/bin/bash
export PARMESAN_BASE=/work/parmesan
source $PARMESAN_BASE/parmesan.env


cd /targets/parmesan-google/bcfirst/
for t in *; do (
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /targets/parmesan-google/full/
    python3 $PARMESAN_BASE/tools/compile_bc_zxy.py binutils "$t".bc -s -d @@
    )
done;

 


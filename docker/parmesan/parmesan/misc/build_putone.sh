#!/bin/bash
export PARMESAN_BASE=/work/parmesan
source $PARMESAN_BASE/parmesan.env


cd /targets/parmesan-putone/bcfirst
for t in *; do (
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /targets/parmesan-putone/full/
    python3 $PARMESAN_BASE/tools/compile_bc_zxy.py putone "$t".bc -s -d @@
    )
done;

 


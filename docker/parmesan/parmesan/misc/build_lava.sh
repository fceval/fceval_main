#!/bin/bash
export PARMESAN_BASE=/work/parmesan
source $PARMESAN_BASE/parmesan.env

targets={base64  md5sum who uniq}
cd /targets/parmesan-lava/bcfirst/bin/
#for t in *; do (
for t in ${targets[@]}; do ( 
    echo "zxy dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /targets/parmesan-lava/full/
    python3 $PARMESAN_BASE/tools/compile_bc_zxy.py lava "$t".bc -s -d @@
    )
done;

 


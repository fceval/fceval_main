#!/bin/bash
export PARMESAN_BASE=/work/parmesan
source $PARMESAN_BASE/parmesan.env
# libtiff libxml2 openssl
targets={libpng}
cd /targets/parmesan-magma/bcfirst
#for t in *; do (
for t in ${targets[@]}; do ( 
    echo "zxy magma dbg bcget $t"
    get-bc "$t"
    mv "$t".bc /targets/parmesan-magma/full/
    python3 $PARMESAN_BASE/tools/compile_bc_zxy.py magma "$t".bc -s -d @@
    )
done;

 


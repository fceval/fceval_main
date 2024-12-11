#!/bin/bash
set -euo pipefail
if [ ! -d "/work/analysis_binaries" ]; then
  mkdir /work/analysis_binaries
fi

cd /targets/magma/libpng
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor magma libpng"
    echo "$fb"
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm  magma start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm magma end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    if [ -d "$fb.analysis_binaries" ]; then
        rm -rf "$fb.analysis_binaries" 
        mkdir "$fb.analysis_binaries"
    fi
    #/work/magma/gen_library_abilist.sh libz.so* discard >> /targets/magma/libpng/custom_abilist.txt
    #ldd /usr/lib64/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /work/magma/gen_library_abilist.sh '{}' discard >> /targets/magma/libpng/custom_abilist.txt
    echo "$fb.analysis_binaries" 
    echo "$t"
    #add -lm for compile error
    collab_fuzz_wrapper --custom-abilist /targets/magma/libpng/custom_abilist.txt "$fb.analysis_binaries" "$t" -L/usr/lib64 -L/targets/magma/libpng -g  -lrt -lz -lm -l:libpng16.a -l:dfsan_libc++.a -l:StandaloneFuzzTargetMain.o
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
done


cd /targets/magma/libtiff
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor magma libtiff"
    echo "$fb"
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm  magma start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm magma end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    if [ -d "$fb.analysis_binaries" ]; then
        rm -rf "$fb.analysis_binaries" 
        mkdir "$fb.analysis_binaries"
    fi
    #/work/magma/gen_library_abilist.sh libz.so* discard >> /targets/magma/libpng/custom_abilist.txt
    #ldd /usr/lib64/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /work/magma/gen_library_abilist.sh '{}' discard >> /targets/magma/libpng/custom_abilist.txt
    echo "$fb.analysis_binaries" 
    echo "$t"
    #add -lm for compile error
    collab_fuzz_wrapper --custom-abilist /targets/magma/libtiff/custom_abilist.txt "$fb.analysis_binaries" "$t" -L/usr/lib64 -L/targets/magma/libtiff  -L/targets/magma/libtiff/lib -g  -lm -lz -ljpeg -llzma -l:libtiff.a -l:libtiffxx.a -l:dfsan_libc++.a -l:StandaloneFuzzTargetMain.o
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
done


cd /targets/magma/libxml2
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor magma libxml2"
    echo "$fb"
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm  magma start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm magma end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    if [ -d "$fb.analysis_binaries" ]; then
        rm -rf "$fb.analysis_binaries" 
        mkdir "$fb.analysis_binaries"
    fi
    #/work/magma/gen_library_abilist.sh libz.so* discard >> /targets/magma/libpng/custom_abilist.txt
    #ldd /usr/lib64/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /work/magma/gen_library_abilist.sh '{}' discard >> /targets/magma/libpng/custom_abilist.txt
    echo "$fb.analysis_binaries" 
    echo "$t"
    #add -lm for compile error
    collab_fuzz_wrapper --custom-abilist /targets/magma/libxml2/custom_abilist.txt "$fb.analysis_binaries" "$t" -L/usr/lib64 -L/targets/magma/libxml2 -g  -lz -llzma -lm -l:libxml2.a -l:dfsan_libc++.a -l:StandaloneFuzzTargetMain.o
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
done


cd /targets/magma/lua
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor magma lua"
    echo "$fb"
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm  magma start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm magma end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    if [ -d "$fb.analysis_binaries" ]; then
        rm -rf "$fb.analysis_binaries" 
        mkdir "$fb.analysis_binaries"
    fi
    #/work/magma/gen_library_abilist.sh libz.so* discard >> /targets/magma/libpng/custom_abilist.txt
    #ldd /usr/lib64/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /work/magma/gen_library_abilist.sh '{}' discard >> /targets/magma/libpng/custom_abilist.txt
    echo "$fb.analysis_binaries" 
    echo "$t"
    #add -lm for compile error
    collab_fuzz_wrapper --custom-abilist /targets/magma/lua/custom_abilist.txt "$fb.analysis_binaries" "$t" -L/usr/lib64  -g  -lz -llzma -lm -ldl -lreadline -l:dfsan_libc++.a
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
done


cd /targets/magma/openssl
# XXX: the following OOMs on 16GB if run in parallel
for t in ./*.bc; do
    fb=$(basename -s .bc "$t")
    echo "zxytestfor magma openssl"
    echo "$fb"
    ls /usr/lib64/libInst*
    #grep -C 20 "fmaf" /usr/lib64/libInstCountWrapperRT.so
    ldd /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm  magma start"
    nm  -C -u /usr/lib64/libInstCountWrapperRT.so
    echo "zxy nm magma end"
    # cat /usr/lib64/libInstCountWrapperRT.so
    if [ -d "$fb.analysis_binaries" ]; then
        rm -rf "$fb.analysis_binaries" 
        mkdir "$fb.analysis_binaries"
    fi
    #/work/magma/gen_library_abilist.sh libz.so* discard >> /targets/magma/libpng/custom_abilist.txt
    #ldd /usr/lib64/*|grep .so|awk '{print $3}'|grep .so|sort|uniq|sed 's#^/lib#/usr/lib#g'|sed 's#\.so.*$#.so#g'|grep -v libgcc_s.so|grep -v libstdc++.so|grep -v libc.so|grep -v libm.so|grep -v libpthread.so|xargs -i /work/magma/gen_library_abilist.sh '{}' discard >> /targets/magma/libpng/custom_abilist.txt
    echo "$fb.analysis_binaries" 
    echo "$t"
    #add -lm for compile error
    collab_fuzz_wrapper --custom-abilist /targets/magma/lua/custom_abilist.txt "$fb.analysis_binaries" "$t" -L/usr/lib64 -L/targets/magma/openssl  -g  -lz -llzma -lcrypto -ldl -pthread -lm  -l:dfsan_libc++.a  -l:StandaloneFuzzTargetMain.o -l:libcrypto.a -l:libssl.a
    mv "$fb".analysis_binaries /work/analysis_binaries/"$fb".analysis_binaries
done



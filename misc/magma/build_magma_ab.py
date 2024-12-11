#!/usr/bin/env python3
import os, sys
import lddwrap
import pathlib

mappings = {
    "libpng": "libpng",
#    "libtiff": "libtiff",
    "libxml2": "libxml2",
    "lua": "lua",
    "openssl": "openssl",        
}

inv_mappings = {v: k for k, v in mappings.items()}

targets = {
    "libpng": ("-L/usr/lib64 -L/targets/magma/libpng -g  -lrt -lz -lm", " -l:dfsan_libc++.a -l:libpng16.a -l:StandaloneFuzzTargetMain.o"),
#    "libtiff": ("-L/usr/lib64 -L/targets/magma/libtiff -g  -lz -ljpeg -llzma", " -l:dfsan_libc++.a -l:/targets/magma/libtiff/lib/libtiffxx.a -l:/targets/magma/libtiff/lib/libtiff.a -l:StandaloneFuzzTargetMain.o"),  
    "libxml2": ("-L/usr/lib64 -L/targets/magma/libxml2 -g  -lz -llzma -lm", " -l:dfsan_libc++.a -l:libxml2.a -l:StandaloneFuzzTargetMain.o"), 
    "lua": ("-L/usr/lib64 -g  -lz -llzma -lm", " -l:dfsan_libc++.a"),
    "openssl": ("-L/usr/lib64 -L/targets/magma/openssl -g  -lz -llzma -lm  -lcrypto -lssl -ldl -pthread", " -l:dfsan_libc++.a -l:libcrypto.a  -l:libssl.a -l:StandaloneFuzzTargetMain.o"),            
}


cxx_targets = [
 "libpng",
# "libtiff",
 "libxml2", 
 "lua",
 "openssl",  
]

LIB_BLACKLIST = [
    "libc++.so", "libc++abi.so", "libc.so", "libgcc_s.so", "libdl.so",
    "ld-linux-x86-64.so", "linux-vdso.so","librt.so","libm.so","libpthread.so","libstdc++.so"
]

NO_LLVM_CPP = ["proj4-2017-08-14"]


def so_in_blacklist(soname):
    if soname is None:
        return False
    return any(map(lambda x: x in soname, LIB_BLACKLIST))


def gen_abilist(target_bin):
    p = pathlib.Path(target_bin)
    print("gen_abilist111",p)
    r = lddwrap.list_dependencies(path=p, env=os.environ.copy())
    print("gen_abilist2222222",r)
    for dep in r:
        if (not dep.path or dep.found == False or dep.unused == True
                or not os.path.isabs(dep.path)):
            print("gen_abilist333333333")
            continue
        if dep.soname is None:
            print("gen_abilist4444")
            continue
        if so_in_blacklist(dep.soname):
            print("gen_abilist555555555",dep.soname) 
            continue

        print(f"gen_abilist666666:{dep.path}")
        ret = os.system(
            f"/work/magma/gen_library_abilist.sh {dep.path} discard >> /targets/magma/{target_bin}/custom_abilist.txt"
        )
        if ret != 0:
            print(f'Could not generate abilist for {target_bin}')
            sys.exit(1)


def main():
    for target in targets:
        old_cwd = os.getcwd()
        bdir = f"/targets/magma/{target}"
        os.chdir(bdir)
        os.system(f"get-bc {target}")
        flags, libs = targets[target]
        bc_file = f"{target}.bc"

        gen_abilist(target)

        cxx_flag = '--cxx' if target in cxx_targets else ''

        #if target not in NO_LLVM_CPP:
            #libs += ' /work/magma/llvm.c'
        print(f"main11111111111")
        cmd = (
             f'collab_fuzz_wrapper ' +
             f'--custom-abilist $(pwd)/custom_abilist.txt {cxx_flag} ' +
             f'/work/analysis_binaries/{target}.analysis_binaries '
             + f'{bc_file} {flags} {libs}')
        #ret = os.system(cmd)
        print(f"main222222222222")
        #if ret != 0:
        #    print(f"Error building {target}")
        #    print(cmd)
        #    sys.exit(1)
        os.chdir(old_cwd)


if __name__ == '__main__':
    main()

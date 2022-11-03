#!/usr/bin/env python
import sys
import os
from pathlib import Path

import logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)

SCRIPT_PATH = Path(os.path.dirname(__file__))
BIN_PATH = (Path(SCRIPT_PATH) / "../bin/").resolve()
FUZZER_PATH = BIN_PATH / "fuzzer"
CC_BIN = BIN_PATH / "angora-clang"
CXX_BIN = BIN_PATH / "angora-clang++"
DIFF_BIN = BIN_PATH / "llvm-diff-parmesan"
ID_ASSIGNER_PATH = BIN_PATH / "pass/libLLVMIDAssigner.so"
PRUNE_SCRIPT_PATH = SCRIPT_PATH / "prune.py"
#CFLAGS = os.environ.get("CFLAGS", "-fPIC") # -fPIC required for targets like binutils
#CXXFLAGS = os.environ.get("CXXFLAGS", "-fPIC") # -fPIC required for targets like binutils
CFLAGS = os.environ.get("CFLAGS", "-fpie -pie") # -fPIC required for targets like binutils
CXXFLAGS = os.environ.get("CXXFLAGS", "-fpie -pie") # -fPIC required for targets like binutils


def run_cmd(cmd):
    logging.info(f" + {cmd}")
    os.system(cmd)

def build_pipeline(binsuite,bc_file, target_flags="@@", profiling_input_dir="in", is_cpp=False):
    compiler = CXX_BIN if is_cpp else CC_BIN
    cflags = CXXFLAGS if is_cpp else CFLAGS
    name = os.path.splitext(bc_file)[0]
    sanitizer = "address"
    targets_file = f"targets_{name}.json"
    os.chdir(f"/targets/parmesan-{binsuite}/full")
    #1) BUILD FAST LL
    run_cmd(f"USE_FAST=1 {compiler} {cflags} -S -emit-llvm -o fast.ll.{name} {bc_file}")
    #2) BUILD FAST BIN
    run_cmd(f"USE_FAST=1 {compiler} {cflags} -o fast.{name} {bc_file}")
    #3) BUILD FAST SAN LL
    run_cmd(f"USE_FAST=1 {compiler} {cflags} -fsanitize={sanitizer} -S -emit-llvm -o san.ll.{name} {bc_file}")
    #4) BUILD FAST SAN BIN
    run_cmd(f"USE_FAST=1 {compiler} {cflags} -fsanitize={sanitizer} -o san.fast.{name} {bc_file}")
    #5) BUILD TRACK BIN
    run_cmd(f"USE_TRACK=1 {compiler} {cflags} -o track.{name} {bc_file}")
    #6) Gather targets.json and target.diff
    run_cmd(f"{DIFF_BIN} -json fast.ll.{name} san.ll.{name} 2> diff.{name}")
    run_cmd(f"mv targets.json {targets_file}")
    #7) Gather cmp.map
    run_cmd(f"opt -load {ID_ASSIGNER_PATH} -idassign -idassign-emit-cfg \
            -idassign-cfg-file cfg.dat fast.ll.{name}")
    #8) Prune targets
    run_cmd(f"python {PRUNE_SCRIPT_PATH} {targets_file} diff.{name} cmp.map {profiling_input_dir} track.{name} {target_flags} > targets_{name}.pruned.json")

    # Print fuzzing command
    print("You can now run your target application (with SanOpt enabled) using:")
    print()
    print(f"{FUZZER_PATH} -c ./targets_{name}.pruned.json -i {profiling_input_dir} -o out -t ./track.{name} -s ./san.fast.{name} -- ./fast.{name} {target_flags}")
    print()

def print_usage():
    print(f"Usage: {sys.argv[0]} binsuite BC_FILE [TARGET_PROG_CMD_FLAGS]")
    print("Where the BC_FILE is an llvm .bc file obtained by, for example, gclang.")

if __name__ == "__main__":
    orig_cwd = os.getcwd()
    if len(sys.argv) < 3:
        print_usage()
        sys.exit(1)
    if len(sys.argv) > 3:
        # Provide some target program flags (e.g., for objdump, give it -s -d)
        flags = ' '.join(sys.argv[3:])
        build_pipeline(sys.argv[1],sys.argv[2], target_flags=flags)
    else:
        build_pipeline(sys.argv[1],sys.argv[2])
    os.chdir(f"{orig_cwd}")    

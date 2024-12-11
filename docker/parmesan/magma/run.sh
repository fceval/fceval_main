#!/bin/bash

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
##


# Required for llvm-config
export PATH="$FUZZER/repo/llvm_install/clang+llvm/bin:$PATH"
export ANGORA_DISABLE_CPU_BINDING=1
#cp $OUTPUT_DIR/docker_hostname docker_hostname
#rm -rf $OUTPUT_DIR
"$FUZZER/repo/bin/fuzzer" -c "$TARGET_JSON" \
        -M 100 -i $INPUT_DIR -o "$OUTPUT_DIR/parmesan" \
        -t $TRACK_BIN -- $PARMESAN_CMD 2>&1
#cp docker_hostname $OUTPUT_DIR/docker_hostname

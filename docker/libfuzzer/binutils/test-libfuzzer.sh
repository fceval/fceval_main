#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. common.sh
EXECUTABLE_NAME_BASE = 
# Note: this target contains unbalanced malloc/free (malloc is called
# in one invocation, free is called in another invocation).
# and so libFuzzer's -detect_leaks should be disabled for better speed.
export ASAN_OPTIONS=detect_leaks=0:quarantine_size_mb=50

set -x
rm -rf CORPUS fuzz-*.log
mkdir  CORPUS
#$LIBFUZZER_FLAGS
[ -e "/target/binutils/fuzz_readelf" ] && /target/binutils/fuzz_readelf -artifact_prefix= CORPUS/ -use_value_profile=1 -jobs=2 -workers=2 $LIBFUZZER_FLAGS CORPUS seeds
grep "AddressSanitizer: heap-use-after-free" fuzz-0.log || exit 1

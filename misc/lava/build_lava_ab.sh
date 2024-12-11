#!/usr/bin/env bash

set -euo pipefail

mkdir /work/analysis_binaries
for f in /work/lava-bc/*.bc; do \
    fb=$(basename -s .bc "$f")
    mkdir "$fb.analysis_binaries"
    echo "zxy start"
    collab_fuzz_wrapper "$fb.analysis_binaries" "$f" -ldl -lm
    echo "zxy end"
    cp -r "$fb.analysis_binaries" /work/analysis_binaries/
done

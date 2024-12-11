#!/usr/bin/env bash
set -Eeuxo pipefail
mkdir -p $OUTPUT_DIR || true
hostname >> $OUTPUT_DIR/docker_hostname
cd /targets/lava/base64/bin

sh -c 'afl-fuzz  -i $INPUT_DIR -o $OUTPUT_DIR -S afl-s -- /targets/lava/base64/bin/base64 -d @@ && angora_fuzzer --sync_afl -A  -i $INPUT_DIR -o $OUTPUT_DIR  -t /targets/lava/{bin}/bin/track/bin/base64 -- /targets/lava/{bin}/bin/fast/bin/base64 -d @@'

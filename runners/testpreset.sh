#!/usr/bin/env bash

set -e

#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

cd /home/kakaxdu/collabfuzzzxy/docker/honggfuzz
python3 afl_setting.py
collab_fuzz_build -f honggfuzz -t objdump

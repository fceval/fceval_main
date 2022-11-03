#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#docker images  | grep none | awk '{print $3}' | xargs docker rmi
echo "this script would delete all fuzzers' middler images ,like fuzzer-afl:binutils ,only the fuzzer-afl:latest be reserved"
docker container prune -f
fuzzers = ("afl" "aflfast" "aflplusplus" "aflppzxy" "angora" "fairfuzz" "honggfuzz" "libfuzzer" "parmesan" "qsym" "radamsa" "symcc")
echo "fuzzers:${fuzzers[*]}"
for fuzzer in  fuzzers

do
echo $fuzzer
docker rmi "fuzzer-${fuzzer}:binutils" -f
docker rmi "fuzzer-${fuzzer}:google" -f
docker rmi "fuzzer-${fuzzer}:lava" -f
docker rmi "fuzzer-${fuzzer}:unibench" -f
docker rmi "fuzzer-${fuzzer}:putzxy" -f

done

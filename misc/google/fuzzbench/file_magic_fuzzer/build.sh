#!/bin/bash -ex
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Force a empty seed.
# zip -j $OUT/magic_fuzzer_seed_corpus.zip ./tests/*.testfile
echo "filemagic"
echo $1
echo $2
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && autoreconf -fi && ./configure --enable-static --disable-shared --disable-libseccomp && make clean && make V=1 all -j $JOBS)
}

 
apt-get update && apt-get install -y make autoconf automake libtool shtool zlib1g-dev
git clone --depth 1 https://github.com/file/file.git SRC

build_lib
build_fuzzer

cp /work/fuzzbench/file_magic_fuzzer/magic_fuzzer.cc BUILD/fuzz/magic_fuzzer.cc

if [[ $FUZZING_ENGINE == "hooks" ]]; then
  # Link ASan runtime so we can hook memcmp et al.
  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
fi
set -x

$CXX $CXXFLAGS -std=c++11 -I BUILD/src BUILD/fuzz/magic_fuzzer.cc BUILD/src/.libs/libmagic.a  $LIB_FUZZING_ENGINE -L /usr/local/lib -larchive -lz -lbz2 -llzma -o $EXECUTABLE_NAME_BASE    
    

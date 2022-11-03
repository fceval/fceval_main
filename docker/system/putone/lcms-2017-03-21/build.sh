#!/bin/bash -ex
# Copyright 2020 Google LLC
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
apt-get update && \
    apt-get install -y \
    make \
    automake \
    libtool \
    wget

git clone https://github.com/mm2/Little-CMS.git

wget -qO cms_transform_fuzzer.dict \
    https://raw.githubusercontent.com/google/fuzzing/master/dictionaries/icc.dict

cd Little-CMS
git checkout f9d75ccef0b54c9f4167d95088d4727985133c52
./autogen.sh
./configure
make -j $(nproc)

$CXX $CXXFLAGS ../cms_transform_fuzzer.cc -I include/ src/.libs/liblcms2.a \
    $FUZZER_LIB  -lpthread -o /targets/afl-putone/lcms


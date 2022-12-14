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
    wget \
    autoconf \
    automake \
    libtool \
    libglib2.0-dev

git clone https://gitlab.gnome.org/GNOME/libxml2.git

wget -qO libxml2.dict \
    https://raw.githubusercontent.com/google/AFL/debe27037b9444bbf090a0ffbd5d24889bb887ae/dictionaries/xml.dict
cd libxml2
# Git is converting CRLF to LF automatically and causing issues when checking
# out the branch. So use -f to ignore the complaint about lost changes that we
# don't even want.
git checkout -f v2.9.2
./autogen.sh
CCLD="$CXX $CXXFLAGS" ./configure --without-python --with-threads=no \
    --with-zlib=no --with-lzma=no
make -j $(nproc)

 
$CXX $CXXFLAGS -std=c++11 ../target.cc -I include .libs/libxml2.a \
    $FUZZER_LIB  -lpthread -o /targets/afl-putone/libxml2

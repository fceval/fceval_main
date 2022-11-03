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
echo "jsoncpp"
echo $1
echo $2
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh
apt-get update && apt-get install -y build-essential make curl wget
wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh && \
    chmod +x cmake-3.14.5-Linux-x86_64.sh && \
    ./cmake-3.14.5-Linux-x86_64.sh --skip-license --prefix="/usr/local"
    
build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF -DJSONCPP_WITH_TESTS=OFF \
      -DBUILD_SHARED_LIBS=OFF -G "Unix Makefiles" ..
  )
  make all -j $JOBS
  cd ..
}

 
git clone --depth 1 https://github.com/open-source-parsers/jsoncpp SRC


build_lib
build_fuzzer

 

if [[ $FUZZING_ENGINE == "hooks" ]]; then
  # Link ASan runtime so we can hook memcmp et al.
  LIB_FUZZING_ENGINE="$LIB_FUZZING_ENGINE -fsanitize=address"
fi
set -x
$CXX $CXXFLAGS -std=c++11 -I BUILD/include -I BUILD/ BUILD/src/test_lib_json/fuzz.cpp BUILD/src/lib_json/libjsoncpp.a  $LIB_FUZZING_ENGINE -L /usr/local/lib -o $EXECUTABLE_NAME_BASE    
    
# Compile fuzzer.
$CXX $CXXFLAGS -I../include $LIB_FUZZING_ENGINE \
    ../src/test_lib_json/fuzz.cpp -o $OUT/jsoncpp_fuzzer \
    src/lib_json/libjsoncpp.a

# Add dictionary.
cp SRC/src/test_lib_json/fuzz.dict  jsoncpp_fuzzer.dict    
    

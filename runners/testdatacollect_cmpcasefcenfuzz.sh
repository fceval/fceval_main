#!/usr/bin/env bash

set -e
#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

#fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "qsym" "radamsa" "honggfuzz" "libfuzzer" "angora" "parmesan" "symcc")
policies=("enfuzz" "casefc")
fuzzers=("strip" "nm" "strings" "size" "objdump")
expid=0
for fuzzer in ${fuzzers[@]}
do
	for po in ${policies[@]}
	do
		if [ "$po" == "casefc" ]
		then
			expid=0
		else
			expid=1
		fi
		mkdir -p $fuzzer/$po
		echo "/var/lib/docker/volumes/21-05-2022-expfca$fuzzer-$expid-$fuzzer-${expid}_data-vol/_data"
		cp -rf /var/lib/docker/volumes/21-05-2022-expfca$fuzzer-$expid-$fuzzer-${expid}_data-vol/_data $fuzzer/$po/
		chown -Rf $USER $fuzzer

	done
done



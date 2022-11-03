#!/usr/bin/env bash

set -e
#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

#fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "qsym" "radamsa" "honggfuzz" "libfuzzer" "angora" "parmesan" "symcc")
policies=("enfuzz" "casefc")
#fuzzers=("strip" "nm" "strings" "size" "objdump" "readelf" )
fuzzers=("strip" "nm" "strings" "size" "objdump" "readelf" )
expid=0
for fuzzer in ${fuzzers[@]}
do
	cd  exp$fuzzer/fca
	expid=0
	echo $PWD
	while [ $expid -le 4 ]
	do
	    echo 21-05-2022-expfca$fuzzer-$expid-$fuzzer-$expid
	    echo "21-05-2022-expfca${fuzzer}-${expid}-${fuzzer}-${expid}"
	    #sed -i "s/angora/radamsa/g" `grep angora -rl "21-05-2022-expfca${fuzzer}-${expid}-${fuzzer}-${expid}"` 
	    grep angora -rl "21-05-2022-expfca${fuzzer}-${expid}-${fuzzer}-${expid}" | xargs -r sed -i "s/angora/radamsa/g"
	    expid=$(( $expid + 1 ))
	done
	cd ../..
	echo $PWD					
done



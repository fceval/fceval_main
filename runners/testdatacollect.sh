#!/usr/bin/env bash

set -e
#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

#fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "qsym" "radamsa" "honggfuzz" "libfuzzer" "angora" "parmesan" "symcc")
policies=("enfuzz" "casefc")
bms=("strip" "nm" "strings" "size" "objdump" "readelf")
bm="nm"
fcs=("fca" "fcb")
expids=(0 1 2 3 4)

for fc in ${fcs[@]}
do
	for expid in ${expids[@]}
	do
		expid2=`expr $expid + 1`
		expid3=$expid
		if [ $fc == "fcb" ]
		then expid3=`expr $expid + 20`
		fi
		mkdir -p $bm/$fc/$expid2
		echo $bm/$fc/$expid2
		echo "/var/lib/docker/volumes/21-05-2022-exp$fc$bm-$expid3-$bm-${expid}_data-vol/_data"
		cp -rf /var/lib/docker/volumes/21-05-2022-exp$fc$bm-$expid3-$bm-${expid}_data-vol/_data $bm/$fc/$expid2/
		chown -Rf $USER $bm

	done
done



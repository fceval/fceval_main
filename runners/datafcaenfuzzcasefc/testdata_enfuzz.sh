#!/usr/bin/env bash

set -e
#cd /home/kakaxdu/collabfuzzzxy
#source venvnew/bin/activate

#fuzzers=("afl" "aflplusplus" "aflfast" "fairfuzz" "qsym" "radamsa" "honggfuzz" "libfuzzer" "angora" "parmesan" "symcc")
policies=("enfuzz" "casefc")
bms=("strings")
fcs=("fca" "fcb")
expids=(0 1 2 3 4)
fc="fca"
for bm in ${bms[@]}
do
	for expid in ${expids[@]}
	do
		expid2=`expr $expid + 1`
		mkdir -p $bm/$fc/$expid2
		mkdir -p $bm/fcb/$expid2
		echo $bm/$fc/$expid2
		echo "/var/lib/docker/volumes/21-05-2022-exp$fc$bm-$expid-$bm-${expid}_data-vol/_data"
		cp -rf /var/lib/docker/volumes/26-07-2022-exp$fc$bm-$expid-$bm-${expid}_data-vol/_data $bm/$fc/$expid2/
		cp -rf /var/lib/docker/volumes/enfuzz-26-07-2022-exp$fc$bm-$expid-$bm-${expid}_data-vol/_data $bm/fcb/$expid2/
		chown -Rf $USER $bm

	done
done



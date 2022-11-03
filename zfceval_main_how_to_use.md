# step1, Get base images and binaries 

a, get the source codes of project **[fceval_magma:](https://github.com/fceval/fceval_magma)**  , to build fuzzer-benchmark pairs.

b,execute the example bash **fceval_magma/buildcasefc .sh**  , Docker images for all fuzzer-benchmark pairs would be generated with binaries inside.

```
cd tools/captain
fuzzers=("afl" "aflplusplus" "moptafl_asan" "fairfuzz" "symcc_afl")
bms=("binutils" "libpng"  "libxml2" "openssl" "lua"  "cflow" "jq" "mp42aac")
for fuzzer in ${fuzzers[@]}
do
	for bm in ${bms[@]}
		do
			echo $fuzzer &&  echo $bm && (FUZZER=${fuzzer} TARGET=${bm} CANARY_MODE=2 ./build.sh)
		done
done
```

c,execute the example bash script **fceval_magma/copymagmabins.sh** to extract the special binaries for benchmarks in line with fuzzers.

```
cd tools/captain
fuzzers=("afl" "aflplusplus" "moptafl_asan" "fairfuzz" "symcc_afl")
bms=("binutils" "libpng"  "libxml2" "openssl" "lua" "cflow" "jq" "mp42aac")
rm -rf bins
mkdir bins
cd bins
for fuzzer in ${fuzzers[@]}
do
	for bm in ${bms[@]}
	do
        mkdir -p $fuzzer/$bm
        echo $fuzzer &&  echo $bm && docker run --name="${fuzzer}---${bm}" --network host -d magma/$fuzzer/$bm 	&& docker cp "${fuzzer}---${bm}":magma_out $fuzzer/$bm/  &&  docker stop "${fuzzer}---${bm}" && docker rm -f "${fuzzer}---${bm}"
	done
done
```

**Also,you could get the precompiled binaries for fuzzer-benchmark pairs from feval_main_magmabins
https://drive.google.com/drive/folders/196tBRHKwUTK9-JYYzSYVBsHeEHM8sDDS?usp=sharing
**


# step2, Get Docker images for collaborative fuzzing with fuzzer combinations

a, get source codes of project **[fceval_main:](https://github.com/fceval/fceval_main)**

b, copy the above binaries to corresponding fuzzer directories, destination path:fceval_main/docker/... 

c, execute the example bash script **feval_main/aaafceval/build_fce.sh** to build all Docker images . Also, you could refer to this script for on-demand compilation .

```
source ../venv/bin/activate
cd ..
# all for collaborative fuzzing
make framework-all
make tools
cd runners
make collab_fuzz_runner
sudo $(pwd)/../venv/bin/python setup.py install
cd ..
#fuzzers 
cd docker/afl && make all && cd ../..
cd docker/aflplusplus && make all && cd ../..
cd docker/aflfast && make all && cd ../..
cd docker/fairfuzz && make all && cd ../..
cd docker/mopt && make all && cd ../..
cd docker/symcc && make all && cd ../..
#statsd data server container for visulization
cd docker/statsd_exporter_zxy && make all && cd ../..   
```

 d, use collab_fuzz_build to add running command for each pair of fuzzer and benchmark. For example, the following script would  generate the final image for fuzzers(afl ,aflplusplus) and benchmarks(nm,objdump)

**collab_fuzz_build -f afl aflplusplus -t nm objdump**

#benchmarks: nm,objdump,readelf,libpng, libxml2,lua,openssl cflow jq mp42aac 

e, setting experiment environment

go to the directory **runners/exp.....** to set experiment environment in the file **experiment.yml** , and then execute the command collab_fuzz_run ./experiment.yml to automatically setup the images,networks,commands and so on. **Attention for IP conflicts!**

f,  Here , you would be able to execute the experiments . For example , to run the experiments for the fuzzer combination FCA on the benchmark cflow, go to the directory **fceval_main/runners/expcflow/fca/04-08-2022-expfcacflow-0-cflow-0** and execute the command: **docker-compose up --abort-on-container-exit**

# step3,  result analysis

using the tools and guidelines in the project **[fceval_tools:](https://github.com/fceval/fceval_tools)** to visualize the global branch coverage and fuzzing status ,  calculate all the evaluation results from the original experiment data .



Then , wish you good luck!  With any question , please unhesitate to contact us!


.PHONY: all
#fuzzer-symcc-putone fuzzer-symcc-unibench  fuzzer-symcc-lava  fuzzer-symcc-binutils 
all:fuzzer-angora 
	
fuzzer-angora: 
	docker build --network=host -t fuzzer-angora -f Dockerfile.all .
	python afl_setting.py
	../../misczxy/rminone.sh

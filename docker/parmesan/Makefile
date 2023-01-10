.PHONY: all
#  fuzzer-parmesan-putone fuzzer-parmesan-lava fuzzer-parmesan-unibench   fuzzer-parmesan-google  
all: fuzzer-parmesan
fuzzer-parmesan: 
	docker build --network=host -t fuzzer-parmesan -f Dockerfile.all .
	python afl_setting.py
	../../misczxy/rminone.sh

.PHONY: all

all: fuzzer-aflplusplus

fuzzer-system-aflplusplus: Dockerfile.system
	docker build --network=host -t fuzzer-system:aflplusplus -f Dockerfile.system .

fuzzer-aflplusplus: 
	docker build --network=host -t fuzzer-aflplusplus -f Dockerfile .
	python3 afl_setting.py
	../../misczxy/rminone.sh	

.PHONY: all

DOCKER_FLAGS ?=

all: fuzzer-system

fuzzer-system: Dockerfile  
	docker build $(DOCKER_FLAGS)  --network=host -t fuzzer-system  .
	python3 afl_setting.py
	../../misczxy/rminone.sh
 		

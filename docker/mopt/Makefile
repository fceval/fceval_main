.PHONY: all

all: fuzzer-mopt

fuzzer-mopt: 
	docker build --network=host -t fuzzer-mopt .
	python3 afl_setting.py

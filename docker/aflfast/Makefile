.PHONY: all

all: fuzzer-aflfast

fuzzer-aflfast: 
	docker build --network=host -t fuzzer-aflfast .
	python3 afl_setting.py

.PHONY: all
#  fuzzer-afl-binutils  fuzzer-afl-google fuzzer-afl-binutils fuzzer-afl-lava fuzzer-afl-unibench fuzzer-afl-putone fuzzer-afl-unibench  fuzzer-afl-fuzzbench
all: fuzzer-afl

fuzzer-system-afl: Dockerfile.system
	docker build --network=host -t fuzzer-system:afl -f Dockerfile.system .


fuzzer-afl-binutils: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:binutils -f Dockerfile.binutils .

fuzzer-afl-lava: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:lava -f Dockerfile.lava .

fuzzer-afl-google: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:google -f Dockerfile.google .

fuzzer-afl-fuzzbench: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:fuzzbench -f Dockerfile.fuzzbench .
	
fuzzer-afl-unibench: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:unibench -f Dockerfile.unibench .

fuzzer-afl-putone: fuzzer-system-afl
	docker build --network=host -t fuzzer-afl:putone -f Dockerfile.putone .
	
fuzzer-afl: 
	docker build --network=host -t fuzzer-afl -f Dockerfile.all .
	python3 afl_setting.py
	../../misczxy/rminone.sh

fuzzer-afl-run: 
	docker build --network=host -t fuzzer-afl-run -f Dockerfile.run .
	python3 afl_setting_run.py
	../../misczxy/rminone.sh	
	

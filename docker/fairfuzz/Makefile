.PHONY: all
#  fuzzer-fairfuzz-google fuzzer-fairfuzz-binutils fuzzer-fairfuzz-putone fuzzer-fairfuzz-lava fuzzer-fairfuzz-unibench 
all: fuzzer-fairfuzz

fuzzer-system-fairfuzz: Dockerfile.system
	docker build --network=host -t fuzzer-system:fairfuzz -f Dockerfile.system .


fuzzer-fairfuzz-binutils: fuzzer-system-fairfuzz
	docker build --network=host -t fuzzer-fairfuzz:binutils -f Dockerfile.binutils .

fuzzer-fairfuzz-lava: fuzzer-system-fairfuzz
	docker build --network=host -t fuzzer-fairfuzz:lava -f Dockerfile.lava .

fuzzer-fairfuzz-google: fuzzer-system-fairfuzz
	docker build --network=host -t fuzzer-fairfuzz:google -f Dockerfile.google .

fuzzer-fairfuzz-unibench: fuzzer-system-fairfuzz
	docker build --network=host -t fuzzer-fairfuzz:unibench -f Dockerfile.unibench .

fuzzer-fairfuzz-putone: fuzzer-system-fairfuzz
	docker build --network=host -t fuzzer-fairfuzz:putone -f Dockerfile.putone .
	
fuzzer-fairfuzz: 
	docker build --network=host -t fuzzer-fairfuzz -f Dockerfile.all .
	python3 afl_setting.py
	../../misczxy/rminone.sh

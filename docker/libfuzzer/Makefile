.PHONY: all

all: fuzzer-libfuzzer-binutils fuzzer-libfuzzer-lava fuzzer-libfuzzer-putone fuzzer-libfuzzer-google fuzzer-libfuzzer
# fuzzer-libfuzzer-lava
fuzzer-system-libfuzzer: Dockerfile.system
	docker build --network=host -t fuzzer-system:libfuzzer -f Dockerfile.system .

fuzzer-libfuzzer-binutils: fuzzer-system-libfuzzer
	docker build  --network=host -t fuzzer-libfuzzer:binutils -f Dockerfile.binutils .

fuzzer-libfuzzer-unibench: fuzzer-system-libfuzzer
	docker build --network=host -t fuzzer-libfuzzer:unibench -f Dockerfile.unibench .

fuzzer-libfuzzer-lava: fuzzer-system-libfuzzer
	docker build --network=host -t fuzzer-libfuzzer:lava -f Dockerfile.lava .

fuzzer-libfuzzer-google: fuzzer-system-libfuzzer
	docker build --network=host -t fuzzer-libfuzzer:google -f Dockerfile.google .

fuzzer-libfuzzer-putone: fuzzer-system-libfuzzer
	docker build --network=host -t fuzzer-libfuzzer:binutils -f Dockerfile.putone .
	
#fuzzer-libfuzzer: fuzzer-libfuzzer-binutils fuzzer-libfuzzer-lava fuzzer-libfuzzer-google
fuzzer-libfuzzer: 
	docker build --network=host -t fuzzer-libfuzzer -f Dockerfile.all .

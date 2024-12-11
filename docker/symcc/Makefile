.PHONY: all
#fuzzer-symcc-putone fuzzer-symcc-unibench  fuzzer-symcc-lava  fuzzer-symcc-binutils 
all:fuzzer-symcc 
#fuzzer-symcc-google     

fuzzer-system-symcc: Dockerfile.system
	docker build --network=host -t fuzzer-system:symcc -f Dockerfile.system .


fuzzer-symcc-binutils: fuzzer-system-symcc
	docker build --network=host -t fuzzer-symcc:binutils -f Dockerfile.binutils .

fuzzer-symcc-lava: fuzzer-system-symcc
	docker build --network=host -t fuzzer-symcc:lava -f Dockerfile.lava .

fuzzer-symcc-google: fuzzer-system-symcc
	docker build --network=host -t fuzzer-symcc:google -f Dockerfile.google .

fuzzer-symcc-unibench: fuzzer-system-symcc
	docker build --network=host -t fuzzer-symcc:unibench -f Dockerfile.unibench .

fuzzer-symcc-putone: fuzzer-system-symcc
	docker build --network=host -t fuzzer-symcc:putone -f Dockerfile.putone .
	
fuzzer-symcc: 
	docker build --network=host -t fuzzer-symcc -f Dockerfile.all .
	python afl_setting.py
	../../misczxy/rminone.sh

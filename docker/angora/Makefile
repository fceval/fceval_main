.PHONY: all
#all: fuzzer-angora-binutils  fuzzer-angora-unibench  fuzzer-angora-putone fuzzer-angora-lava fuzzer-angora  fuzzer-angora-google 
all: fuzzer-angora-binutils fuzzer-angora-unibench  fuzzer-angora-putone fuzzer-angora-lava fuzzer-angora

fuzzer-system-angora: Dockerfile.system
	docker build --network=host -t fuzzer-system:angora -f Dockerfile.system .


fuzzer-angora-binutils: fuzzer-system-angora
	docker build --network=host -t fuzzer-angora:binutils -f Dockerfile.binutils .

fuzzer-angora-lava: fuzzer-system-angora
	docker build --network=host -t fuzzer-angora:lava -f Dockerfile.lava .

fuzzer-angora-google: fuzzer-system-angora
	docker build  --network=host -t fuzzer-angora:google -f Dockerfile.google .

fuzzer-angora-unibench: fuzzer-system-angora
	docker build --network=host -t fuzzer-angora:unibench -f Dockerfile.unibench .

fuzzer-angora-putone: fuzzer-system-angora
	docker build --network=host -t fuzzer-angora:putone -f Dockerfile.putone .
		
fuzzer-angora:   # fuzzer-angora-google # 
	docker build --network=host -t fuzzer-angora -f Dockerfile.all .
	python afl_setting.py
	../../misczxy/rminone.sh

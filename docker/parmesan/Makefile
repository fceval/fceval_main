.PHONY: all
#  fuzzer-parmesan-putone fuzzer-parmesan-lava fuzzer-parmesan-unibench   fuzzer-parmesan-google  
all: fuzzer-parmesan-binutils fuzzer-parmesan-magma fuzzer-parmesan
#fuzzer-parmesan-google 
fuzzer-system-parmesan: Dockerfile.system
	docker build --network=host -t fuzzer-system:parmesan -f Dockerfile.system .


fuzzer-parmesan-binutils: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:binutils -f Dockerfile.binutils .

fuzzer-parmesan-lava: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:lava -f Dockerfile.lava .

fuzzer-parmesan-google: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:google -f Dockerfile.google .

fuzzer-parmesan-unibench: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:unibench -f Dockerfile.unibench .

fuzzer-parmesan-putone: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:putone -f Dockerfile.putone .

fuzzer-parmesan-magma: fuzzer-system-parmesan
	docker build --network=host -t fuzzer-parmesan:magma -f Dockerfile.magma .
		
fuzzer-parmesan: 
	docker build --network=host -t fuzzer-parmesan -f Dockerfile.all .
	python afl_setting.py
	../../misczxy/rminone.sh

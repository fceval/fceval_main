.PHONY: docker framework tools

REMOTE_REGISTRY ?= sarek.osterlund.xyz

all:framework docker tools
#all: submodules framework docker tools
docker:
	$(MAKE) -C docker
	./misczxy/rminone.sh	


#framework: framework-binutils framework-unibench framework-putzxy framework-google framework-lava 
framework: framework-all
	./misczxy/rminone.sh	 

# zhaoxy add for framework image simplication 
framework-all:
	DOCKER_BUILDKIT=0 docker build --network=host --target=framework-all -t fuzzer-framework-all .
	./misczxy/rminone.sh
	
framework-binutils:
	DOCKER_BUILDKIT=0 docker build --network=host --target=framework-binutils -t fuzzer-framework-binutils .
	./misczxy/rminone.sh
	
framework-unibench:
	DOCKER_BUILDKIT=0 docker build --network=host --target=framework-unibench -t fuzzer-framework-unibench .
	./misczxy/rminone.sh	
	
framework-putzxy:
	DOCKER_BUILDKIT=0 docker build  --network=host --target=framework-putzxy -t fuzzer-framework-putzxy . | tee output.file
	./misczxy/rminone.sh	
		
framework-lava:
	DOCKER_BUILDKIT=0 docker build --network=host --target=framework-lava -t fuzzer-framework-lava .
	./misczxy/rminone.sh	
	
framework-google:
	DOCKER_BUILDKIT=0 docker build --network=host --target=framework-google -t fuzzer-framework-google .
	./misczxy/rminone.sh
	
submodules:
	git submodule update --init --recursive

tools: afl_generic_driver collab_fuzz_runner
	./misczxy/rminone.sh
	
afl_generic_driver:
	$(MAKE) -C drivers/afl_generic docker
	./misczxy/rminone.sh
	
collab_fuzz_runner:
	$(MAKE) -C runners
	./misczxy/rminone.sh
	
remote_push: framework afl_generic_driver
	docker tag fuzzer-framework ${REMOTE_REGISTRY}/fuzzer-framework
	docker tag fuzzer-generic-driver ${REMOTE_REGISTRY}/fuzzer-generic-driver
	docker push ${REMOTE_REGISTRY}/fuzzer-framework
	docker push ${REMOTE_REGISTRY}/fuzzer-generic-driver
	$(MAKE) -C docker remote_push

remote_pull:
	docker pull ${REMOTE_REGISTRY}/fuzzer-framework
	docker pull ${REMOTE_REGISTRY}/fuzzer-generic-driver
	docker tag ${REMOTE_REGISTRY}/fuzzer-framework fuzzer-framework
	docker tag ${REMOTE_REGISTRY}/fuzzer-generic-driver fuzzer-generic-driver
	$(MAKE) -C docker remote_pull


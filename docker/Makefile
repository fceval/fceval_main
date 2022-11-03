.PHONY: docker remote_pull

DOCKER_FLAGS ?= 
REMOTE_REGISTRY ?= sarek.osterlund.xyz
stage1: fuzzer-statsd-exporter-zxy fuzzer-system fuzzer-afl  fuzzer-aflplusplus fuzzer-mopt
stage2:fuzzer-aflfast  fuzzer-fairfuzz fuzzer-radamsa 
stage3:fuzzer-angora  fuzzer-symcc fuzzer-parmesan
stage4:fuzzer-honggfuzz fuzzer-libfuzzer fuzzer-qsym
all:fuzzer-statsd-exporter-zxy fuzzer-system fuzzer-afl  fuzzer-aflplusplus fuzzer-symcc fuzzer-parmesan fuzzer-aflfast  fuzzer-fairfuzz fuzzer-radamsa fuzzer-honggfuzz  fuzzer-angora 
others:fuzzer-aflfast  fuzzer-fairfuzz fuzzer-radamsa fuzzer-honggfuzz
#all: fuzzer-afl fuzzer-radamsa fuzzer-aflppzxy fuzzer-statsd-exporter-zxy fuzzer-libfuzzer fuzzer-honggfuzz fuzzer-qsym fuzzer-#angora fuzzer-parmesan fuzzer-symcc fuzzer-aflfast  fuzzer-fairfuzz
#all: fuzzer-afl fuzzer-aflfast  fuzzer-fairfuzz fuzzer-honggfuzz fuzzer-radamsa fuzzer-qsym fuzzer-libfuzzer
#all: fuzzer-afl fuzzer-aflfast  fuzzer-fairfuzz fuzzer-honggfuzz fuzzer-radamsa fuzzer-libfuzzer
rebuild: DOCKER_FLAGS = --no-cache  
rebuild: all

prereqs:
	echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope


# general system setup
fuzzer-system:
	$(MAKE) -C system DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-aflplusplus:
	$(MAKE) -C aflplusplus DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-plain:
	$(MAKE) -C plain DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-qsym: fuzzer-plain
	$(MAKE) -C qsym DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-afl: fuzzer-system
	$(MAKE) -C afl DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-aflfast: fuzzer-aflplusplus
	$(MAKE) -C aflfast DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-fairfuzz: fuzzer-afl
	$(MAKE) -C fairfuzz DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-honggfuzz: fuzzer-system
	$(MAKE) -C honggfuzz DOCKER_FLAGS=${DOCKER_FLAGS}  

fuzzer-radamsa: fuzzer-aflplusplus
	$(MAKE) -C radamsa DOCKER_FLAGS=${DOCKER_FLAGS} 

fuzzer-aflppzxy: fuzzer-aflplusplus
	$(MAKE) -C aflppzxy DOCKER_FLAGS=${DOCKER_FLAGS} 
  
#fuzzer-libfuzzer: fuzzer-system
#	echo "Not implemented yet"

fuzzer-angora: fuzzer-system
	$(MAKE) -C angora DOCKER_FLAGS=${DOCKER_FLAGS} 

fuzzer-libfuzzer: fuzzer-system
	$(MAKE) -C libfuzzer DOCKER_FLAGS=${DOCKER_FLAGS} 

fuzzer-parmesan: fuzzer-system
	$(MAKE) -C parmesan DOCKER_FLAGS=${DOCKER_FLAGS} 	


fuzzer-symcc: fuzzer-system
	$(MAKE) -C symcc DOCKER_FLAGS=${DOCKER_FLAGS} 

fuzzer-mopt:
	$(MAKE) -C mopt DOCKER_FLAGS=${DOCKER_FLAGS} 
		
fuzzer-statsd-exporter-zxy:
	$(MAKE) -C statsd_exporter_zxy DOCKER_FLAGS=${DOCKER_FLAGS} 
	   

remote_push: all
	docker tag fuzzer-system ${REMOTE_REGISTRY}/fuzzer-system
	docker tag fuzzer-afl ${REMOTE_REGISTRY}/fuzzer-afl
	docker tag fuzzer-aflplusplus ${REMOTE_REGISTRY}/fuzzer-aflplusplus
	docker tag fuzzer-aflfast ${REMOTE_REGISTRY}/fuzzer-aflfast
	docker tag fuzzer-fairfuzz ${REMOTE_REGISTRY}/fuzzer-fairfuzz
	docker tag fuzzer-qsym ${REMOTE_REGISTRY}/fuzzer-qsym
	docker push ${REMOTE_REGISTRY}/fuzzer-system
	docker push ${REMOTE_REGISTRY}/fuzzer-afl
	docker push ${REMOTE_REGISTRY}/fuzzer-aflplusplus
	docker push ${REMOTE_REGISTRY}/fuzzer-aflfast
	docker push ${REMOTE_REGISTRY}/fuzzer-fairfuzz
	docker push ${REMOTE_REGISTRY}/fuzzer-qsym

remote_pull:
	docker pull ${REMOTE_REGISTRY}/fuzzer-system
	docker pull ${REMOTE_REGISTRY}/fuzzer-afl
	docker pull ${REMOTE_REGISTRY}/fuzzer-aflplusplus
	docker pull ${REMOTE_REGISTRY}/fuzzer-aflfast
	docker pull ${REMOTE_REGISTRY}/fuzzer-fairfuzz
	docker pull ${REMOTE_REGISTRY}/fuzzer-qsym
	docker tag ${REMOTE_REGISTRY}/fuzzer-system fuzzer-system
	docker tag ${REMOTE_REGISTRY}/fuzzer-afl fuzzer-afl
	docker tag ${REMOTE_REGISTRY}/fuzzer-aflplusplus fuzzer-aflplusplus
	docker tag ${REMOTE_REGISTRY}/fuzzer-aflfast fuzzer-aflfast
	docker tag ${REMOTE_REGISTRY}/fuzzer-fairfuzz fuzzer-fairfuzz
	docker tag ${REMOTE_REGISTRY}/fuzzer-qsym fuzzer-qsym


# TODO:
# some packages from fuzzer-test-suite need ptrace functionality which
# can not be enabled during docker build so we have to run that code in
# privileged mode and save the changes

fuzzer-test-suite:
	./build_test_suite.py

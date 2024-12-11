.PHONY: docker

docker: 
	docker build --network=host -t fuzzer-generic-driver -f docker/Dockerfile .
	../../misczxy/rminone.sh

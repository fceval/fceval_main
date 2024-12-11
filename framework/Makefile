.PHONY: docker proj

all: docker

proj:
	cargo build --release

docker: 
	docker build --network=host -t fuzzer-framework ../

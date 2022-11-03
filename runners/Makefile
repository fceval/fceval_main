.PHONY: collab_fuzz_runner

all: build

build:
	python setup.py build

install: build
	sudo python3 setup.py install	
	sudo $(shell pwd)/../venv/bin/python setup.py install

collab_fuzz_runner: install

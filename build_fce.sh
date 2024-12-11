source venv/bin/activate
make framework-all
make tools
cd docker/afl && make all && cd ../..
cd docker/aflplusplus && make all && cd ../..
cd docker/aflfast && make all && cd ../..
cd docker/radamsa && make all && cd ../..
cd docker/honggfuzz && make all && cd ../..
cd docker/symcc && make all && cd ../..

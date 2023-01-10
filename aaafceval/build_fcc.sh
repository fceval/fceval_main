source ../venv/bin/activate
cd ..
make framework-all
make tools
cd runners
make collab_fuzz_runner
sudo $(pwd)/../venv/bin/python setup.py install
cd ..
cd docker/afl && make all && cd ../..
cd docker/symcc && make all && cd ../..
cd docker/aflplusplus && make all && cd ../..
cd docker/radamsa && make all && cd ../..
cd docker/parmesan && make all && cd ../..
cd docker/statsd_exporter_zxy && make all && cd ../..

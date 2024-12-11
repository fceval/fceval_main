FROM fuzzer-system:afl

WORKDIR /work
# install AFL fairfuzz
RUN git clone https://github.com/carolemieux/afl-rb.git && cd afl-rb && git checkout e529c1f1b366 && cp -r ../afl/llvm_mode ./ && make -j`nproc` && ./afl-clang --version && make install



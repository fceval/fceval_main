FROM fuzzer-aflplusplus
WORKDIR /work
#COPY --from=fuzzer-system /work/aflplusplus_3.11c.tar.gz aflplusplus_3.11c.tar.gz
#COPY --from=fuzzer-system:aflplusplus /work/AFLplusplus /work/AFLplusplus
#RUN cd AFLplusplus && make distrib && make install && cd custom_mutators/radamsa && make
RUN cd /magma/fuzzers/aflplusplus/repo/custom_mutators/radamsa  && make
#ENV AFL_CUSTOM_MUTATOR_LIBRARY=/work/AFLplusplus/custom_mutators/radamsa/radamsa-mutator.so
ENV AFL_CUSTOM_MUTATOR_LIBRARY=/magma/fuzzers/aflplusplus/repo/custom_mutators/radamsa/radamsa-mutator.so
ENV AFL_CUSTOM_MUTATOR_ONLY=1



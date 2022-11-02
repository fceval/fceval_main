**This is the main project with source codes for FCEVAL .**

**FCEVAL is an effective,fair,comprehensive quantified and easy-to-use evaluator for fuzzer combinations, which extends the collaborative framework [COLLABFUZZ](https://github.com/vusec/collabfuzz)  to run fuzzer combinations and extends Ground-truth benchmark for fuzzing [Magma](https://github.com/HexHive/magma) for adapting fuzzers to benchmarks.**

There are several sub projects for FCEVAL as follows:

**[fceval_artifacts](https://github.com/fceval/fceval_artifacts):**   

1,to store the original data for  comparing both FCA with two testcase sharing policies  and FCA&FCB with the same policy POLICY_FCEVAL.

**[fceval_appendix:](https://github.com/fceval/fceval_appendix)**  

1, to store the original data for  comparing both FCC with two testcase sharing policies  and FCC&FCD with the same policy POLICY_FCEVAL.

2,to display additional results that are not shown for limited paper space.

**[fceval_magma:](https://github.com/fceval/fceval_magma)**  

1,we extend Magma for more fuzzers and benchmarks ,then fetch the bins from the docker images and copy them to fceeval_main to make the final docker images .

**[fceval_tools:](https://github.com/fceval/fceval_tools)**  

1, to store all of the tools ,such as experiment setting,  test data collecting, bins fetching and copying , one-key result analyzing.

**[fceval_others:](https://github.com/zhaoxiaoyunok/fceval_others)**  

1, to store the docker builing scripts  with the way of COLLABFUZZ, including more benchmark sets ,such as Fuzzbench,LAVA-M,unibench,Binutils .

2,other additional information and materials.
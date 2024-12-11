**This is the main project with source codes for FCEVAL . [paper link](https://authors.elsevier.com/a/1hIyd_3pcoW3be)**

**FCEVAL is an effective,fair,comprehensive quantified and easy-to-use evaluator for fuzzer combinations, which extends the collaborative framework [COLLABFUZZ](https://github.com/vusec/collabfuzz)  to run fuzzer combinations and extends Ground-truth benchmark for fuzzing [Magma](https://github.com/HexHive/magma) for adapting fuzzers to benchmarks.**

There are several sub projects for FCEVAL as follows:

**[fceval_artifacts](https://github.com/fceval/fceval_artifacts):**   

1,to store the original data for  comparing both FCA with two testcase sharing policies  and FCA&FCB with the same policy POLICY_FCEVAL.

**[fceval_appendix:](https://github.com/fceval/fceval_appendix)**  

1, to store the original data for  comparing both FCC with two testcase sharing policies  and FCC&FCD with the same policy POLICY_FCEVAL.

2,to display additional results that are not shown for limited paper space.

**[fceval_magma:](https://github.com/fceval/fceval_magma)**  

1,we extend Magma for more fuzzers and benchmarks ,then fetch the bins from the docker images and copy them to fceeval_main to make the final docker images .


When using this project in your research, please kindly refer to the following papers:

@article{zhao2023fceval,
  title={FCEVAL: An Effective and Quantitative Platform for Evaluating Fuzzer Combinations Fairly and Easily},
  author={Zhao, Xiaoyun and Yang, Chao and Jia, Zhizhuang and Wang, Yue and Ma, Jianfeng},
  journal={Computers \& Security},
  pages={103354},
  year={2023},
  publisher={Elsevier}
}

@article{Hazimeh:2020:Magma,
  author     = {Ahmad Hazimeh and Adrian Herrera and Mathias Payer},
  title      = {Magma: A Ground-Truth Fuzzing Benchmark},
  year       = {2020},
  issue_date = {December 2020},
  publisher  = {Association for Computing Machinery},
  address    = {New York, NY, USA},
  volume     = {4},
  number     = {3},
  url        = {https://doi.org/10.1145/3428334},
  doi        = {10.1145/3428334},
  journal    = {Proc. ACM Meas. Anal. Comput. Syst.},
  month      = dec,
  articleno  = {49},
  numpages   = {29}
}

@inproceedings{osterlund2021collabfuzz,
  title={Collabfuzz: A framework for collaborative fuzzing},
  author={{\"O}sterlund, Sebastian and Geretto, Elia and Jemmett, Andrea and G{\"u}ler, Emre and G{\"o}rz, Philipp and Holz, Thorsten and Giuffrida, Cristiano and Bos, Herbert},
  booktitle={Proceedings of the 14th European Workshop on Systems Security},
  pages={1--7},
  year={2021}
}

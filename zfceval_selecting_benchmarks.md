To select a unified benchmark set, we've proposed our principles and conducted extensive compilation, adaptation, and experimental testing. **Then, the main process is described as follows****：**

**(1)** We have **systematically investigated the major benchmark sets** for evaluating fuzzing techniques.

**Magma,** with ground-truth has seven targets (i.e., the codebases into which bugs are injected) when published, including 25 drivers (i.e., executable programs that provide a command-line interface to the target) that exercise different functionality within the target. As shown in  [https://hexhive.epfl.ch/magma/reports/sample/libraries/openssl.html.](https://hexhive.epfl.ch/magma/reports/sample/libraries/openssl.html.), the average number of bugs, which are triggered but not necessarily detected, is about 4 for a target and 1.28 for a driver. We can further observe from the web page [https://hexhive.epfl.ch/magma/docs/Reports.html](https://hexhive.epfl.ch/magma/docs/Reports.html) that many of them would take more than 24 hours to trigger. As shown in the results of our practical experimental tests, we’ve used four fuzzer combinations to test on the benchmark program of openssl for 24 hours * 20 repetitions but found no bug. It means that the metrics of bug finding would not be measured on this benchmark.

![image](https://github.com/fceval/fceval_main/blob/b740e3a2c6a9a20dc89ea0074f53e76ee0974463/docs/b1.png)
![image](https://github.com/fceval/fceval_main/blob/b740e3a2c6a9a20dc89ea0074f53e76ee0974463/docs/b2.png)

**OSS-fuzz.** The 47 real-world programs from OSS-fuzz, which are used by FUZZBENCH, are mainly compiled and adapted for the fuzzers such as AFL, Honggfuzz, Libfuzzer. We’ve checked out the related profile of the program, project.yaml or benchmark.yml, (i.e. [https://github.com/google/oss-fuzz/blob/master/projects/abseil-cpp/project.yaml](https://github.com/google/oss-fuzz/blob/master/projects/abseil-cpp/project.yaml) for OSS-fuzz, [https://github.com/google/](https://github.com/google/)fuzzbench/blob/master/ benchmarks/arrow_parquet-arrow-fuzz/benchmark.yaml for FUZZBENCH) to see what fuzzers the current project supports or does not support. We’ve checked the item of “unsupported fuzzers” and found that 29/47 programs don’t support the fuzzer SYMCC at the moment. Meanwhile, we could obtain the fact that **google fuzzer test suite** has been replaced by OSS-fuzz and would not be maintained.

**Unibench** is composed of 20 real-world programs while biased towards to the input types as audio&video(7) and image(5). We’ve chosen one for each type such as mp42aac, cflow and jq.

**(2) We've followed the selection principles in Section 3.4. Benchmarks and mad a lot of manual effort and computational resources to adapt the base fuzzers to benchmark programs one by one**. We’ve tried to ensure that they run properly both one-to-one and in a collaborative fuzzing environment. Then, we have considered the following aspects for selecting benchmark programs.

A, **diversity.** It contains multiple types of bugs, which can be seen from the table crash_analysis in the result database run_info.sqlite, such as heap-buffer-voverflow, heap_use_after_free, SEGV, FPE, stack-buffer-overflow, allocater, negative-size-param, stack-overflow, global-buffer-overflow and global-buffer-overflow. Also, it covers different kinds of programs, such as binary processer, lua script, image processing, audio&video, xml file and text.

B, **real-world programs.** The particular way of forward-porting real bugs from old versions to the latest version enables ground truth in the programs from Magma. Also, the programs from Unibench have some bug information, i.e. mp42aac (https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=Bento4), cflow (https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=cflow), jq (https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=jq). In addition, there is CVE information (https://cve.mitre.org/cgi-bin/cvekey.cgi? keyword=binutils) for the benchmark programs from Binutils, the linux binary tools.

C, **gradient difficulty in bug finding.** We can observe from the actual bug history charts that bugs in openssl cannot be found within 24 hours by any fuzzer combination, bugs in jq can be discovered by FCA in 3 hours, while bugs in other benchmarks can be continuously found by general fuzzer combinations.  

D, as shown in Seciton 3.4 Benchmarks, **the final benchmark set is in line with our methodology as follows:**

• All of them are real-world programs. Due to the special way of forwarding real bugs from older versions to newer code, ground-truth bugs are injected. There are also CVEs for the programs from binutils and unibench.

• They are with diverse types, such as binary, lua script, image, video, text, xml file and networking. Also, they contain different types of bugs, such as heap-buffer-voverflow, heap_use_after_free, SEGV, FPE, stack-buffer-overflow, allocater, negative-size-param, stack-overflow, global-buffer-overflow and global-buffer-overflow, evidenced by the table crash_analysis from the result database run_info.sqlite.

• There is gradient difficulty in finding bugs in these benchmarks. As shown in Fig.5, 24-hour is not enough for finding bugs on openssl x509, general fuzzer combinations could find all of the bugs within 3 hours, while fuzzer combinations could discovery bugs on other programs continuously within 24 hours.

Nevertheless, the selection of such a benchmark set should be a **dynamic process**. We would **utilize our evaluation platform FCEVAL in subsequent work to test more target programs in practice and improve it continuously**.

**(3)** As written in Section 5.3, we would look forward to **a unified standard for benchmarking programs** supported by both industry and academia and wish our work draw more attention and thinking.

from .config import Config, FuzzerType


def get_cmdline_suggestion(config: Config) -> str:
    if (
        config.fuzzer_type == FuzzerType.AFL
        or config.fuzzer_type == FuzzerType.AFLFAST
        or config.fuzzer_type == FuzzerType.FAIRFUZZ
        or config.fuzzer_type == FuzzerType.RADAMSA
        or config.fuzzer_type == FuzzerType.AFLPPZXY
        or config.fuzzer_type == FuzzerType.AFLPLUSPLUS 
    ): #zhaoxy add for aflplusplus
        cmdline_args = (
            f"afl-fuzz -i input_dir "
            f"-o {config.output_dir} "
            f"-M {config.fuzzer_type} "
            f"-- /path/to/target.afl"
        )
     # zhaoxy add for angora start   
    elif config.fuzzer_type == FuzzerType.ANGORA:
        cmdline_args = (
            f"angora_fuzzer -i input_dir "
            f"-o {config.output_dir} -S "
            f"-t /path/to/target.track "
            f"-- /path/to/target.fast"
        )
     # zhaoxy add for angora end   
     # zhaoxy add for symcc start   
    elif config.fuzzer_type == FuzzerType.SYMCC:
        cmdline_args = (
            f"afl-fuzz -M afl-master -i corpus -o afl_out -m none -- afl_build/tcpdump/tcpdump -e -r @@"
            f"afl-fuzz -S afl-secondary -i corpus -o afl_out -m none -- afl_build/tcpdump/tcpdump -e -r @@"
            f"~/.cargo/bin/symcc_fuzzing_helper -o afl_out -a afl-secondary -n symcc -- symcc_build/tcpdump/tcpdump -e -r @@"
        )
     # zhaoxy add for symcc end
      # zhaoxy add for parmesan start   
    elif config.fuzzer_type == FuzzerType.PARMESAN:
        cmdline_args = (
            f"afl-fuzz -S afl-s -i corpus -o afl_out -m none -- afl_build/objdump -s -d @@"
            f"/work/parmesan/bin/fuzzer -c ./targets_objdump.pruned.json -i in -o out -t ./objdump.track -s ./objdump.san.fast -- ./objdump.fast -s -d @@"
        )
     # zhaoxy add for symcc end             
    elif config.fuzzer_type == FuzzerType.QSYM:
        cmdline_args = (
            f"bin/run_qsym_afl.py "
            f"-a framework "
            f"-o {config.output_dir} "
            f"-n qsym -- /path/to/target"
        )
    elif config.fuzzer_type == FuzzerType.LIBFUZZER:
        cmdline_args = (
            f"TARGET_BIN "
            f"-artifact_prefix={config.output_dir}/artifacts/ "
            f"{config.output_dir}/queue"
        )
    elif config.fuzzer_type == FuzzerType.HONGGFUZZ:
        cmdline_args = (
            f"honggfuzz --input {config.output_dir}/seeds "
            f"--output {config.output_dir}/queue "
            f"--crashdir {config.output_dir}/crashes "
            f"-y {config.output_dir}/sync -- "
            f"/path/to/target.honggfuzz"
        )
    elif config.fuzzer_type == FuzzerType.MOPT:
        cmdline_args = (
            f"afl-fuzz -m none -L 0 -i input_dir "
            f"-o {config.output_dir} "
            f"-M {config.fuzzer_type} "
            f"-- /path/to/target.afl"
        )       
    else:
        raise Exception(f"Invalid fuzzer type: {config.fuzzer_type}")

    return cmdline_args

BIN2SUITE = {
    "objdump": ("binutils", "objdump"),
    "size": ("binutils", "size"),
    "cxxfilt": ("binutils", "c++filt"),
    "addr2line": ("binutils", "addr2line"),
    "ar": ("binutils", "ar"),
    "strings": ("binutils", "strings"),
    #"nm-new": ("binutils", "nm-new"),
    "nm": ("binutils", "nm"),
    "readelf": ("binutils", "readelf"),
    #"strip-new": ("binutils", "strip-new"),
    "strip": ("binutils", "strip"),
    "boringssl": ("google-test-suite", "boringssl-2016-02-12"),
    "c-ares": ("google-test-suite", "c-ares-CVE-2016-5180"),
    "freetype2": ("google-test-suite", "freetype2-2017"),
    "guetzli": ("google-test-suite", "guetzli-2017-3-30"),
    "harfbuzz": ("google-test-suite", "harfbuzz-1.3.2"),
    "json": ("google-test-suite", "json-2017-02-12"),
    "lcms": ("google-test-suite", "lcms-2017-03-21"),
    "libarchive": ("google-test-suite", "libarchive-2017-01-04"),
    "libjpeg-turbo": ("google-test-suite", "libjpeg-turbo-07-2017"),
    #"libpng": ("google-test-suite", "libpng-1.2.56"),
    "libssh": ("google-test-suite", "libssh-2017-1272"),
    #"libxml2": ("google-test-suite", "libxml2-v2.9.2"),
    "llvm-libcxxabi": ("google-test-suite", "llvm-libcxxabi-2017-01-27"),
    "openssl-1.0.1f": ("google-test-suite", "openssl-1.0.1f"),
    "openssl-1.0.2d": ("google-test-suite", "openssl-1.0.2d"),
    #"openssl-1.1.0c": ("google-test-suite", "openssl-1.1.0c"),
    "openssl-1.1.0c-bignum": ("google-test-suite", "openssl-1.1.0c", "bignum"),
    "openssl-1.1.0c-x509": ("google-test-suite", "openssl-1.1.0c", "x509"),
    #"openthread": ("google-test-suite", "openthread-2018-02-27"),
    "openthread-ip6": ("google-test-suite", "openthread-2018-02-27", "ip6"),
    "openthread-radio": ("google-test-suite", "openthread-2018-02-27", "radio"),
    "pcre2": ("google-test-suite", "pcre2-10.00"),
    "proj4": ("google-test-suite", "proj4-2017-08-14"),
    "re2": ("google-test-suite", "re2-2014-12-09"),
    "sqlite": ("google-test-suite", "sqlite-2016-11-14"),
    "vorbis": ("google-test-suite", "vorbis-2017-12-11"),
    "woff2": ("google-test-suite", "woff2-2016-05-06"),
    "wpantund": ("google-test-suite", "wpantund-2018-02-27"),
    "base64": ("LAVA-M", "base64"),
    "md5sum": ("LAVA-M", "md5sum"),
    "uniq": ("LAVA-M", "uniq"),
    "who": ("LAVA-M", "who"),
    #zhaoxy add for unifuzz dataset start
    "cflow": ("unibench", "cflow"),
    "flvmeta": ("unibench", "flvmeta"),
    "infotocap": ("unibench", "infotocap"),
    "jhead": ("unibench", "jhead"),
    "jq": ("unibench", "jq"),
    "exiv2": ("unibench", "exiv2"),
    "mp42aac": ("unibench", "mp42aac"),
    "wav2swf": ("unibench", "wav2swf"),
    "imginfo": ("unibench", "imginfo"),     
    #"mp3gain": ("unibench", "mp3gain")
    #zhaoxy add for unifuzz dataset end
    
    # zhaoxy add for putonemp3gain
    "mp3gain": ("putone", "mp3gain"),
    # zhaoxy add for putonefile_magic
    "file_magic": ("putone", "file_magic"),
    "freetype2-2017": ("fuzzbench", "freetype2-2017"),
    "file_magic_fuzzer": ("fuzzbench", "file_magic_fuzzer"),
    #zhaoxy add for magma
    "libpng": ("magma", "libpng"),
    "libtiff": ("magma", "libtiff"),
    "libsndfile": ("magma", "libsndfile"), 
    "libxml2": ("magma", "libxml2"), 
    "lua": ("magma", "lua"), 
    "openssl": ("magma", "openssl"),
    "as": ("binutils", "as"),
    "ld": ("binutils", "ld"),
    "ranlib": ("binutils", "ranlib"),
    "gprof": ("binutils", "gprof"), 
    
}

BIN2ARGS = {
    "addr2line": "-e @@",
    "ar": "-t @@",
    "strings": "-d @@",
    "size": "@@",
    "cxxfilt": "@@",
    "c++filt": "@@",
    #"nm-new": "-a -C -l --synthetic @@",
    #"nm": "-a -C -l --synthetic @@",
    "nm": "-C @@",
    #"objdump": "--dwarf-check -C -g -f -dwarf -x @@",
    "objdump": "-d @@",
    #"readelf": "-a -c -w -I @@",
    "readelf": "-a @@",
    #"strip-new": "-o /dev/null -s @@",
    "strip": "-o /dev/null -s @@",
    "xml": "@@",
    "gnuplot": "@@",
    "boringssl": "@@",
    "c-ares": "@@",
    "freetype2": "@@",
    "guetzli": "@@",
    "harfbuzz": "@@",
    "json": "@@",
    "lcms": "@@",
    "libarchive": "@@",
    "libjpeg-turbo": "@@",
    #"libpng": "@@",
    "libssh": "@@",
    #"libxml2": "@@",
    "llvm-libcxxabi": "@@",
    "openssl-1.0.1f": "@@",
    "openssl-1.0.2d": "@@",
    "openssl-1.1.0c": "@@",
    "openssl-1.1.0c-bignum": "@@",
    "openssl-1.1.0c-x509": "@@",
    "openthread": "@@",
    "openthread-ip6": "@@",
    "openthread-radio": "@@",
    "pcre2": "@@",
    "proj4": "@@",
    "re2": "@@",
    "sqlite": "@@",
    "vorbis": "@@",
    "woff2": "@@",
    "wpantund": "@@",
    "base64": "-d @@",
    "md5sum": "-c @@",
    "uniq": "@@",
    "who": "@@",
    #zhaoxy add for unifuzz dataset start
    "cflow": "@@",
    "flvmeta": "@@",
    "infotocap": "-o /dev/null @@",
    "jhead": "@@",
    "jq": ". @@",
    "exiv2": "@@",
    "mp42aac": "@@ /dev/null",
    "wav2swf": "-o /dev/null @@",
    "imginfo": "-f @@", 
    #"mp3gain": "@@"
    #zhaoxy add for unifuzz dataset end
    
    #zhaoxy add for putone mp3gain
    "mp3gain": "@@",
    # zhaoxy add for putonefile_magic
    "file_magic": "2147483647",
    "freetype2-2017":  "@@",
    "file_magic_fuzzer":  "@@",
    #zhaoxy add for magma
    "libpng": "@@",
    "libtiff": "@@",
    "libsndfile": "@@",
    "libxml2": "@@",
    "lua": "@@",
    "openssl": "@@",
    "as": "@@",
    "ld": "@@",
    "ranlib": "@@",
    "gprof": "@@",
}

SUITEOPTS = {
    "binutils": "-t 1000+",
    "google-test-suite": "-t 1000+",
    "LAVA-M": "-t 1000+",
    "unibench": "-t 1000+",  #zhaoxy add for unifuzz dataset
    "fuzzbench": "-t 1000+",
    "putone": "-t 1000+",  #zhaoxy add for putone mp3gain #zhaoxy add for putone fuzzbench
    "magma": "-t 1000+",  #zhaoxy add for magma
    }

SUITEBIN = {
    "binutils": "/targets/binutils/bin/{bin}",
    #zhaoxy add for unifuzz dataset
    "unibench": "/targets/unibench/{bin}",
    "google-test-suite": "/targets/google/RUNDIR-{bin}/{bin}-afl{ext}",
    #"google-test-suite-plain": "/targets-plain/google/{bin}-coverage{ext}",
    "google-test-suite-plain": "/targets-plain/google/RUNDIR-{bin}/{bin}-coverage{ext}",
    "google-test-suite-libfuzzer": "/targets/google/RUNDIR-{bin}/{bin}-fsanitize_fuzzer{ext}",
    "google-test-suite-honggfuzz": "/targets/google/RUNDIR-{bin}/{bin}-honggfuzz{ext}",
    "LAVA-M": "/targets/lava/{bin}/bin/{bin}",
    
    # zhaoxy add for putone mp3gain
    "putone": "/targets/putone/{bin}",
    
    "fuzzbench": "/targets/fuzzbench/{bin}",
    #zhaoxy add for magma
    "magma": "/targets/magma/{bin}/{bin}"
    
    }

SUITEDIREXTRA = {
    "binutils-angora-fast": "/targets/binutils/fast/bin",
    "binutils-angora-track": "/targets/binutils/track/bin",
    "unibench-angora-fast": "/targets/unibench/fast",
    "unibench-angora-track": "/targets/unibench/track",
    "fuzzbench-angora-fast": "/targets/fuzzbench/fast",
    "fuzzbench-angora-track": "/targets/fuzzbench/track",    
    # zhaoxy add for putone mp3gain
    "putone-angora-fast": "/targets/putone/fast",
    "putone-angora-track": "/targets/putone/track",
    "magma-angora-fast": "/targets/magma/{bin}/fast",
    "magma-angora-track": "/targets/magma/{bin}/track",  
    "LAVA-M-angora-fast": "/targets/lava/fast/{bin}/bin",
    "LAVA-M-angora-track": "/targets/lava/track/{bin}/bin",

    "binutils-symcc-symcc": "/targets/binutils/symcc/bin",
    "unibench-symcc-symcc": "/targets/unibench/symcc",
    "LAVA-M-symcc-symcc": "/targets/lava/symcc/{bin}/bin",
    # zhaoxy add for putone mp3gain
    "putone-symcc-symcc": "/targets/putone/symcc",
    "fuzzbench-symcc-symcc": "/targets/fuzzbench/symcc",
    #zhaoxy add for magma
    "magma-symcc-symcc": "/targets/magma/{bin}/symcc",
    "binutils-parmesan-parmesan": "/targets/binutils",
    "magma-parmesan-parmesan": "/targets/magma/{bin}",
    "unibench-parmesan-parmesan": "/targets/unibench",   
    "magma-aflplusplus-cmplog": "/targets/magma/{bin}/cmplog",
    "binutils-aflplusplus-cmplog": "/targets/binutils/cmplog/bin",
    "unibench-aflplusplus-cmplog": "/targets/unibench/cmplog",    
    }

# zhaoxy add for bins with seeds start
BIN2SEEDS = {
    "boringssl": "google-test-suite/boringssl-2016-02-12",
    "c-ares": "google-test-suite/c-ares-CVE-2016-5180",
    "freetype2": "google-test-suite/freetype2-2017",
    "guetzli": "google-test-suite/guetzli-2017-3-30",
    "harfbuzz": "google-test-suite/harfbuzz-1.3.2",
    "json": "google-test-suite/json-2017-02-12",
    "lcms": "google-test-suite/lcms-2017-03-21",
    "libarchive": "google-test-suite/libarchive-2017-01-04",
    "libjpeg-turbo": "google-test-suite/libjpeg-turbo-07-2017",
    "libpng": "google-test-suite/libpng-1.2.56",
    "libssh": "google-test-suite/libssh-2017-1272",
    #"libxml2": "google-test-suite/libxml2-v2.9.2",
    "llvm-libcxxabi": "google-test-suite/llvm-libcxxabi-2017-01-27",
    "openssl-1.0.1f": "google-test-suite/openssl-1.0.1f",
    "openssl-1.0.2d": "google-test-suite/openssl-1.0.2d",
    #"openthread": ("google-test-suite", "openthread-2018-02-27")
    "openthread-ip6": "google-test-suite/openthread-2018-02-27",
    "openthread-radio": "google-test-suite/openthread-2018-02-27",
    "pcre2": "google-test-suite/pcre2-10.00",
    "proj4": "google-test-suite/proj4-2017-08-14",
    "re2": "google-test-suite/re2-2014-12-09",
    "sqlite": "google-test-suite/sqlite-2016-11-14",
    "vorbis": "google-test-suite/vorbis-2017-12-11",
    "woff2": "google-test-suite/woff2-2016-05-06",
    "wpantund": "google-test-suite/wpantund-2018-02-27",
    "base64": "lavam/base64",
    "md5sum": "lavam/md5sum",
    "uniq": "lavam/uniq",
    "who": "lavam/who",
    #zhaoxy add for unifuzz dataset start
    "cflow": "unibench/cflow",
    "flvmeta": "unibench/flvmeta",
    "infotocap": "unibench/infotocap",
    "jhead": "unibench/jhead",
    "jq": "unibench/jq",
    "exiv2": "unibench/exiv2",
    "wav2swf": "unibench/wav2swf",
    "mp42aac": "unibench/mp42aac",
    "imginfo": "unibench/imginfo",
    # "mp3gain": "unibench/mp3gain"
    #zhaoxy add for unifuzz dataset end
    
    #zhaoxy add for putone mp3gain
    "mp3gain": "putone/mp3gain",
    #zhaoxy add for putone file_magic
    "file_magic": "putone/file_magic",
    "objdump": "binutils/objdump",
    "strings": "binutils/strings",
    "size": "binutils/size",
    "nm": "binutils/nm",
    "ld": "binutils/ld",
    "cxxfilt": "binutils/c++filt",
    "readelf": "binutils/readelf",
    "strip": "binutils/strip",
    "addr2line": "binutils/addr2line",
    "ar": "binutils/ar", 
    "freetype2-2017": "fuzzbench/freetype2-2017",  
    "file_magic_fuzzer": "fuzzbench/file_magic_fuzzer",  
     #zhaoxy add for magma
    "libpng": "magma/libpng",
    "libtiff": "magma/libtiff",
    "libxml2": "magma/libxml2",  
    "lua": "magma/lua",  
    "openssl": "magma/openssl",                      
}
# zhaoxy add for bins with seeds end


ONLY_PLAIN = [("google-test-suite", "qsym")]

# FUZZERS = {
#        "afl": ["afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -M afl -- {target_cmd}"],
#        "aflfast": ["afl-fuzz {afl_opts} -p fast -i {input_dir} -o {output_dir} -M aflfast -- {target_cmd}"],
#        "fairfuzz": ["afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -M fairfuzz -- {target_cmd}"],
#        "qsym": ["/qsym/bin/run_qsym_afl.py -a framework -o {output_dir} -n qsym -- {target_cmd}"],
#        "radamsa": ["afl-fuzz {afl_opts} -RR -i {input_dir} -o {output_dir} -M radamsa -- {target_cmd}"],
#        "honggfuzz": ["honggfuzz -n 1 --input {output_dir}/seeds -z --covdir_all {output_dir}/queue  --crashdir {output_dir}/crashes -y {output_dir}/sync -Y 10 -- {target_cmd}"],
#        #"libfuzzer": "{target_cmd} --fork=1 {output_dir}/libfuzzer/queue {input_dir}",
#        "libfuzzer": ["{target_cmd} -fork=1 -ignore_crashes=1 -artifact_prefix={output_dir}/artifacts/ {output_dir}/queue"],
#        "aflppzxy": ["afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -M aflppzxy -- {target_cmd}"],
#        # zhaoxy add for angora 
#        # angora_fuzzer -i input -o output -t path/to/taint/program -- path/to/fast/program [argv]
#        "angora": ["afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -S afl-s -- {target_cmd}", "angora_fuzzer --sync_afl -A  -i {input_dir} -o {output_dir}  -t {fuzzer_dir_extra}/track/bin/{target} -- {fuzzer_dir_extra}/fast/bin/{target_with_param}", ],
#        # zhaoxy add for parmesan 
#        # /work/parmesan/bin/fuzzer -c ./targets_objdump.pruned.json -i in -o out -t ./objdump.track -s ./objdump.san.fast -- ./objdump.fast -s -d @@"
#        "parmesan": ["afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -S afl-s -- {target_cmd}", "/work/parmesan/bin/fuzzer  --sync_afl -A  -c ./targets_{target}.pruned.json -i in -o out -t ./track.{target} -s ./san.fast.{target} -- ./fast.{target_with_param}"],      
#        # zhaoxy add for symcc https://github.com/julihoh/libafl_symcc/blob/main/docs/Fuzzing.txt 
#        #"symcc": "afl-fuzz {afl_opts}  -M afl-master -i {input_dir} -o {output_dir}  -m none -- {target_cmd} && afl-fuzz {afl_opts}  -S afl-secondary -i {input_dir} -o {output_dir}  -m none -- {target_cmd} && symcc_fuzzing_helper -o {output_dir} -a afl-secondary -n symcc -- {target_cmd}",
#        "symcc": ["afl-fuzz {afl_opts}  -S afl-secondary -i {input_dir} -o {output_dir}  -m none -- {target_cmd}", "symcc_fuzzing_helper -o {output_dir} -a afl-secondary -n symcc -- {fuzzer_dir_extra}/{target_with_param}"],
       
# }


#libfuzzer parameter description
#        '-print_final_stats=1',
#        # `close_fd_mask` to prevent too much logging output from the target.
#        '-close_fd_mask=3',
#        # Run in fork mode to allow ignoring ooms, timeouts, crashes and
#        # continue fuzzing indefinitely.
#        '-fork=1',
#        '-ignore_ooms=1',
#        '-ignore_timeouts=1',
#        '-ignore_crashes=1',

#        # Don't use LSAN's leak detection. Other fuzzers won't be using it and
#        # using it will cause libFuzzer to find "crashes" no one cares about.
#        '-detect_leaks=0',

#        # Store crashes along with corpus for bug based benchmarking.
#        f'-artifact_prefix={crashes_dir}/',

FUZZERS = {
       "afl": 'afl-fuzz {afl_opts} -i "{input_dir}" -o "{output_dir}" -m none -S afl -- {target_cmd}',
       "aflfast": 'afl-fuzz {afl_opts} -p fast -i {input_dir} -o {output_dir} -m none -D -S aflfast -- {target_cmd}',
       "fairfuzz": 'afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S fairfuzz -- {target_cmd} ',

       #zhaoxy delete for qsym fake fuzzer_stats while [ ! -f {output_dir}/framework/fuzzer_stats ]; do sleep 1; done;
       "qsym": 'afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -M afl-master -- {target_cmd} 2147483647 & afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S framework -- {target_cmd} 2147483647 & /qsym/bin/run_qsym_afl.py -a framework -o {output_dir} -n qsym -- {target_cmd}',
       #"qsym": "tmux new -s qsym -d && tmux split-window && tmux select-pane -U && afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -S framework -- {target_cmd}  && tmux select-pane -D && /qsym/bin/run_qsym.py -a framework -o {output_dir} -n qsym -- /plain{target_cmd}",  
       #AFL_ROOT/afl-fuzz -M afl-master -i $INPUT -o $OUTPUT -- $AFL_CMDLINE
        # run AFL slave
        #AFL_ROOT/afl-fuzz -S afl-slave -i $INPUT -o $OUTPUT -- $AFL_CMDLINE
        # run QSYM
        #$ bin/run_qsym_afl.py -a afl-slave -o $OUTPUT -n qsym -- $QSYM_CMDLINE
       # "radamsa": "afl-fuzz {afl_opts} -RR -i {input_dir} -o {output_dir} -M radamsa -- {target_cmd}", the old mode before afl++2.60
       "radamsa": 'afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -D -S radamsa -- {target_cmd}',
       "honggfuzz": 'honggfuzz -n 1 --input {output_dir}/seeds -z --output {output_dir}/queue  --crashdir {output_dir}/crashes -- {target_cmd}', #-y {output_dir}/sync -Y 10 
       #"libfuzzer": "{target_cmd} --fork=1 {output_dir}/libfuzzer/queue {input_dir}",
       "libfuzzer": '{target_cmd} -fork=1 -ignore_crashes=1 -ignore_timeouts=1 -ignore_ooms=1 -detect_leaks=0 -print_final_stats=1 -close_fd_mask=3 -keep_seed=1 -cross_over_uniform_dist=1 -artifact_prefix={output_dir}/artifacts/ {output_dir}/queue',
       "aflppzxy": 'afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S aflppzxy -- {target_cmd}',
       "aflplusplus": 'afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -D -c {fuzzer_dir_extra}/{target} -M aflplusplus -- {target_cmd}',
       # zhaoxy add for angora 
       # angora_fuzzer -i input -o output -t path/to/taint/program -- path/to/fast/program [argv]
       #"angora": "afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -S afl-s -- {target_cmd} && angora_fuzzer --sync_afl -A  -i {input_dir} -o {output_dir}  -t {fuzzer_dir_extra}/{target} -- {fuzzer_dir_extra2}/{target_with_param}",
      #"angora": "tmux new -s angora -d && tmux split-window && tmux select-pane -U && afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S angora -- {target_cmd} 2147483647 && angora_fuzzer --sync_afl -A  -i {input_dir} -o {output_dir}  -t {fuzzer_dir_extra}/{target} -- {fuzzer_dir_extra2}/{target_with_param}", 
      "angora": "rm -rf {output_dir} && angora_fuzzer -M none -i {input_dir} -o {output_dir} -t {fuzzer_dir_extra}/{target} -- {fuzzer_dir_extra2}/{target_with_param}",
       # zhaoxy add for parmesan 
       # /work/parmesan/bin/fuzzer -c ./targets_objdump.pruned.json -i in -o out -t ./objdump.track -s ./objdump.san.fast -- ./objdump.fast -s -d @@"
       #"parmesan": "afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -S afl-s -- {target_cmd} && /work/parmesan/bin/fuzzer  --sync_afl -A  -c ./targets_{target}.pruned.json -i in -o out -t ./track.{target} -s ./san.fast.{target} -- ./fast.{target_with_param}",

	#zhaoxy add for magma: only use track/fast bin with targets.json with out prune
       #"parmesan": "tmux new -s parmesan -d && tmux split-window && tmux select-pane -U && afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S parmesan -- {target_cmd} 2147483647 && tmux select-pane -D &&  /work/parmesan/bin/fuzzer  --sync_afl -A  -c ./targets_{target}.pruned.json -i {input_dir} -o {output_dir}  -t ./track.{target} -s ./san.fast.{target} -- ./fast.{target_with_param}",
       #"parmesan": "tmux new -s parmesan -d && tmux split-window && tmux select-pane -U && afl-fuzz {afl_opts} -i {input_dir} -o {output_dir} -m none -S parmesan -- {target_cmd} 2147483647 && tmux select-pane -D &&  /work/parmesan/bin/fuzzer  --sync_afl -A  -c ./targets_{target}.json -i {input_dir} -o {output_dir}  -t ./track.{target} -- ./fast.{target_with_param}", 
       "parmesan": 'chmod a+x /targets/run.sh && export AFL_OPTS="{afl_opts}" && export TARGET_CMD="{target_cmd}" && export TARGET_JSON="{fuzzer_dir_extra}/{target}-targets.json"  && export TRACK_BIN="{fuzzer_dir_extra}/track.{target}" && export PARMESAN_CMD="{fuzzer_dir_extra}/fast.{target_with_param}" && /targets/run.sh',          
       # zhaoxy add for symcc https://github.com/julihoh/libafl_symcc/blob/main/docs/Fuzzing.txt 
       #"symcc": "afl-fuzz {afl_opts}  -M afl-master -i {input_dir} -o {output_dir}  -m none -- {target_cmd} && afl-fuzz {afl_opts}  -S afl-secondary -i {input_dir} -o {output_dir}  -m none -- {target_cmd} && symcc_fuzzing_helper -o {output_dir} -a afl-secondary -n symcc -- {target_cmd}",
       #"symcc": "tmux new -s symcc -d && tmux split-window && tmux select-pane -U && afl-fuzz {afl_opts}  -S symcc -i {input_dir} -o {output_dir}  -m none -- {target_cmd} && tmux select-pane -D && symcc_fuzzing_helper -o {output_dir} -a symcc -n symcc -- {fuzzer_dir_extra}/{target_with_param}",
       #"symcc": "afl-fuzz {afl_opts}  -M symcc -i {input_dir} -o {output_dir}  -m none -- {target_cmd} & symcc_fuzzing_helper -o {output_dir} -a symcc -n symcc -- {fuzzer_dir_extra}/{target_with_param}",
       "symcc":'chmod a+x /targets/run.sh && export AFL_OPTS="{afl_opts}" && export TARGET_CMD="{target_cmd}" && export SYMCC_CMD="{fuzzer_dir_extra}/{target_with_param}" && /targets/run.sh',
       "mopt": 'afl-fuzz {afl_opts}  -m none -L 0 -i "{input_dir}" -o "{output_dir}" -S mopt -- {target_cmd}',
       
       
}

def get_pre_cmd(fuzzer):
    if fuzzer == "honggfuzz":
        cmd = "mkdir -p {output_dir}/queue; mkdir -p {output_dir}/crashes; mkdir -p {output_dir}/sync; mkdir -p {output_dir}/seeds;"
        cmd += "for f in `ls {input_dir}`; do cp {input_dir}/$f {output_dir}/seeds/seed-${{f##*/}}; done;"
        return cmd
    if fuzzer == "libfuzzer":
        cmd =  "mkdir -p {output_dir}/queue; mkdir -p {output_dir}/artifacts;"
        cmd += "for f in `ls {input_dir}`; do cp {input_dir}/$f {output_dir}/queue/seed-${{f##*/}}; done;"
        return cmd     
    if fuzzer == "qsym":
        #cmd = "while [ ! -f {output_dir}/framework/fuzzer_stats ]; do sleep 1; done;" #zhaoxy delete for qsym fake fuzzer_stats
        #cmd += "cat {output_dir}/framework/fuzzer_stats"  #zhaoxy delete for qsym fake fuzzer_stats
        #return cmd
        return ""
    print(f"no pre cmd: {fuzzer}")
    return ""

def get_suitebin(suite, fuzzer, sanitize=True):
    if suite == 'google-test-suite':
        if fuzzer == 'qsym' and not sanitize:
            suite = 'google-test-suite-plain'
        elif fuzzer == 'libfuzzer':
            suite = 'google-test-suite-libfuzzer'
        elif fuzzer == 'honggfuzz':
            suite = 'google-test-suite-honggfuzz'
    return SUITEBIN[suite]

def get_suite_dir_extra(suite, fuzzer, tag, sanitize=True):#binutils-angora-fast
    return SUITEDIREXTRA["-".join((suite, fuzzer, tag))]

def get_bin_with_param(target, param):
    return target + param

def replace_input_file(s, fuzzer):
    if fuzzer == "honggfuzz":
        s = s.replace('@@', '___FILE___')
    elif fuzzer == "libfuzzer":
        s = s.replace('@@', '')
    return s

def get_default_args(target):
    return f"{BIN2ARGS[target]}"

def get_default_analysis_bin_dir(target):
    return f"/work/analysis_binaries/{target}.analysis_binaries/"

def get_framework_suite_image_name(target):
    suite = BIN2SUITE[target][0].split("-")[0].lower()
    # zhaoxy modify for framework image simplication
    # return f"fuzzer-framework-{suite}"
    return f"fuzzer-framework-all"


from .fuzzerctrlmsg_pb2 import FuzzerType as PB2FuzzerType

from pathlib import Path
from enum import Enum
from typing import NamedTuple, Optional, List


class FuzzerType(Enum):
    AFL = "afl"
    ANGORA = "angora"  #zhaoxy add for angora start
    SYMCC = "symcc"  #zhaoxy add for symcc    
    QSYM = "qsym"
    LIBFUZZER = "libfuzzer"
    HONGGFUZZ = "honggfuzz"
    AFLFAST = "aflfast"
    FAIRFUZZ = "fairfuzz"
    RADAMSA = "radamsa"
    AFLPPZXY = "aflppzxy"
    AFLPLUSPLUS = "aflplusplus" #zhaoxy add for aflplusplus
    PARMESAN = "parmesan"  #zhaoxy add for parmesan 
    MOPT = "mopt"  #zhaoxy add for mopt
    def __str__(self) -> str:
        return self.value

    def to_pb2_type(self) -> PB2FuzzerType:
        if self == FuzzerType.AFL:
            return PB2FuzzerType.FUZZER_TYPE_AFL
        elif self == FuzzerType.ANGORA: # zhaoxy add for angora start
            return PB2FuzzerType.FUZZER_TYPE_ANGORA
        elif self == FuzzerType.SYMCC: # zhaoxy add for symcc
            return PB2FuzzerType.FUZZER_TYPE_SYMCC
        elif self == FuzzerType.PARMESAN: # zhaoxy add for PARMESAN
            return PB2FuzzerType.FUZZER_TYPE_PARMESAN
        elif self == FuzzerType.QSYM:
            return PB2FuzzerType.FUZZER_TYPE_QSYM
        elif self == FuzzerType.LIBFUZZER:
            return PB2FuzzerType.FUZZER_TYPE_LIBFUZZER
        elif self == FuzzerType.HONGGFUZZ:
            return PB2FuzzerType.FUZZER_TYPE_HONGGFUZZ
        elif self == FuzzerType.AFLFAST:
            return PB2FuzzerType.FUZZER_TYPE_AFLFAST
        elif self == FuzzerType.FAIRFUZZ:
            return PB2FuzzerType.FUZZER_TYPE_FAIRFUZZ
        elif self == FuzzerType.RADAMSA:
            return PB2FuzzerType.FUZZER_TYPE_RADAMSA
        elif self == FuzzerType.AFLPPZXY:
            return PB2FuzzerType.FUZZER_TYPE_AFLPPZXY
        elif self == FuzzerType.AFLPLUSPLUS: #zhaoxy add for aflplusplus
            return PB2FuzzerType.FUZZER_TYPE_AFLPLUSPLUS            
        elif self == FuzzerType.MOPT: #zhaoxy add for aflplusplus
            return PB2FuzzerType.FUZZER_TYPE_MOPT
        raise NotImplementedError


class Config(NamedTuple):
    # Driver config
    fuzzer_type: FuzzerType

    # zhaoxy modify for displaying the name of fuzzer instances
    fuzzer_name: str

    output_dir: Path
    docker_enabled: bool

    # QSYM specific
    afl_path: Optional[Path]
    target_cmdline: List[str]

    # ZeroMQ config
    ctrl_uri: str
    pull_uri: str
    push_uri: str

from .driver import start_driver
from .config import Config, FuzzerType

from argparse import ArgumentParser
from os import environ
from pathlib import Path
import logging

LOGGING_FORMAT = "[%(asctime)s %(levelname)s %(name)s %(threadName)s] %(message)s"


def parse_config() -> Config:
    parser = ArgumentParser(
        description=(
            "Generic CollabFuzz driver that supports a large variety of fuzzers."
        )
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="enable debug logging"
    )

    parser.add_argument(
        "fuzzer_type",
        type=FuzzerType,
        choices=list(FuzzerType),
        help="type of the fuzzer being monitored",
    )
    print("zxy driver 0000000000 parser error")
    # zhaoxy modify for displaying the name of fuzzer instances start
    parser.add_argument(
        "fuzzer_name",
        type=str,
        help="name of the fuzzer instance being monitored",
    )
    # zhaoxy modify for displaying the name of fuzzer instances end

    parser.add_argument(
        "output_dir",
        type=Path,
        help="output directory used by the fuzzer being monitored",
    )
    print("zxy driver 222222222222 parser error")
    parser.add_argument(
        "-d",
        "--enable-docker",
        action="store_true",
        help="enable fuzzer container control functionality",
    )

    parser.add_argument(
        "-a", "--afl-path", type=Path, help="path to AFL (required for qsym)"
    )
    parser.add_argument(
        "target_cmdline", nargs="*", help="target command line (required for qsym)"
    )
    print("zxy driver 333333333 parser error")
    parser.print_help()
    args = parser.parse_args()
    print("zxy driver 44444444444 parser error")
    logging.basicConfig(format=LOGGING_FORMAT)
    if args.verbose:
        logging.getLogger(__name__).setLevel(logging.DEBUG)

    if args.fuzzer_type == FuzzerType.QSYM and (
        args.afl_path is None or not args.target_cmdline
    ):
        parser.error("AFL path and target command are required for qsym")

    ctrl_uri = environ.setdefault("URI_CONTROL", "ipc:///tmp/server-ctrl.ipc")
    pull_uri = environ.setdefault("URI_SCHEDULER", "ipc:///tmp/server-push.ipc")
    push_uri = environ.setdefault("URI_LISTENER", "ipc:///tmp/server-pull.ipc")
    print("zxy driver 1111111 parser error")
    return Config(
        args.fuzzer_type,
        args.fuzzer_name,# zhaoxy modify for displaying the name of fuzzer instances
        args.output_dir,
        args.enable_docker,
        args.afl_path,
        args.target_cmdline,
        ctrl_uri,
        pull_uri,
        push_uri,
    )


def main():
    config1 = parse_config()
    print("zxy driver main{}".format(config1))
    start_driver(config1)

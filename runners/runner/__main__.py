from runner.compose import setup_run, Config
from runner.settings import get_default_analysis_bin_dir, get_default_args
from argparse import ArgumentParser
import runner.build as build
import logging
import docker
import os
import shutil

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO").upper())
logger = logging.getLogger(__name__)

def main():

    parser = ArgumentParser()
    parser.add_argument('target',
                        type=str,
                        help='Target to run')

    parser.add_argument('-f',
                        '--fuzzers',
                        nargs='+',
                        type=str,
                        required=True,
                        #choices=list(FuzzerType),
                        help='Fuzzers to run')


    parser.add_argument('-s', 
                        '--scheduler', 
                        default="broadcast", 
                        required=False,
                        help='Scheduler to use for the framework')

    parser.add_argument('--args',
                        type=str,
                        required=False,
                        help='Program arguments (e.g., "objdump -x @@")')

    parser.add_argument('--analysis-bin-dir',
                        type=str,
                        required=False,
                        help='Directory containing analysis binaries in framework container')

    parser.add_argument('-v',
                        '--verbose',
                        action='store_true',
                        help='Set log level to DEBUG')

    parser.add_argument('--stdout',
                        action='store_true',
                        help='Set log level to DEBUG')

    parser.add_argument('--disable-docker-control',
                        action='store_false',
                        help='Enable driver docker control (pause, resume fuzzer container). Requires privileged mode.')

    parser.add_argument('--enable-afl-affinity',
                        action='store_true',
                        help='Allow AFL to do core pinning (requires host pid map in docker)')

    parser.add_argument('--build-test-all',
                        action='store_true',
                        help='Build and test all available target containers')

    parser.add_argument('--build-test',
                        action='store_true',
                        help='Build and test specified target containers')

    #zhaoxy add for experiment setting experiment_id
    parser.add_argument('-eid',
                        '--experimentid',
                        type=int, 
                        required=False,
                        help='Pass the int para experiment id for repeated experiments')

    #zhaoxy add this parameter for ip setting 
    parser.add_argument('-etime',
                        '--experiment_time',
                        type=int, 
                        required=False,
                        help='Pass the int para experiment id for repeated experiments')


    args = parser.parse_args()


    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logging.getLogger().setLevel(logging.DEBUG)

    if args.build_test_all:
        client = docker.from_env()
        build.init_req(client)
        build.build_and_test_all(client)

    if args.build_test:
        client = docker.from_env()
        build.init_req(client)
        for fuzzer in args.fuzzers:
            build.build_and_test(client, args.target, fuzzer)

    config = Config(analysis_bin_dir=args.analysis_bin_dir if args.analysis_bin_dir is not None else get_default_analysis_bin_dir(args.target) ,
                    args = args.args if args.args is not None else get_default_args(args.target),
                    target=args.target,
                    enable_docker_control=args.disable_docker_control,
                    scheduler=args.scheduler, enable_afl_affinity=args.enable_afl_affinity, 
                    experiment_id=args.experimentid if args.experimentid is not None else 0,
                    experiment_time=args.experiment_time if args.experiment_time is not None else 0,
                    num_fuzzers=len(args.fuzzers)
                    )
    
    #zhaoxy add for copying statsd/prometheus mapping files to compose directory start
    pwd = os.getcwd()
    logger.info("zxy pwd {}".format(pwd))
    father_path=os.path.abspath(os.path.dirname(pwd)+os.path.sep+".")
    logger.info("zxy father_path {}".format(father_path))
    base_name = os.path.basename(father_path)
    logger.info("zxy base_name {}".format(base_name))
    if "runners"!=base_name:
        logger.error("please make sure the parent directory is runners!")

    if not os.path.exists("grafana-afl++.json"): 
        shutil.copy(os.path.join(father_path,"grafana-afl++.json"),pwd)
    if not os.path.exists("prometheus.yml"):    
        shutil.copy(os.path.join(father_path,"prometheus.yml"),pwd)
    if not os.path.exists("statsd_mapping.yml"):    
        shutil.copy(os.path.join(father_path,"statsd_mapping.yml"),pwd)
    #zhaoxy add for copying statsd/prometheus mapping files to compose directory end

    result = setup_run(config, args.target, args.fuzzers)
    if args.stdout:
        print(result)
    else:
        if os.path.exists("docker-compose.yaml"):
            logger.error("Output 'docker-compose.yaml' file already exists!")
        else:
            with open("docker-compose.yaml", "w+") as f:
                f.write(result)


if __name__ == '__main__':
    main()

import io
import docker
import tempfile
import os
import logging
import math
from argparse import ArgumentParser


from runner.settings import BIN2SUITE, BIN2ARGS, SUITEOPTS, SUITEBIN, FUZZERS, ONLY_PLAIN, replace_input_file, get_suitebin, get_pre_cmd, get_framework_suite_image_name, get_suite_dir_extra



MAX_RETRIES = 5

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO").upper())
logger = logging.getLogger(__name__)

#    && echo  sh -c "'{cmd}'" >> /entry.sh && chmod +x /entry.sh
# zhaoxy modify for fuzzer image simplication start 
# add line25-39 to delete file/directory created by other target building
# zhaoxy modify for fuzzer image simplication end 
def gen_docker_file(base_container, cmd, bpath='.', target_cmd="", pre_cmd=""):
    print(f'Testing cmd:{cmd} bpath:{bpath} target_cmd:{target_cmd} pre_cmd:{pre_cmd}')
    return  f"""
    FROM {base_container}
    RUN if [ -d "/in" ]; then	\
	rm -rf /in \
    ;fi \
    && if [ -d "/out" ]; then	\
	rm -rf /out \
    ;fi \
    && if [ -d "/data" ]; then	\
	rm -rf /data \
    ;fi \
    && if [ -e "/test.sh" ]; then	\
	rm -rf /test.sh \
    ;fi \
    && if [ -e "/entry.sh" ]; then	\
	rm -rf /entry.sh \
    ;fi	\                
    && mkdir /in && mkdir /out && mkdir /data \
    && echo "#!/usr/bin/env bash" > /entry.sh && echo "set -Eeuxo pipefail" >> /entry.sh && echo "mkdir -p \$OUTPUT_DIR || true" >> /entry.sh && echo "hostname >> \$OUTPUT_DIR/docker_hostname" >> /entry.sh && echo '{pre_cmd}' >> /entry.sh \
    && echo  '{cmd}' >> /entry.sh && chmod +x /entry.sh
    ENV INPUT_DIR=/in OUTPUT_DIR=/out TIMEOUT=10s AFL_STATSD_TAGS_FLAVOR=dogstatsd AFL_STATSD=1 AFL_STATSD_PORT=9125  AFL_STATSD_HOST="172.24.0.3"
    CMD ["/entry.sh"]
    """

# def gen_docker_file_two(base_container, cmd1, cmd2, bpath='.', target_cmd="", pre_cmd=""):
#     return  f"""
#     FROM {base_container}
#     USER root
#     RUN if [ -d "/in" ]; then	\
# 	rm -rf /in \
#     ;fi \
#     && if [ -d "/out" ]; then	\
# 	rm -rf /out \
#     ;fi \
#     && if [ -d "/data" ]; then	\
# 	rm -rf /data \
#     ;fi \
#     && if [ -e "/test.sh" ]; then	\
# 	rm -rf /test.sh \
#     ;fi \
#     && if [ -e "/entry.sh" ]; then	\
# 	rm -rf /entry.sh \
#     ;fi \
#     && mkdir /in && mkdir /out && chown -R coll:coll /out && mkdir /data && chown -R coll:coll /data \
#     && echo "#!/usr/bin/env bash" > /entry.sh && echo "set -Eeuxo pipefail" >> /entry.sh && echo "mkdir -p \$OUTPUT_DIR || true" >> /entry.sh && echo "hostname >> \$OUTPUT_DIR/docker_hostname" >> /entry.sh && echo cd {bpath} >> /entry.sh && echo '{pre_cmd}' >> /entry.sh \
#     && echo   sh -c "'{cmd1} && {cmd2}'"  >> /entry.sh \
#     && echo "#!/usr/bin/env bash" > /test.sh && echo "set -Eeuxo pipefail" >> /test.sh && echo cd {bpath} >> /test.sh && echo mkdir -p \$OUTPUT_DIR/framework/ >> /test.sh && echo ln -s /in \$OUTPUT_DIR/framework/queue >> /test.sh && echo "command_line: /fuzzers/afl/afl-fuzz -- {target_cmd}" >> /tmp/fuzzer_stats && echo cp /tmp/fuzzer_stats \$OUTPUT_DIR/framework >> /test.sh && echo '{pre_cmd}' >> /test.sh && echo -e \"timeout --preserve-status \$TIMEOUT {cmd1} || true\" >> /test.sh && chmod +x /entry.sh && chmod +x /test.sh
#     ENV INPUT_DIR=/in OUTPUT_DIR=/out TIMEOUT=10s AFL_STATSD_TAGS_FLAVOR=dogstatsd AFL_STATSD=1 AFL_STATSD_PORT=9125  AFL_STATSD_HOST="172.24.0.3"
#     USER coll
#     CMD ["/entry.sh"]
#     """

def build_req(client, fuzzer):
    name = f'fuzzer-{fuzzer}'
    try:
        client.images.get(name)
    except docker.errors.ImageNotFound as e:
        logger.warn(f'Base image {name} not found. Building...')
        #TODO: pull in image/ build
        #os.system(f'make -j`nproc` {name}')

def test_container(client, image, fuzzer_type="afl"):
    retries = 0
    while retries < MAX_RETRIES:
        logger.info(f'Testing {image} [{retries}] {fuzzer_type}')
        try:
            with tempfile.TemporaryDirectory() as tmp, tempfile.TemporaryDirectory() as tmp_input:
                volumes = {tmp: {'bind': '/out', 'mode': 'rw'}}
                inputs = os.path.join(os.getcwd(), "inputs", image)
                if os.path.exists(inputs):
                    logger.info(f"Use inputs from {inputs}")
                    volumes[inputs] = {'bind': '/in', 'mode': 'ro'}
                else:
                    os.system(f"echo AAAAAAAA > {tmp_input}/seed")
                    volumes[tmp_input] = {'bind': '/in', 'mode': 'ro'}
                timeout = int(5 * math.pow(2,retries))
                clog = client.containers.run(image, auto_remove = True, command = "/test.sh", environment = {"TIMEOUT": str(timeout)+"s", "OUTPUT_DIR": "/out"}, volumes=volumes, cap_add=['SYS_PTRACE'])
                if fuzzer_type == "libfuzzer" or fuzzer_type == "honggfuzz":
                    queue = os.listdir(f'{tmp}/queue')
                else:
                    queue = os.listdir(f'{tmp}/{fuzzer_type}/queue')
                if len(queue) > 0:
                    retries = MAX_RETRIES

                if retries == MAX_RETRIES - 1:
                    logger.error(f"could not generate queue files for {image}")

        except docker.errors.ContainerError as e:
            logger.error(f'Error for {image}: {e}')
            raise e
        retries += 1

def pull_image(client, remote, name):
    remote_name = f'{remote}/{name}:latest'
    logger.info(f'Pulling remote image {remote_name}')
    image = client.images.pull(remote_name)
    assert(image)
    logger.debug(f'Tag image {remote_name} as {name}')
    assert(image.tag(name))

def push_image(client, remote, name):
    remote_name = f'{remote}/{name}:latest'
    image = client.images.get(name)
    assert(image)
    logger.debug(f'Tag image {name} as {remote_name}')
    assert(image.tag(remote_name))
    logger.info(f'Push image {remote_name}')
    client.images.push(remote_name)

def pull_reqs(client, remote, framework_img_name):
    pull_image(client, remote, framework_img_name)
    pull_image(client, remote, "fuzzer-generic-driver")

def push_reqs(client, remote, framework_img_name):
    push_image(client, remote, framework_img_name)
    push_image(client, remote, "fuzzer-generic-driver")

def push(client, remote, target, fuzzer, enable_test=False):
    name = f'fuzzer-{fuzzer}-{target}:latest'
    remote_name = f'{remote}/fuzzer-{fuzzer}-{target}:latest'
    image = client.images.get(name)
    logger.debug(f'Tag image {name} as {remote_name}')
    assert(image.tag(remote_name))
    logger.info(f'Push image {remote_name}')
    client.images.push(remote_name)

def pull(client, remote, target, fuzzer, enable_test=False):
    name = f'fuzzer-{fuzzer}-{target}:latest'
    remote_name = f'{remote}/fuzzer-{fuzzer}-{target}:latest'
    logger.info(f'Pulling remote image {remote_name}')
    image = client.images.pull(remote_name)
    logger.debug(f'Tag remote image {remote_name} as {name}')
    assert(image.tag(name))
    if enable_test:
        fuzzer_type = fuzzer
        test_container(client, name, fuzzer_type=fuzzer_type)

def build_and_test(client, target, fuzzer):
    build(client, target, fuzzer, enable_test=True)

def build(client, target, fuzzer, enable_test=False):
    data = BIN2SUITE[target]
    suite = BIN2SUITE[target][0]
    binary = data[1]
    bpath = os.path.dirname(get_suitebin(suite, fuzzer).format(bin=binary, ext=""))
    ext = ""
    if len(data) > 2:
        # For target applications with multiple bins (e.g., openssl-1.1.0c)
        ext = "-{}".format(data[2])
    target_cmd = "{bin} {args}".format(bin=get_suitebin(suite, fuzzer, sanitize=False).format(bin=binary, ext=ext), args=BIN2ARGS[target])

    fuzzer_dir_extra = ""
    fuzzer_dir_extra2 = ""
    if "angora" == fuzzer:
        fuzzer_dir_extra = get_suite_dir_extra(suite, fuzzer, "track", sanitize=False).format(bin=binary)
        fuzzer_dir_extra2 = get_suite_dir_extra(suite, fuzzer, "fast", sanitize=False).format(bin=binary)
    elif "symcc" == fuzzer:
        fuzzer_dir_extra = get_suite_dir_extra(suite, fuzzer, "symcc", sanitize=False).format(bin=binary)
    elif "parmesan" == fuzzer:
        fuzzer_dir_extra = get_suite_dir_extra(suite, fuzzer, "parmesan", sanitize=False).format(bin=binary)    
    elif "aflplusplus" == fuzzer:
        fuzzer_dir_extra = get_suite_dir_extra(suite, fuzzer, "cmplog", sanitize=False).format(bin=binary)    
    target_with_param = "{target} {args}".format(target=target, args=BIN2ARGS[target])
    fuzzer_target_cmd = target_cmd
    base_container = f'fuzzer-{fuzzer}'
    new_container = f'fuzzer-{fuzzer}-{target}'
    afl_opts = SUITEOPTS[suite]
    # fuzzer_cmds = FUZZERS[fuzzer]
    # cmds = []
    # # zhaoxy modify for angora,parmesan  key:target
    # # cmd = fuzzer_cmd.format(target_cmd=fuzzer_target_cmd, target=target,input_dir="\$INPUT_DIR", output_dir="\$OUTPUT_DIR", afl_opts=afl_opts)
    # for fuzzer_cmd in fuzzer_cmds:
    #     cmd = fuzzer_cmd.format(target_cmd=fuzzer_target_cmd, fuzzer_dir_extra=fuzzer_dir_extra,target_with_param=target_with_param,target=target,input_dir="\$INPUT_DIR", output_dir="\$OUTPUT_DIR", afl_opts=afl_opts)
    #         ## Replace @@ for some fuzzers
    #     cmd = replace_input_file(cmd, fuzzer)
    #     cmds.append(cmd)
    
    # pre_cmd = get_pre_cmd(fuzzer).format(output_dir="$OUTPUT_DIR", input_dir="$INPUT_DIR")
    # if len(cmds)==2:
    #     print("zxy...{}",len(cmds))
    #     fileobj = io.BytesIO(gen_docker_file_two(base_container, cmds[0], cmds[1], bpath=bpath, target_cmd=target_cmd, pre_cmd=pre_cmd).encode())
    # else:   
    #     fileobj = io.BytesIO(gen_docker_file(base_container, cmds[0], bpath=bpath, target_cmd=target_cmd, pre_cmd=pre_cmd).encode())

    fuzzer_cmd = FUZZERS[fuzzer]
    # zhaoxy modify for angora,parmesan  key:target
    # cmd = fuzzer_cmd.format(target_cmd=fuzzer_target_cmd, target=target,input_dir="\$INPUT_DIR", output_dir="\$OUTPUT_DIR", afl_opts=afl_opts) 
    cmd = fuzzer_cmd.format(target_cmd=fuzzer_target_cmd, fuzzer_dir_extra=fuzzer_dir_extra,fuzzer_dir_extra2=fuzzer_dir_extra2,target_with_param=target_with_param,target=target,input_dir="$INPUT_DIR", output_dir="$OUTPUT_DIR", afl_opts=afl_opts)
    pre_cmd = get_pre_cmd(fuzzer).format(output_dir="$OUTPUT_DIR", input_dir="$INPUT_DIR")
    cmd = replace_input_file(cmd, fuzzer)
    fileobj = io.BytesIO(gen_docker_file(base_container, cmd, bpath=bpath, target_cmd=target_cmd, pre_cmd=pre_cmd).encode())

    logger.info(f'Building {new_container}')
    
    # zhaoxy modify for fuzzer image simplication 
    client.images.build(fileobj=fileobj, tag=new_container, rm=True)
    # client.images.build(fileobj=fileobj, tag=base_container, rm=True)
    
    fuzzer_type = fuzzer
    if enable_test:
        test_container(client, new_container, fuzzer_type=fuzzer_type)


def build_and_test_suite(client, suite):
    for fuzzer, fuzzer_cmd in FUZZERS.items():
        for target, data in BIN2SUITE.items():
            if suite != data[0]:
                continue
            build_and_test(client, target, fuzzer)

def build_and_test_all(client):
    suites = set(map(lambda e: e[0], BIN2SUITE.values()))
    for test_suite in suites:
        build_and_test_suite(client, test_suite)


def init_req(client):
    for fuzzer in FUZZERS:
        build_req(client, fuzzer)
    #os.system("echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope > /dev/null 2>&1")
    #os.system("echo core | sudo tee /proc/sys/kernel/core_pattern > /dev/null 2>&1")


def main():

    parser = ArgumentParser()

    parser.add_argument('-f',
                        '--fuzzers',
                        nargs='+',
                        type=str,
                        required=False,
                        default = [],
                        help='Fuzzers to build for (build all if empty)')


    parser.add_argument('-t', 
                        '--targets', 
                        nargs='+',
                        type=str,
                        required=False,
                        default = [],
                        help='Targets to build (build all if empty)')

    parser.add_argument('-s', 
                        '--suites', 
                        nargs='+',
                        type=str,
                        required=False,
                        default = [],
                        help='Suites to build (build all if empty)')

    parser.add_argument('--remote',
                        type=str,
                        required=False,
                        default = None,
                        help='Remote docker registry to pull from')

    parser.add_argument('--push-remote',
                        type=str,
                        required=False,
                        help='Push selected targets to remote')

    parser.add_argument('--pull-reqs',
                        action='store_true',
                        help='Pull framework containers (requires --remote))')

    parser.add_argument('--push-reqs',
                        action='store_true',
                        help='Push framework containers (requires --push-remote)')

    parser.add_argument('--test',
                        action='store_true',
                        help='Enable testing of containers')

    parser.add_argument('--disable-reqs',
                        action='store_true',
                        help='Do not execute requirements to run fuzzers')

    parser.add_argument('-v',
                        '--verbose',
                        action='store_true',
                        help='Set log level to DEBUG')

    args = parser.parse_args()


    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logging.getLogger().setLevel(logging.DEBUG)

    fuzzers = FUZZERS.keys()
    if args.fuzzers:
        fuzzers = args.fuzzers
        logger.info(f'Selected fuzzers {fuzzers}')

    targets = BIN2SUITE.keys()
    if args.targets:
        targets = args.targets
        logger.info(f'Selected targets {targets}')

    suites = list(map(lambda e: e[0], BIN2SUITE.values()))
    if args.suites:
        suites = args.suites
        logger.info(f'Selected suites {suites}')

    framework_suite_image_names = set([
        get_framework_suite_image_name(target) for target in targets
        if BIN2SUITE[target][0] in suites
    ])

    client = docker.from_env()
    if not args.disable_reqs and args.test:
        logger.info(f'Enabling system requirements (requires root)')
        init_req(client)

    if args.remote and args.pull_reqs:
        for img_name in framework_suite_image_names:
            pull_reqs(client, args.remote, img_name)

    if args.push_remote and args.push_reqs:
        for img_name in framework_suite_image_names:
            push_reqs(client, args.push_remote, img_name)

    for fuzzer in fuzzers:
        for target in targets:
            if BIN2SUITE[target][0] not in suites:
                continue
            if args.remote:
                pull(client, args.remote, target, fuzzer, enable_test = args.test)
            else:
                build(client, target, fuzzer, enable_test = args.test)

            if args.push_remote:
                push(client, args.push_remote, target, fuzzer)


    
if __name__ == "__main__":
    main()

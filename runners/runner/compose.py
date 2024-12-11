import yaml
import collections
import grp
import tempfile
import os
import subprocess
# zhaoxy add for bins with seeds BIN2SEEDS
from runner.settings import BIN2ARGS, SUITEBIN, BIN2SUITE, BIN2SEEDS, get_default_args, get_default_analysis_bin_dir, \
    get_suitebin, get_framework_suite_image_name

import logging
from argparse import ArgumentParser

VERBOSE = True

LISTENER_PORT = 3000
CONTROL_PORT = 3001
SCHEDULER_PORT = 3002

FUZZER_COUNT = collections.Counter()

ipCounter = 0  # zhaoxy add for statsd
#zhaoxy add for experiment setting experiment_id
Config = collections.namedtuple('Config', ['args', 'analysis_bin_dir', 'target', 'enable_docker_control', 'scheduler',
                                           'enable_afl_affinity','experiment_id', 'experiment_time', 'num_fuzzers'],)
 

logger = logging.getLogger(__name__)


# zhaoxy add for statsd start
# def setup_networks():
# # networks:
# #   network_statsd_zxy:
# #     ipam:
# #       config:
# #         - subnet: 172.24.0.0/16
# #           gateway: 172.24.0.1
#     r1 = {}
#     r1["subnet"] = f"172.24.0.0/16"
#     r1["gateway"] =  f"172.24.0.1"
#     r2 = {}
#     r2["config"] =  [r1]
#     r3 ={}
#     r3["network_statsd_zxy"] = {"ipam":r2}
#     return "networks", r3

def setup_networks():
    # networks:
    #   network_statsd_zxy:
    #     ipam:
    #       config:
    #         - subnet: 172.24.0.0/16
    #           gateway: 172.24.0.1
    r1 = {}
    r1["name"] = f"statsdserver_network_statsd_zxy"
    r2 = {}
    r2["external"] = r1
    r3 = {}
    r3["network_statsd_zxy"] = r2
    return "networks", r3


def setup_statsd_prometheus():
    r = {}
    r["image"] = "prom/prometheus"
    r["container_name"] = "prometheus"
    r["volumes"] = ['./prometheus.yml:/prometheus.yml']
    r["command"] = ["--config.file=/prometheus.yml"]
    r["restart"] = "unless-stopped"
    r["ports"] = ["9090:9090"]

    r1 = {}
    #zhaoxy add for experiment setting experiment_id
    r1["network_statsd_zxy"] = {"ipv4_address": f'172.24.0.2'}  
    r["networks"] = r1
    return "prometheus", r


def setup_statsd_exporter():
    r = {}
    r["image"] = "fuzzer-statsd-exporter-zxy"
    r["container_name"] = "statsd_exporter"
    r["volumes"] = ['./statsd_mapping.yml:/statsd_mapping.yml']
    r["command"] = ["--statsd.mapping-config=/statsd_mapping.yml"]
    r["restart"] = "unless-stopped"
    r["ports"] = ["9102:9102/tcp", "8125:9125/udp"]

    r1 = {}
    r1["network_statsd_zxy"] = {"ipv4_address": f'172.24.0.3'}
    r["networks"] = r1
    return "statsd_exporter", r


def setup_statsd_grafana():
    r = {}
    r["image"] = "grafana/grafana"
    r["container_name"] = "grafana"
    r["restart"] = "unless-stopped"
    r["ports"] = ["3000:3000"]

    r1 = {}
    r1["network_statsd_zxy"] = {"ipv4_address": f"172.24.0.4"}
    r["networks"] = r1
    return "grafana", r


def setup_framework(config):
    # analysis_bin_dir = "/home/coll/analysis_binaries/objdump.analysis_binaries/"
    analysis_bin_dir = config.analysis_bin_dir
    args = config.args
    r = {}
    r["image"] = get_framework_suite_image_name(config.target)

    # zhaoxy add for bins with seeds
    if config.target in BIN2SEEDS:
        r["volumes"] = [f'data-vol:/data', f'./seeds/{BIN2SEEDS[config.target]}:/in']
    else:
        r["volumes"] = [f'data-vol:/data', './input:/in']

    r["environment"] = {
        "URI_LISTENER": f"tcp://*:{LISTENER_PORT}",
        "URI_CONTROL": f"tcp://*:{CONTROL_PORT}",
        "URI_SCHEDULER": f"tcp://*:{SCHEDULER_PORT}",
        "OUTPUT_DIR": "/data/collab/out",
        "INPUT_DIR": "/in",
        "ANALYSIS_BIN_DIR": analysis_bin_dir,
        "ARG": args,
        "SCHEDULER": config.scheduler,
    }
    if VERBOSE:
        r["environment"]["RUST_LOG"] = "debug"

    r1 = {}
    #zhaoxy add for ip setting :which time of all repeated testsexperimentTime = config.experiment_id #zhaoxy add for ip setting :which time of all repeated tests
    r1["network_statsd_zxy"] = {"ipv4_address": f"172.24.{config.experiment_id}.5"}
    r["networks"] = r1

    #return "framework", r
    return f"framework-exid{config.experiment_id}", r


# zhaoxy add for statsd end

# fuzzer_id is fuzzer_name actually
def setup_driver(config, fuzzer_id, fuzzer_type, target):
    r = {}
    args = config.args
    binary = BIN2SUITE[target][1]
    suite = BIN2SUITE[target][0]
    ext = ""
    if len(BIN2SUITE[target]) > 2:
        ext = BIN2SUITE[target][2]

    bpath = get_suitebin(suite, fuzzer_type).format(bin=binary, ext=ext)

    r["image"] = "fuzzer-generic-driver"
    r["volumes"] = [f'data-vol:/data']
    #r["links"] = [f"framework"]
    r["links"] = [f"framework-exid{config.experiment_id}"]
    r["depends_on"] = [f"framework-exid{config.experiment_id}"]

    if config.enable_docker_control:
        r["volumes"].append("/var/run/docker.sock:/var/run/docker.sock")
        r["pid"] = "host"

    r["environment"] = {
        "URI_LISTENER": f"tcp://framework-exid{config.experiment_id}:{LISTENER_PORT}",
        "URI_CONTROL": f"tcp://framework-exid{config.experiment_id}:{CONTROL_PORT}",
        "URI_SCHEDULER": f"tcp://framework-exid{config.experiment_id}:{SCHEDULER_PORT}",
        "OUTPUT_DIR": f"/data/{fuzzer_id}/",

        # zhaoxy modify for displaying the name of fuzzer instances
        # "FUZZER_NAME": fuzzer_type,
        "FUZZER_TYPE": fuzzer_type,
        "FUZZER_NAME": fuzzer_id,

        # "CONTAINER_ID": f"compose_{fuzzer_id}_1" if config.enable_docker_control else "none",
        "ARG": f"{bpath} {args}",
    }

    ip = ipCounter * 2 + 11
    r1 = {}
    #ipseg = 24 + experimentId #zhaoxy add for experiment setting experiment_id
    r1["network_statsd_zxy"] = {"ipv4_address": f"172.24.{config.experiment_id}.{ip}"}
    r["networks"] = r1

    return f'driver-{fuzzer_id}', r


def setup_fuzzer(config, fuzzer, target):
    count = FUZZER_COUNT[fuzzer]
    name = f'{fuzzer}-{count}-exid{config.experiment_id}'
    r = {}

    # zhaoxy modify for fuzzer image simpication ,no image with name like fuzzer-afl-objdump would be generated
    r["image"] = f'fuzzer-{fuzzer}-{target}'
    # r["image"] = f'fuzzer-{fuzzer}'
    
    #r["mem_limit"] = "512m"
    #r["mem_reservation"] = "128M"
    #r["cpus"] = "0.9"

    if config.target in BIN2SEEDS:
        r["volumes"] = [f'data-vol:/data', f'./seeds/{BIN2SEEDS[config.target]}:/in']
    else:
        r["volumes"] = [f'data-vol:/data', f'./input:/in']

    r["depends_on"] = [f"framework-exid{config.experiment_id}", f"driver-{name}"]
    r["environment"] = {
        "OUTPUT_DIR": f'/data/{name}',
    }
    if config.enable_afl_affinity:
        r["pid"] = "host"
    else:
        r["environment"]["AFL_NO_AFFINITY"] = "1"

    if fuzzer == "qsym":
        r["stop_signal"] = "SIGKILL"

    # zhaoxy add for fuzzer banner for visualization 
    r["environment"]["AFL_STATSD_FUZZER_BANNER"] = name

    FUZZER_COUNT[fuzzer] += 1

    ip = ipCounter * 2 + 10
    r1 = {}
    #ipseg = 24 + experimentId #zhaoxy add for experiment setting experiment_id
    r1["network_statsd_zxy"] = {"ipv4_address": f"172.24.{config.experiment_id}.{ip}"}
    r["networks"] = r1

    return name, r


def generate_compose(compose):
    return yaml.dump(compose)


def setup_run(config, target, fuzzers):# fuzzers represents the array of fuzzer types
    services = {}

    # zhaoxy add for statsd start
    global ipCounter

    #ip_segment = experimentId
    # services["statsd_exporter"] = setup_statsd_exporter( )[1]
    # services["grafana"] = setup_statsd_grafana( )[1]
    # services["prometheus"] = setup_statsd_prometheus()[1]
    # zhaoxy add for statsd end

    framework_name, framework_data = setup_framework(config)
    services[framework_name] = framework_data
    #services["framework"] = setup_framework(config)[1]
    for fuzzer in fuzzers:
        ipCounter += 1
        fuzzer_name, fuzzer_data = setup_fuzzer(config, fuzzer, target)
        driver_name, driver_data = setup_driver(config, fuzzer_name, fuzzer, target)
        services[fuzzer_name] = fuzzer_data
        services[driver_name] = driver_data

    compose = {}
    compose["version"] = '2'

    compose["networks"] = setup_networks()[1]  # zhaoxy add for statsd

    compose["services"] = services
    compose["volumes"] = {"data-vol": {}}

    if os.path.exists("docker-compose.yaml"):  # zhaoxy add for error "file already exsists"
        os.remove("docker-compose.yaml")

    res = generate_compose(compose)

    # Create default seed in input folder
    if not os.path.exists("input"):  # zhaoxy add for error "file already exsists"
        os.mkdir("input")
    with open(os.path.join("input", "seed"), "w") as f:
        f.write("AAAAAAAA")
    return res


def do_run(config, target, fuzzers, timeout=0):
    # Create tmp dir
    with tempfile.TemporaryDirectory() as tmp:
        orig_cwd = os.getcwd()
        os.chdir(tmp)
        # Generate compose
        with open("docker-compose.yaml", "w+") as f:
            f.write(setup_run(config, target, fuzzers))

        # Load input seeds

        # Docker compose up
        subprocess.call("docker-compose up -d")

        # Wait
        if timeout > 0:
            time.sleep(timeout)

        # Retrieve results
        # docker-compose ps -q --filter NAME=fuzzer-framework
        # docker cp XXX:/data ./out

        # Teardown
        subprocess.call("docker-compose down")
        os.chdir(orig_cwd)

    pass

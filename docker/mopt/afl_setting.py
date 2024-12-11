#!/usr/bin/python3

from __future__ import print_function

import os
 
#zxy add configs for cpu setting
targetCommandsCpu = 'docker run --user root --privileged --name  fuzzer-mopt-build fuzzer-mopt bash -ic \
"echo core >/proc/sys/kernel/core_pattern; \
echo 0 | tee /proc/sys/kernel/core_uses_pid; \
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; \
echo 0 | tee /proc/sys/kernel/yama/ptrace_scope; \
echo 1 | tee /proc/sys/kernel/sched_child_runs_first; \
echo 0 | tee /proc/sys/kernel/randomize_va_space"; '
 


os_str = \
"""
{targetCommands}
docker commit fuzzer-mopt-build fuzzer-mopt;
docker stop fuzzer-mopt-build; 
docker rm fuzzer-mopt-build;
""".format(targetCommands=targetCommandsCpu)
  
print(os_str)
os.system(os_str)



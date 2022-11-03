#!/usr/bin/env python3
import sys
import os
import subprocess
import argparse
from concurrent import futures

TARGETS = [
   "freetype2-2017",
   "file_magic_fuzzer"
]


def build_target(target, serial):
    env_vars = {
        'CC': 'gclang',
        'CXX': 'gclang++',
        'CFLAGS': '-fprofile-instr-generate -fcoverage-mapping -gline-tables-only',
        'CXXFLAGS': '-fprofile-instr-generate -fcoverage-mapping -gline-tables-only -fPIC -stdlib=libc++',
        'LIBFUZZER_SRC': '/work/llvm-project/compiler-rt/lib/fuzzer/',
        'FUZZING_ENGINE': 'coverage'
    }

    if serial:
        stdout = None
        stderr = None
    else:
        stdout = subprocess.PIPE
        stderr = subprocess.PIPE

    env = os.environ.copy()
    env.update(env_vars)
    return subprocess.run(['/work/fuzzbench/build.sh', target],
                          env=env,
                          stdout=stdout,
                          stderr=stderr,
                          text=True)


def start_build(targets, serial):
    if serial:
        num_workers = 1
    else:
        # Limit workers to CPU count since the builds are themselves parallel
        num_workers = os.cpu_count() // 2

    with futures.ThreadPoolExecutor(num_workers) as executor:
        future_to_target = {}
        for target in targets:
            future = executor.submit(build_target, target, serial)
            future_to_target[future] = target

        for future in futures.as_completed(future_to_target):
            completed = future.result()
            if completed.returncode != 0:
                print(
                    f'Failed building {future_to_target[future]}! Output was:',
                    completed.stdout,
                    "STDERR",
                    completed.stderr,
                    sep="\n",
                    file=sys.stderr)
                sys.exit(1)

            print(f'Built: {future_to_target[future]}', flush=True)


def main(args):
    print(f'Beginning to build in {args.mode} mode', flush=True)
    start_build(TARGETS, args.mode == 'serial')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('mode',
                        choices=['serial', 'parallel'],
                        default='parallel')
    args = parser.parse_args()
    main(args)

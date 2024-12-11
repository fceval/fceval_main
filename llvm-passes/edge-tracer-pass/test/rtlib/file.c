// RUN: %clang_tracer %s %rtlib_tracer %rtdeps -o %t
// RUN: rm -f %t.csv
// RUN: TRACER_ENABLE_FILE_OUTPUT=1 TRACER_OUTPUT_FILE=%t.csv %t yolo
// RUN: cat %t.csv | FileCheck %s
#include <stdio.h>
#include <stdlib.h>

// CHECK: source,target,count
int main(int argc, char *argv[argc + 1]) {
  if (argc != 2) {
    printf("usage: %s message\n", argv[0]);
    exit(1);
  }
// CHECK: 0x{{[0-9a-f]+}},0x{{[0-9a-f]+}},{{[0-9]+}}
// CHECK-NOT: 0x0,
  puts("Correct usage!");

  return 0;
}

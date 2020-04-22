#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct byte_code_t {
    uint32_t *code;
    size_t length;
} byte_code_t;

#ifdef __cplusplus
extern "C" {
#endif

bool
clspvBuildProgram(void *compiler_library,
                  char const *program,
                  char const *options,
                  byte_code_t *byte_code);

void
clspvDestroyByteCode(byte_code_t *byte_code);

#ifdef __cplusplus
}
#endif

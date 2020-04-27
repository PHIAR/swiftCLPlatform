#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum function_argument_e {
    function_argument_unknown,
    function_argument_buffer,
    function_argument_constant,
    function_argument_sampler,
} function_argument_e;

typedef struct byte_code_t {
    uint32_t *code;
    size_t length;
    function_argument_e *function_arguments;
    size_t function_arguments_count;
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

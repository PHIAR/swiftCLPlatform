#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum function_argument_e {
    function_argument_unknown,
    function_argument_buffer,
    function_argument_buffer_ubo,
    function_argument_constant,
    function_argument_pod,
    function_argument_pod_push_constant,
    function_argument_pod_ubo,
    function_argument_sampler,
} function_argument_e;

typedef struct function_argument_t {
    char const *entry_point;
    function_argument_e type;
    size_t bindingIndex;
    size_t index;
    size_t offset;
    size_t size;
} function_argument_t;

typedef struct byte_code_t {
    uint32_t *code;
    size_t length;
    function_argument_t *function_arguments;
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

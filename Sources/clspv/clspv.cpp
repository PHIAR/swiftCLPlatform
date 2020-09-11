#include <cassert>
#include <cstring>
#include <dlfcn.h>
#include <string>
#include <clspv/ArgKind.h>
#include <clspv/Compiler.h>
#include <clspv/DescriptorMap.h>

#include "clspv.h"

#if defined(__ANDROID__)
static auto const &compileFromSourceStringSymbolName = "_ZN5clspv23CompileFromSourceStringERKNSt6__ndk112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEES8_S8_PNS0_6vectorIjNS4_IjEEEEPNS9_INS_8version018DescriptorMapEntryENS4_ISE_EEEE";
#elif defined(__linux__)
static auto const &compileFromSourceStringSymbolName = "_ZN5clspv23CompileFromSourceStringERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_S7_PSt6vectorIjSaIjEEPS8_INS_8version018DescriptorMapEntryESaISD_EE";
#elif defined(__APPLE__)
static auto const &compileFromSourceStringSymbolName = "_ZN5clspv23CompileFromSourceStringERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_S7_PSt6vectorIjSaIjEEPS8_INS_8version018DescriptorMapEntryESaISD_EE";
#endif

bool
clspvBuildProgram(void *compiler_library,
                  char const *program,
                  char const *options,
                  byte_code_t *byte_code)
{
    using CompileFromSourceString = int32_t (*)(std::string const &,
                                                std::string const &,
                                                std::string const &,
                                                std::vector <uint32_t> *,
                                                std::vector <clspv::version0::DescriptorMapEntry> *);

    auto const &_program = std::string(program);
    auto const &_options = std::string(options);
    auto &&descriptor_map_entries = std::vector <clspv::version0::DescriptorMapEntry> ();
    auto &&output_binary = std::vector <uint32_t> ();
    auto const &compileFromSourceString = reinterpret_cast <CompileFromSourceString> (dlsym(compiler_library, compileFromSourceStringSymbolName                                     ));

    if (compileFromSourceString == nullptr) {
        return false;
    }

    if (compileFromSourceString(_program, "", _options, &output_binary, &descriptor_map_entries)) {
        return false;
    }

    byte_code->code = static_cast <uint32_t *> (calloc(output_binary.size(), sizeof(uint32_t)));
    byte_code->length = output_binary.size();
    memcpy(byte_code->code, &output_binary[0], output_binary.size() * sizeof(uint32_t));

    byte_code->function_arguments = static_cast <function_argument_t *> (calloc(descriptor_map_entries.size(), sizeof(function_argument_t)));
    byte_code->function_arguments_count = descriptor_map_entries.size();

    for (auto &&i = size_t(0); i < descriptor_map_entries.size(); ++i) {
        using namespace clspv::version0;

        auto const &descriptor_map_entry = descriptor_map_entries[i];

        switch (descriptor_map_entry.kind) {
        case DescriptorMapEntry::KernelArg: {
            auto &function_argument = byte_code->function_arguments[i];

            function_argument.entry_point = strdup(descriptor_map_entry.kernel_arg_data.kernel_name.c_str());
            function_argument.bindingIndex = descriptor_map_entry.binding;
            function_argument.index = descriptor_map_entry.kernel_arg_data.arg_ordinal;
            function_argument.offset = descriptor_map_entry.kernel_arg_data.pod_offset;
            function_argument.size = descriptor_map_entry.kernel_arg_data.pod_arg_size;

            switch (descriptor_map_entry.kernel_arg_data.arg_kind) {
            case clspv::ArgKind::Buffer:
                function_argument.type = function_argument_buffer;
                break;

            case clspv::ArgKind::BufferUBO:
                function_argument.type = function_argument_buffer_ubo;
                break;

            case clspv::ArgKind::Pod:
                function_argument.type = function_argument_pod;
                break;

            case clspv::ArgKind::PodPushConstant:
                function_argument.type = function_argument_pod_push_constant;
                break;

            case clspv::ArgKind::PodUBO:
                function_argument.type = function_argument_pod_ubo;
                break;

            default:
                assert(false);
            }

            break;
        }

        default:
            break;
        }
    }

    return true;
}

void
clspvDestroyByteCode(byte_code_t *byte_code)
{
    if (byte_code->code) {
        free(byte_code->code);
        byte_code->code = nullptr;
    }

    byte_code->length = 0;

    if (byte_code->function_arguments_count) {
        for (auto &&i = size_t(0); i < byte_code->function_arguments_count; ++i) {
            free(const_cast <char *> (byte_code->function_arguments[i].entry_point));
        }

        if (byte_code->function_arguments) {
            free(byte_code->function_arguments);
            byte_code->function_arguments = nullptr;
        }

        byte_code->function_arguments_count = 0;
    }
}

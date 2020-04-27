#include <dlfcn.h>
#include <cstring>
#include <string>
#include <clspv/Compiler.h>

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

    byte_code->code = static_cast <uint32_t *> (malloc(output_binary.size() * sizeof(uint32_t)));
    byte_code->length = output_binary.size();
    memcpy(byte_code->code, &output_binary[0], output_binary.size() * sizeof(uint32_t));

    byte_code->function_arguments = static_cast <function_argument_e *> (malloc(descriptor_map_entries.size() * sizeof(function_argument_e)));
    byte_code->function_arguments_count = descriptor_map_entries.size();

    for (auto const &descriptor_map_entry: descriptor_map_entries) {
        using namespace clspv::version0;

        auto const &binding = descriptor_map_entry.binding;

        if (binding >= descriptor_map_entries.size()) {
            continue;
        }

        switch (descriptor_map_entry.kind) {
        case DescriptorMapEntry::Constant:
            byte_code->function_arguments[binding] = function_argument_constant;
            break;

        case DescriptorMapEntry::KernelArg: {
            auto &function_argument = byte_code->function_arguments[descriptor_map_entry.kernel_arg_data.arg_ordinal];

            if (descriptor_map_entry.kernel_arg_data.arg_kind == clspv::ArgKind::PodPushConstant) {
                function_argument = function_argument_constant;
            } else {
                function_argument = function_argument_buffer;
            }

            break;
        }

        case DescriptorMapEntry::Sampler:
            byte_code->function_arguments[binding] = function_argument_sampler;
            break;

        default:
            byte_code->function_arguments[binding] = function_argument_unknown;
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

    if (byte_code->function_arguments) {
        free(byte_code->function_arguments);
        byte_code->function_arguments = nullptr;
    }

    byte_code->function_arguments_count = 0;
}

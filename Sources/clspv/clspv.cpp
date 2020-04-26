#include <dlfcn.h>
#include <cstring>
#include <string>
#include <clspv/Compiler.h>

#include "clspv.h"

#if defined(__linux__)
static auto const &compileFromSourceStringSymbolName = "_ZN5clspv23CompileFromSourceStringERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEES7_S7_PSt6vectorIjSaIjEEPS8_INS_8version018DescriptorMapEntryESaISD_EE";
#elif defined(__ANDROID__)
static auto const &compileFromSourceStringSymbolName = "_ZN5clspv23CompileFromSourceStringERKNSt6__ndk112basic_stringIcNS0_11char_traitsIcEENS0_9allocatorIcEEEES8_S8_PNS0_6vectorIjNS4_IjEEEEPNS9_INS_8version018DescriptorMapEntryENS4_ISE_EEEE";
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
    return true;
}

void
clspvDestroyByteCode(byte_code_t *byte_code)
{
    free(byte_code->code);
    byte_code->code = nullptr;
    byte_code->length = 0;
}

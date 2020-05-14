import clspv
import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class CompilerSession: MetalCompilerSession {
    private typealias BuildProgram = @convention (c) (UnsafePointer <CChar>, UnsafePointer <CChar>, UnsafeMutablePointer <byte_code_t>) -> Bool
    private typealias DestroyByteCode = @convention (c) (UnsafeMutablePointer <byte_code_t>) -> Void

    private static var cookie = 0
    private static let precompiledSources: [String: String] = [:]
    private static let clspvLibrary: UnsafeMutableRawPointer = {
        let library = "libclspv_core.so".withCString { dlopen($0, RTLD_LAZY  ) }

        precondition(library != nil)
        return library!
    }()

    private static let shaderPreamble =  """
    #pragma OPENCL EXTENSION cl_khr_fp16: enable

    #define convert_char_sat convert_char
    #define convert_char_sat_rte convert_char
    #define convert_char2_sat convert_char2
    #define convert_char2_sat_rte convert_char2
    #define convert_char3_sat convert_char3
    #define convert_char3_sat_rte convert_char3
    #define convert_char4_sat convert_char4
    #define convert_char4_sat_rte convert_char4

    #define convert_short_sat convert_short
    #define convert_short_sat_rte convert_short
    #define convert_short2_sat convert_short2
    #define convert_short2_sat_rte convert_short2
    #define convert_short3_sat convert_short3
    #define convert_short3_sat_rte convert_short3
    #define convert_short4_sat convert_short4
    #define convert_short4_sat_rte convert_short4

    #define convert_uchar_sat convert_uchar
    #define convert_uchar_sat_rte convert_uchar
    #define convert_uchar2_sat convert_uchar2
    #define convert_uchar2_sat_rte convert_uchar2
    #define convert_uchar3_sat convert_uchar3
    #define convert_uchar3_sat_rte convert_uchar3
    #define convert_uchar4_sat convert_uchar4
    #define convert_uchar4_sat_rte convert_uchar4

    #define convert_ushort_sat convert_ushort
    #define convert_ushort_sat_rte convert_ushort
    #define convert_ushort2_sat convert_ushort2
    #define convert_ushort2_sat_rte convert_ushort2
    #define convert_ushort3_sat convert_ushort3
    #define convert_ushort3_sat_rte convert_ushort3
    #define convert_ushort4_sat convert_ushort4
    #define convert_ushort4_sat_rte convert_ushort4

    #define hypot(x, y) sqrt((x * x) + (y * y))

    """

    private let spirv: [UInt32]
    private let functionArgumentTypes: [String: FunctionArgumentTypes]

    internal init?(source: String,
                   options: String) {
        let _source = CompilerSession.shaderPreamble + source
        let _options = "--pod-pushconstant -w -O=3 \(options)"
        let (spirv: spirv,
             functionArgumentTypes: functionArgumentTypes): (spirv: [UInt32],
                                                             functionArgumentTypes: [String: FunctionArgumentTypes]) = _source.withCString { _metalSource in
            var byteCode = byte_code_t()

            _options.withCString { _options in
                let compileSuccess = clspvBuildProgram(CompilerSession.clspvLibrary, _metalSource, _options, &byteCode)

                precondition(compileSuccess, "options:\n\(options)\nsource:\n\(source)\nbyteCode:\(byteCode)\n")
                precondition(byteCode.length > 0)
            }

            let spirv = Array(UnsafeBufferPointer(start: byteCode.code,
                                                  count: Int(byteCode.length)))
            let _functionArgumentTypes = Array(UnsafeBufferPointer(start: byteCode.function_arguments,
                                                                   count: Int(byteCode.function_arguments_count)))
            var functionArgumentTypes: [String: FunctionArgumentTypes] = [:]
            var podUBOOffsetsAndSizes: [String: [(bindingIndex: Int,
                                                  index: Int,
                                                  offset: Int,
                                                  size: Int)]] = [:]

            for _functionArgumentType in _functionArgumentTypes {
                guard let _entryPoint = _functionArgumentType.entry_point else {
                    continue
                }

                let entryPoint = String(cString: _entryPoint)

                if functionArgumentTypes[entryPoint] == nil {
                    functionArgumentTypes[entryPoint] = []
                }

                if _functionArgumentType.index >= functionArgumentTypes[entryPoint]!.count {
                    functionArgumentTypes[entryPoint]! += Array(repeating: .unknown,
                                                                count: _functionArgumentType.index -
                                                                       functionArgumentTypes[entryPoint]!.count +
                                                                       1)
                }

                switch _functionArgumentType.type {
                case function_argument_buffer:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .buffer

                case function_argument_buffer_ubo:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .buffer

                case function_argument_pod:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .constant

                case function_argument_pod_push_constant:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .constant

                case function_argument_pod_ubo:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .buffer

                case function_argument_sampler:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .sampler

                case function_argument_unknown:
                    functionArgumentTypes[entryPoint]![_functionArgumentType.index] = .unknown

                default:
                    preconditionFailure()
                }

                guard _functionArgumentType.type == function_argument_pod_ubo else {
                    continue
                }

                if podUBOOffsetsAndSizes[entryPoint] == nil {
                    podUBOOffsetsAndSizes[entryPoint] = []
                }

                podUBOOffsetsAndSizes[entryPoint]!.append((bindingIndex: _functionArgumentType.bindingIndex,
                                                           index: _functionArgumentType.index,
                                                           offset: _functionArgumentType.offset,
                                                           size: _functionArgumentType.size))
            }

            clspvDestroyByteCode(&byteCode)
            return (spirv: spirv,
                    functionArgumentTypes: functionArgumentTypes)
        }

        self.spirv = spirv
        self.functionArgumentTypes = functionArgumentTypes
        super.init(source: source)
    }

    public override func getMetalLibrary(device: MTLDevice,
                                         preprocessorMacros: [String : NSObject]? = nil) -> MTLLibrary? {
        return device.makeLibrary(spirv: self.spirv,
                                  functionArgumentTypes: self.functionArgumentTypes)
    }
}

internal final class Compiler: MetalCompiler {
    func makeSession(source: String,
                     options: String) -> CompilerSession? {
        return CompilerSession(source: source,
                               options: options)
    }
}

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
    #define convert_uchar_sat convert_uchar
    #define convert_uchar_sat_rte convert_uchar
    #define convert_uchar2_sat convert_uchar2
    #define convert_uchar2_sat_rte convert_uchar2
    #define convert_uchar3_sat convert_uchar3
    #define convert_uchar3_sat_rte convert_uchar3
    #define convert_uchar4_sat convert_uchar4
    #define convert_uchar4_sat_rte convert_uchar4

    """

    private let spirv: [UInt32]
    private let functionArgumentTypes: FunctionArgumentTypes

    internal init?(source: String,
                   options: String) {
        let _source = CompilerSession.shaderPreamble + source
        let _options = "--pod-pushconstant -w -O=3 \(options)"
        let (spirv: spirv,
             functionArgumentTypes: functionArgumentTypes): (spirv: [UInt32],
                                                             functionArgumentTypes: FunctionArgumentTypes) = _source.withCString { _metalSource in
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
            let functionArgumentTypes: [FunctionArgumentType] = _functionArgumentTypes.map {
                switch $0 {
                case function_argument_buffer:
                    return .buffer

                case function_argument_constant:
                    return .constant

                case function_argument_sampler:
                    return .sampler

                case function_argument_unknown:
                    return .unknown

                default:
                    preconditionFailure()
                }
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

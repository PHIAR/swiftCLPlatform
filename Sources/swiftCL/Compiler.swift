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

    """

    private let spirv: [UInt32]

    internal init?(source: String,
                   options: String) {
        let _source = CompilerSession.shaderPreamble + source
        let spirv: [UInt32] = _source.withCString { _metalSource in
            var byteCode = byte_code_t()

            options.withCString { _options in
                let compileSuccess = clspvBuildProgram(CompilerSession.clspvLibrary, _metalSource, _options, &byteCode)

                precondition(compileSuccess, "options:\n\(options)\nsource:\n\(source)\nbyteCode:\(byteCode)\n")
                precondition(byteCode.length > 0)
            }

            let spirv = Array(UnsafeBufferPointer(start: byteCode.code,
                                                  count: Int(byteCode.length)))

            clspvDestroyByteCode(&byteCode)
            return spirv
        }

        self.spirv = spirv
        super.init(source: source)
    }

    public override func getMetalLibrary(device: MTLDevice,
                                         preprocessorMacros: [String : NSObject]? = nil) -> MTLLibrary? {
        return device.makeLibrary(spirv: self.spirv)
    }
}

internal final class Compiler: MetalCompiler {
    func makeSession(source: String,
                     options: String) -> CompilerSession? {
        return CompilerSession(source: source,
                              options: options)
    }
}

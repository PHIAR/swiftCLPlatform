import swiftMetal
import COpenCL
import Foundation
import Metal

internal class Program: MetalProgram {
    public final func createKernel(name: UnsafePointer <CChar>) -> cl_kernel? {
        let kernelName = String(cString: name)

        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("\(#function)(kernelName: \(kernelName))")
        }

        var kernel: Kernel

        if let cachedKernel = self.metalContext.contextQueue.sync(execute: { self.kernelCache[kernelName] }) as? Kernel {
            kernel = cachedKernel.clone()
        } else {
            guard let _kernel = Kernel(metalProgram: self,
                                      name: name) else {
                return nil
            }

            self.metalContext.contextQueue.async { self.kernelCache[kernelName] = _kernel }
            kernel = _kernel
        }

        return kernel.toCLKernel(retained: true)
    }
}

internal final class ILProgram: Program {
    public init?(metalContext: Context,
                 data: DispatchData) {
        let library: MTLLibrary

        do {
            library = try metalContext.metalDevice.device.makeLibrary(data: data)
        } catch {
            return nil
        }

        super.init(metalContext: metalContext,
                   library: library)
    }
}

internal final class SourceProgram: Program {
    private let metalCompiler: Compiler
    private let source: String

    internal init?(metalContext: Context,
                   metalCompiler: Compiler,
                   sources: [String]) {
        let source = sources.joined()

        self.metalCompiler = metalCompiler
        self.source = source
        super.init(metalContext: metalContext)
    }

    public override func buildProgram(options: String? = nil) -> Bool {
        let metalDevice = self.metalContext.metalDevice
        let _options = options ?? ""

        guard let session = self.metalCompiler.makeSession(source: source,
                                                           options: _options),
              let library = session.getMetalLibrary(device: metalDevice.device,
                                                    preprocessorMacros: [:]) else {
            return false
        }

        self.library = library
        return true
    }
}

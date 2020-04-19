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
    private let session: CompilerSession

    internal init?(metalContext: Context,
                   metalCompiler: Compiler,
                   sources: [String]) {
        let source = sources.joined()

        guard let session: CompilerSession = metalCompiler.makeSession(source: source) else {
            return nil
        }

        self.session = session
        super.init(metalContext: metalContext)
    }

    public override func buildProgram(options: String? = nil) -> Bool {
        let metalDevice = self.metalContext.metalDevice
        var preprocessorMacros: [String: NSObject] = [:]

        if let _options = options {
            let optionElements = _options.split(separator: " ")

            for var i in 0..<optionElements.count {
                let optionElement = optionElements[i]

                if optionElement == "-D" {
                    let defineLine = optionElements[i + 1].split(separator: "=",
                                                                 maxSplits: 1)
                    let variableName = String(defineLine[0])
                    let variableValue = defineLine.count > 1 ? String(defineLine[1]) : "1"

                    preprocessorMacros[variableName] = variableValue as NSObject
                    i += 1
                }
            }
        }

        guard let library = session.getMetalLibrary(device: metalDevice.device,
                                                    preprocessorMacros: preprocessorMacros) else {
            return false
        }

        self.library = library
        return true
    }
}

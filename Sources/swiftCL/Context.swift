import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class Context: MetalContext {
    internal var device: Device {
        return self.metalDevice as! Device
    }

    public required init?(metalDevice: Device) {
        super.init(metalDevice: metalDevice)

        guard let metalCommandQueue = CommandQueue(metalContext: self) else {
            return nil
        }

        self.metalCommandQueue = metalCommandQueue
    }

    public func createCommandQueue(properties: cl_command_queue_properties) -> CommandQueue? {
        return self.commandQueue() as? CommandQueue
    }

    public func createEvent() -> MetalEvent? {
        return MetalEvent(metalCommandQueue: self.commandQueue())
    }

    public func createImage(flags: cl_mem_flags,
                            imageFormat: UnsafePointer <cl_image_format>,
                            imageDesc: Image.Descriptor,
                            hostPtr: UnsafeRawPointer?) -> Image? {
        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("createImage(flags: \(flags), imageFormat: \(imageFormat), imageDesc: \(imageDesc), host_ptr: \(String(describing: hostPtr))")
        }

        let image = Image(metalDevice: self.metalDevice,
                          flags: flags,
                          imageFormat: imageFormat.pointee,
                          imageDesc: imageDesc,
                          hostPtr: hostPtr)

        return image
    }

    public func createProgram(count: Int,
                              sources: [String]) -> Program? {
        guard let metalCompiler = Platform.defaultPlatform.metalCompiler as? Compiler,
              let program = SourceProgram(metalContext: self,
                                          metalCompiler: metalCompiler,
                                          sources: sources) else {
            return nil
        }

        return program
    }

    public func createProgramWithIL(_ data: DispatchData) -> Program? {
        guard let program = ILProgram(metalContext: self,
                                      data: data) else {
            return nil
        }

        return program
    }

    public func createSampler(normalizedCoords: Bool,
                              addressingMode: cl_addressing_mode,
                              filterMode: cl_filter_mode) -> Sampler? {
        let sampler = Sampler(metalDevice: self.device,
                              normalizedCoords: normalizedCoords,
                              addressingMode: addressingMode,
                              filterMode: filterMode)

        return sampler
    }
}

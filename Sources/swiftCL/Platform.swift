import swiftMetal
import COpenCL
import Foundation
import Metal

internal let SWIFTCL_ENABLE_CONSOLE_LOG = false
internal let SWIFTCL_ENABLE_INSTRUMENTATION = false

#if (os(iOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
private let MTLCopyAllDevices = { return [ MTLCreateSystemDefaultDevice()! ] }
#endif

internal final class Platform: MetalPlatform {
    private static let defaultPlatform = Platform()

    internal static let allPlatforms = [
        Platform.defaultPlatform,
    ]

    internal required init() {
        super.init(metalDevices: MTLCopyAllDevices().map { Device(device: $0) },
                   metalCompiler: Compiler())
    }
}

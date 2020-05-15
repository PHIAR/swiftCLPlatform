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
    private static let profile = "EMBEDDED_PROFILE"
    private static let vendor = "swiftCL"

    internal static let extensions = "cl_khr_byte_addressable_store " +
                                     "cl_khr_create_command_queue" +
                                     "cl_khr_fp16 " +
                                     "cl_khr_il_program"
    internal static let version = "OpenCL 2.0"

    internal static let allPlatforms = [
        Platform.defaultPlatform,
    ]

    internal lazy var paramValues: [cl_platform_info: Any] = [
        cl_platform_info(CL_PLATFORM_EXTENSIONS): Platform.extensions,
        cl_platform_info(CL_PLATFORM_NAME): Platform.vendor,
        cl_platform_info(CL_PLATFORM_PROFILE): Platform.profile,
        cl_platform_info(CL_PLATFORM_VENDOR): Platform.vendor,
        cl_platform_info(CL_PLATFORM_VERSION): Platform.version,
    ]

    internal required init() {
        super.init(metalDevices: MTLCopyAllDevices().map { Device(device: $0) },
                   metalCompiler: Compiler())
        self.getDevices().forEach { ($0 as! Device).set(platform: self) }
    }

    internal func getPlatformInfo(paramName: cl_platform_info,
                                  paramValueSize: Int,
                                  paramValue: UnsafeMutableRawPointer?,
                                  paramValueSizeRet: UnsafeMutablePointer <size_t>?) -> Bool {
        switch Int32(paramName) {
        case CL_PLATFORM_EXTENSIONS,
             CL_PLATFORM_NAME,
             CL_PLATFORM_PROFILE,
             CL_PLATFORM_VENDOR,
             CL_PLATFORM_VERSION:
            let stringValue = self.paramValues[paramName] as! String

            paramValueSizeRet?.pointee = stringValue.count

            if let pointer = paramValue?.assumingMemoryBound(to: CChar.self) {
                let _ = stringValue.withCString { memcpy(pointer, $0, stringValue.count) }
            }

        default:
            print(String(format: "\(#function)(paramName: 0x%04x, paramValueSize: \(paramValueSize), paramValue: \(String(describing: paramValue)), paramValueSizeRet: \(String(describing: paramValueSizeRet)))", paramName))
        }

        return true
    }
}

import swiftMetal
@_exported import COpenCL

internal extension cl_platform_id {
    func toMetalPlatform(retained: Bool = false) -> Platform {
        guard retained else {
            return Unmanaged <Platform>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Platform>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Platform {
    func toCLPlatform(retained: Bool = false) -> cl_platform_id {
        guard retained else {
            return cl_platform_id(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_platform_id(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clGetDeviceIDs") @discardableResult
public func clGetDeviceIDs(_ platform: cl_platform_id?,
                           _ device_type: cl_device_type,
                           _ num_entries: cl_uint,
                           _ devices: UnsafeMutablePointer <cl_device_id?>?,
                           _ num_devices: UnsafeMutablePointer <cl_uint>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(platform: \(String(describing: platform)), device_type: \(device_type), num_entries: \(num_entries), devices: \(String(describing: devices)), num_devices: \(String(describing: num_devices)))")
    }

    let _platform = platform ?? Platform.allPlatforms[0].toCLPlatform()
    let platform = _platform.toMetalPlatform()
    let platformDevices = platform.getDevices()

    if num_entries == 0 {
        if let _num_devices = num_devices {
            _num_devices.pointee = cl_uint(platformDevices.count)
            return CL_SUCCESS
        }

        return CL_INVALID_VALUE
    }

    guard let _devices = devices else {
        return CL_INVALID_VALUE
    }

    for i in 0..<((num_devices != nil) ? min(Int(num_devices!.pointee), platformDevices.count) : platformDevices.count) {
        let device = platformDevices[i] as! Device

        _devices[i] = device.toCLDevice()
    }

    if let _num_devices = num_devices {
        _num_devices.pointee = cl_uint(platformDevices.count)
    }

    return CL_SUCCESS
}

@_cdecl("clGetExtensionFunctionAddress")
public func clGetExtensionFunctionAddress(_ func_name: UnsafePointer <CChar>) -> UnsafeMutableRawPointer? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(func_name: \(func_name))")
    }

    return nil
}

@_cdecl("clGetExtensionFunctionAddressForPlatform")
public func clGetExtensionFunctionAddressForPlatform(_ platform: cl_platform_id,
                                                     _ func_name: UnsafePointer <CChar>) -> UnsafeMutableRawPointer? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)")
    }

    return nil
}

@_cdecl("clGetPlatformIDs") @discardableResult
public func clGetPlatformIDs(_ num_entries: cl_uint,
                             _ platforms: UnsafeMutablePointer <cl_platform_id>?,
                             _ num_platforms: UnsafeMutablePointer <cl_uint>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(num_entries: \(num_entries), platforms: \(String(describing: platforms))), num_platforms: \(String(describing: num_platforms)))")
    }

    if num_entries == 0 {
        if let _num_platforms = num_platforms {
            _num_platforms.pointee = cl_uint(Platform.allPlatforms.count)
            return CL_SUCCESS
        }

        return CL_INVALID_VALUE
    }

    guard let _platforms = platforms else {
        return CL_INVALID_VALUE
    }

    for i in 0..<((num_platforms != nil) ? min(Int(num_platforms!.pointee), Platform.allPlatforms.count) : Platform.allPlatforms.count) {
        _platforms[i] = Platform.allPlatforms[i].toCLPlatform()
    }

    if let _num_platforms = num_platforms {
        _num_platforms.pointee = cl_uint(Platform.allPlatforms.count)
    }

    return CL_SUCCESS
}

@_cdecl("clGetPlatformInfo") @discardableResult
public func clGetPlatformInfo(_ platform: cl_platform_id,
                              _ param_name: cl_platform_info,
                              _ param_value_size: size_t,
                              _ param_value: UnsafeMutableRawPointer?,
                              _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(platform: \(platform), param_name: \(param_name), param_value_size: \(param_value_size), param_value: \(String(describing: param_value)), param_value_size_ret: \(String(describing: param_value_size_ret))")
    }

    param_value_size_ret?.pointee = 0
    return CL_SUCCESS
}

@_cdecl("clUnloadCompiler") @discardableResult
public func clUnloadCompiler() -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)")
    }

    return CL_SUCCESS
}

@_cdecl("clUnloadPlatformCompiler") @discardableResult
public func clUnloadPlatformCompiler(_ platform: cl_platform_id) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(platform: \(platform))")
    }

    let platform = platform.toMetalPlatform()

    platform.unloadCompiler()
    return CL_SUCCESS
}

import swiftMetal
import COpenCL

internal extension cl_device_id {
    func toDevice(retained: Bool = false) -> Device {
        guard retained else {
            return Unmanaged <Device>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Device>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Device {
    func toCLDevice(retained: Bool = false) -> cl_device_id {
        guard retained else {
            return cl_device_id(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_device_id(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clCreateSubDevices") @discardableResult
public func clCreateSubDevices(_ in_device: cl_device_id,
                               _ properties: UnsafePointer <cl_device_partition_property>,
                               _ num_devices: cl_uint,
                               _ out_devices: UnsafeMutablePointer <cl_device_id>,
                               _ num_devices_ret: UnsafeMutablePointer <cl_uint>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(device: \(in_device))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetDeviceAndHostTimer") @discardableResult
public func clGetDeviceAndHostTimer(_ device: cl_device_id,
                                    _ device_timestamp: UnsafeMutablePointer <cl_ulong>?,
                                    _ host_timestamp: UnsafeMutablePointer <cl_ulong>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(device: \(device), device_timestamp: \(String(describing: device_timestamp)), host_timestamp: \(String(describing: host_timestamp)))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetDeviceInfo")
public func clGetDeviceInfo(_ device: cl_device_id,
                            _ param_name: cl_device_info,
                            _ param_value_size: size_t,
                            _ param_value: UnsafeMutableRawPointer,
                            _ param_value_size_ret: UnsafeMutablePointer <size_t>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print(String(format: "\(#function)(device: \(device), param_name: 0x%04x, param_value_size: \(param_value_size), param_value: \(String(describing: param_value)), param_value_size_ret: \(String(describing: param_value_size_ret)))", param_name))
    }

    let _device = device.toDevice()

    guard _device.getDeviceInfo(paramName: param_name,
                                paramValueSize: param_value_size,
                                paramValue: param_value,
                                paramValueSizeRet: param_value_size_ret) else {
        return CL_INVALID_VALUE
    }

    return CL_SUCCESS
}

@_cdecl("clGetHostTimer") @discardableResult
public func clGetHostTimer(_ device: cl_device_id,
                           _ host_timestamp: UnsafeMutablePointer <cl_ulong>?) -> cl_int
{
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(device: \(device), host_timestamp: \(String(describing: host_timestamp)))")
    }

    return CL_SUCCESS
}

@_cdecl("clReleaseDevice") @discardableResult
public func clReleaseDevice(_ device: cl_device_id) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(device: \(device))")
    }

    let _ = device.toDevice(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainDevice") @discardableResult
public func clRetainDevice(_ device: cl_device_id) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(device: \(device))")
    }

    let _device = device.toDevice()
    let _ = _device.toCLDevice(retained: true)

    return CL_SUCCESS
}


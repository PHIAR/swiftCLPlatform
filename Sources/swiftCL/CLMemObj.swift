import swiftMetal
import COpenCL

internal extension cl_mem {
    func toBuffer(retained: Bool = false) -> Buffer {
        guard retained else {
            return Unmanaged <Buffer>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Buffer>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }

    func toImage(retained: Bool = false) -> Image {
        guard retained else {
            return Unmanaged <Image>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Image>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Buffer {
    func toCLMem(retained: Bool = false) -> cl_mem {
        guard retained else {
            return cl_mem(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_mem(Unmanaged.passRetained(self).toOpaque())
    }
}

internal extension Image {
    func toCLMem(retained: Bool = false) -> cl_mem {
        guard retained else {
            return cl_mem(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_mem(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clCreateSubBuffer")
public func clCreateSubBuffer(_ buffer: cl_mem ,
                              _ flags: cl_mem_flags,
                              _ buffer_create_type: cl_buffer_create_type,
                              _ buffer_create_info: UnsafeRawPointer,
                              _ errcode_ret: UnsafeMutablePointer <cl_int>) -> cl_mem? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(buffer: \(buffer))")
    }

    return nil
}

@_cdecl("clGetImageInfo") @discardableResult
public func clGetImageInfo(_ image: cl_mem,
                           _ param_name: cl_image_info,
                           _ param_value_size: size_t,
                           _ param_value: UnsafeMutableRawPointer?,
                           _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(image: \(image))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetMemObjectInfo") @discardableResult
public func clGetMemObjectInfo(_ memobj: cl_mem,
                               _ param_name: cl_mem_info,
                               _ param_value_size: size_t,
                               _ param_value: UnsafeMutableRawPointer?,
                               _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(memobj: \(memobj))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetPipeInfo") @discardableResult
public func clGetPipeInfo(_ pipe: cl_mem,
                          _ param_name: cl_pipe_info,
                          _ param_value_size: size_t,
                          _ param_value: UnsafeMutableRawPointer?,
                          _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(pipe: \(pipe))")
    }

    return CL_SUCCESS
}

@_cdecl("clReleaseMemObject") @discardableResult
public func clReleaseMemObject(_ memobj: cl_mem) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(memobj: \(memobj))")
    }

    let _ = memobj.toMetalMemObj(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainMemObject") @discardableResult
public func clRetainMemObject(_ memobj: cl_mem) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(memobj: \(memobj))")
    }

    let _memObj = memobj.toMetalMemObj()
    let _ = _memObj.toOpaquePointer(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetMemObjectDestructorCallback") @discardableResult
public func clSetMemObjectDestructorCallback(_ memobj: cl_mem,
                                             _ pfn_notify: (@convention (c) (cl_mem?,
                                                                             UnsafeMutableRawPointer?) -> Void)!,
                                             _ user_data: UnsafeMutableRawPointer?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(memobj: \(memobj), pfn_notify: \(String(describing: pfn_notify)), user_data: \(String(describing: user_data)))")
    }

    let _memObj = memobj.toMetalMemObj()

    _memObj.setDestructorCallback {
        pfn_notify(memobj, user_data)
    }

    return CL_SUCCESS
}

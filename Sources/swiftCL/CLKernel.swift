import swiftMetal
import COpenCL

internal extension cl_kernel {
    func toMetalKernel(retained: Bool = false) -> Kernel {
        guard retained else {
            return Unmanaged <Kernel>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Kernel>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Kernel {
    func toCLKernel(retained: Bool = false) -> cl_kernel {
        guard retained else {
            return cl_kernel(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_kernel(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clCloneKernel")
public func clCloneKernel(_ source_kernel: cl_kernel,
                          _ errcode_ret: UnsafeMutablePointer <cl_int>) -> cl_kernel? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(source_kernel: \(source_kernel))")
    }

    let kernel = source_kernel.toMetalKernel()
    let clonedKernel = kernel.clone()

    return clonedKernel.toCLKernel(retained: true)
}

@_cdecl("clGetKernelArgInfo") @discardableResult
public func clGetKernelArgInfo(_ kernel: cl_kernel,
                               _ arg_indx: cl_uint,
                               _ param_name: cl_kernel_arg_info,
                               _ param_value_size: size_t,
                               _ param_value: UnsafeMutableRawPointer,
                               _ param_value_size_ret: UnsafeMutablePointer <size_t>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }
    return CL_SUCCESS
}

@_cdecl("clGetKernelInfo") @discardableResult
public func clGetKernelInfo(_ kernel: cl_kernel,
                            _ param_name: cl_kernel_info,
                            _ param_value_size: size_t,
                            _ param_value: UnsafeMutableRawPointer,
                            _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetKernelSubGroupInfo") @discardableResult
public func clGetKernelSubGroupInfo(_ kernel: cl_kernel,
                                    _ device: cl_device_id,
                                    _ param_name: cl_kernel_sub_group_info,
                                    _ input_value_size: size_t,
                                    _ input_value: UnsafeRawPointer,
                                    _ param_value_size: size_t,
                                    _ param_value: UnsafeMutableRawPointer,
                                    _ param_value_size_ret: UnsafeMutablePointer <size_t>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetKernelWorkGroupInfo") @discardableResult
public func clGetKernelWorkGroupInfo(_ kernel: cl_kernel,
                                     _ device: cl_device_id?,
                                     _ param_name: cl_kernel_work_group_info,
                                     _ param_value_size: size_t,
                                     _ param_value: UnsafeMutableRawPointer,
                                     _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel), device: \(String(describing: device)), param_name: \(param_name), param_value_size: \(param_value_size), param_value: \(param_value), param_value_size_ret: \(String(describing: param_value_size_ret)))")
    }

    let _kernel = kernel.toMetalKernel()

    guard _kernel.getKernelWorkGroupInfo(paramName: param_name,
                                         paramValueSize: param_value_size,
                                         paramValue: param_value,
                                         paramValueSizeRet: param_value_size_ret) else {
        return CL_INVALID_VALUE
    }

    return CL_SUCCESS
}

@_cdecl("clReleaseKernel") @discardableResult
public func clReleaseKernel(_ kernel: cl_kernel) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }

    let _ = kernel.toMetalKernel(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainKernel") @discardableResult
public func clRetainKernel(_ kernel: cl_kernel) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }

    let metalKernel = kernel.toMetalKernel()
    let _ = metalKernel.toCLKernel(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetKernelArg") @discardableResult
public func clSetKernelArg(_ kernel: cl_kernel,
                           _ arg_index: cl_uint,
                           _ arg_size: size_t,
                           _ arg_value: UnsafeRawPointer) -> cl_int {
    let metalKernel = kernel.toMetalKernel()

    metalKernel.setKernelArg(index: Int(arg_index),
                             size: arg_size,
                             value: arg_value)
    return CL_SUCCESS
}

@_cdecl("clSetKernelArgSVMPointer") @discardableResult
public func clSetKernelArgSVMPointer(_ kernel: cl_kernel,
                                     _ arg_index: cl_uint,
                                     _ arg_value: UnsafeRawPointer) -> cl_int {
    let metalKernel = kernel.toMetalKernel()

    metalKernel.setKernelArgSVMPointer(index: Int(arg_index),
                                       value: arg_value)
    return CL_SUCCESS
}

@_cdecl("clSetKernelExecInfo") @discardableResult
public func clSetKernelExecInfo(_ kernel: cl_kernel,
                                _ param_name: cl_kernel_exec_info,
                                _ param_value_size: size_t,
                                _ param_value: UnsafeRawPointer) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(kernel: \(kernel))")
    }

    let _ = kernel.toMetalKernel()

    return CL_SUCCESS
}

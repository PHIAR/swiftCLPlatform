import swiftMetal
import COpenCL

internal extension cl_program {
    func toMetalProgram(retained: Bool = false) -> Program {
        guard retained else {
            return Unmanaged <Program>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Program>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Program {
    func toCLProgram(retained: Bool = false) -> cl_program {
        guard retained else {
            return cl_program(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_program(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clCreateKernel")
public func clCreateKernel(_ program: cl_program,
                           _ kernel_name: UnsafePointer <CChar>,
                           _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_kernel? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    let _program = program.toMetalProgram()
    let kernel = _program.createKernel(name: kernel_name)

    errcode_ret?.pointee = CL_SUCCESS
    return kernel
}

@_cdecl("clBuildProgram") @discardableResult
public func clBuildProgram(_ program: cl_program,
                           _ num_devices: cl_uint,
                           _ device_list: UnsafePointer <cl_device_id>?,
                           _ options: UnsafePointer <CChar>?,
                           _ pfn_notify: (@convention (c) (cl_program, UnsafeMutableRawPointer?) -> Void)?,
                           _ user_data: UnsafeMutableRawPointer?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program), device_list: \(String(describing: device_list)), num_devices: \(num_devices), options: \(String(describing: options)), pfn_notify: \(String(describing: pfn_notify)), user_data: \(String(describing: user_data)))")
    }

    let _program = program.toMetalProgram()
    let result: Bool

    if let _options = options {
        result = _program.buildProgram(options: String(cString: _options))
    } else {
        result = _program.buildProgram(options: nil)
    }

    return result ? CL_SUCCESS : CL_BUILD_PROGRAM_FAILURE
}

@_cdecl("clCreateKernelsInProgram") @discardableResult
public func clCreateKernelsInProgram(program: cl_program,
                                     num_kernels: cl_uint,
                                     kernels: UnsafeMutablePointer <cl_kernel>,
                                     num_kernels_ret: UnsafeMutablePointer <cl_uint>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    return CL_SUCCESS
}

@_cdecl("clCompileProgram") @discardableResult
public func clCompileProgram(program: cl_program,
                             num_devices: cl_uint,
                             device_list: UnsafePointer <cl_device_id>,
                             options: UnsafePointer <CChar>,
                             num_input_headers: cl_uint,
                             input_headers: UnsafePointer <cl_program>,
                             header_include_names: UnsafeMutablePointer <UnsafePointer <CChar>>,
                             pfn_notify: (@convention (c) (cl_program, UnsafeMutableRawPointer?) -> Void)?,
                             user_data: UnsafeMutableRawPointer) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetProgramBuildInfo")
public func clGetProgramBuildInfo(program: cl_program,
                                  device: cl_device_id,
                                  param_name: cl_program_build_info,
                                  param_value_size: size_t,
                                  param_value: UnsafeMutableRawPointer?,
                                  param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program) param_name: \(param_name) param_value_size: \(param_value_size) param_value: \(String(describing: param_value)) param_value_size_ret: \(String(describing: param_value_size_ret)))")
    }

    let _program = program.toMetalProgram()

    switch param_name {
    case cl_program_build_info(CL_PROGRAM_BUILD_LOG):
        param_value_size_ret?.pointee = 0

    case cl_program_info(CL_PROGRAM_BUILD_STATUS):
        param_value?.assumingMemoryBound(to: cl_build_status.self).pointee = cl_build_status(CL_BUILD_SUCCESS)
        param_value_size_ret?.pointee = MemoryLayout <cl_build_status>.size

    default:
        preconditionFailure(String(format: "Unknown parameter: 0x%04x", param_name))
    }

    return CL_SUCCESS
}

@_cdecl("clGetProgramInfo") @discardableResult
public func clGetProgramInfo(program: cl_program,
                             param_name: cl_program_info,
                             param_value_size: size_t,
                             param_value: UnsafeMutableRawPointer?,
                             param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program) param_name: \(param_name) param_value_size: \(param_value_size) param_value: \(String(describing: param_value)) param_value_size_ret: \(String(describing: param_value_size_ret)))")
    }

    let _program = program.toMetalProgram()

    switch param_name {
    case cl_program_info(CL_PROGRAM_BINARIES):
        precondition(param_value_size > 0)

        let data = _program.getData()

        if let _param_value = param_value,
           let _data = data {
            let _ = _data.withUnsafeBytes {
                memcpy(_param_value.assumingMemoryBound(to: UnsafeMutablePointer <UnsafeMutableRawPointer>.self).pointee,
                       $0.baseAddress!,
                       _data.count)
            }
        }

        param_value_size_ret?.pointee = param_value_size

    case cl_program_info(CL_PROGRAM_BINARY_SIZES):
        let size = _program.getData()?.count ?? 1

        param_value_size_ret?.pointee = MemoryLayout <UInt32>.size

        switch param_value_size {
        case MemoryLayout <UInt32>.size:
            param_value?.assumingMemoryBound(to: UInt32.self).pointee = UInt32(size)

        case MemoryLayout <UInt64>.size:
            param_value?.assumingMemoryBound(to: UInt64.self).pointee = UInt64(size)

        default:
            preconditionFailure("Unknown parameter value size: \(param_value_size).")
        }

    default:
        preconditionFailure(String(format: "Unknown parameter: 0x%04x", param_name))
    }

    return CL_SUCCESS
}

@_cdecl("clReleaseProgram") @discardableResult
public func clReleaseProgram(_ program: cl_program) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    let _ = program.toMetalProgram(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainProgram") @discardableResult
public func clRetainProgram(_ program: cl_program) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    let program = program.toMetalProgram()
    let _ = program.toCLProgram(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetProgramReleaseCallback") @discardableResult
public func clSetProgramReleaseCallback(program: cl_program,
                                        pfn_notify: (@convention (c) (cl_program, UnsafeMutableRawPointer?) -> Void)?,
                                        user_data: UnsafeMutableRawPointer?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program))")
    }

    let _program = program.toMetalProgram()

    _program.setReleaseCallback {
        if let _pfn_notify = pfn_notify {
            _pfn_notify(program, user_data)
        }
    }

    return CL_SUCCESS
}

@_cdecl("clSetProgramSpecializationConstant") @discardableResult
public func clSetProgramSpecializationConstant(program: cl_program,
                                               spec_id: cl_uint,
                                               spec_size: size_t,
                                               spec_value: UnsafeRawPointer) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(program: \(program), spec_id: \(spec_id), spec_size: \(spec_size), spec_value: \(spec_value))")
    }

    return CL_SUCCESS
}

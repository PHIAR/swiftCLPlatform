import swiftMetal
import COpenCL
import Foundation
import Metal

internal extension cl_context {
    func toContext(retained: Bool = false) -> Context {
        guard retained else {
            return Unmanaged <Context>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Context>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Context {
    func toCLContext(retained: Bool = false) -> cl_context {
        guard retained else {
            return cl_context(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_context(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clCreateBuffer")
public func clCreateBuffer(_ context: cl_context,
                           _ flags: cl_mem_flags,
                           _ size: size_t,
                           _ host_ptr: UnsafeMutableRawPointer?,
                           _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_mem? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), flags: \(flags), size: \(size), host_ptr: \(String(describing: host_ptr)))")
    }

    let _context = context.toContext()

    guard let buffer = _context.metalDevice.makeBuffer(size: size,
                                                       hostPtr: host_ptr) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context): return \(String(describing: buffer)))")
    }

    errcode_ret?.pointee = CL_SUCCESS
    return buffer.toOpaquePointer(retained: true)
}

@_cdecl("clCreateCommandQueue")
public func clCreateCommandQueue(_ context: cl_context,
                                 _ device: cl_device_id?,
                                 _ properties: cl_command_queue_properties,
                                 _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_command_queue? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), device: \(String(describing: device)), properties: \(properties))")
    }

    let _context = context.toContext()

    guard let commandQueue = _context.createCommandQueue(properties: properties) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return commandQueue.toCLCommandQueue(retained: true)
}

@_cdecl("clCreateCommandQueueWithProperties")
public func clCreateCommandQueueWithProperties(_ context: cl_context,
                                               _ device: cl_device_id,
                                               _ properties: UnsafePointer <cl_queue_properties>,
                                               _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_command_queue? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), device: \(device), properties: \(properties))")
    }

    let _context = context.toContext()

    guard let commandQueue = _context.createCommandQueue(properties: cl_command_queue_properties()) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return commandQueue.toCLCommandQueue(retained: true)
}

@_cdecl("clCreateContext")
public func clCreateContext(_ properties: UnsafePointer <cl_context_properties>?,
                            _ num_devices: cl_uint,
                            _ devices: UnsafePointer <cl_device_id?>?,
                            _ pfn_notify: (@convention (c) (UnsafePointer <CChar>?,
                                                            UnsafeRawPointer?,
                                                            size_t,
                                                            UnsafeMutableRawPointer?) -> Void)?,
                            _ user_data: UnsafeMutableRawPointer?,
                            _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_context? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(properties: \(String(describing: properties)), num_devices: \(num_devices), devices: \(String(describing: devices)), pfn_notify: \(String(describing: pfn_notify)), user_data: \(String(describing: user_data)))")
    }

    guard let _devices = devices,
          num_devices > 0 else {
        errcode_ret?.pointee = CL_INVALID_VALUE
        return nil
    }

    let device = _devices[0]!.toDevice()

    guard let _context = device.createContext() else {
        errcode_ret?.pointee = CL_INVALID_VALUE
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return _context.toOpaquePointer(retained: true)
}

@_cdecl("clCreateContextFromType")
public func clCreateContextFromType(_ properties: UnsafePointer <cl_context_properties>,
                                    _ device_type: cl_device_type,
                                    _ pfn_notify: (@convention(c) (UnsafePointer <CChar>?,
                                                                   UnsafeRawPointer?,
                                                                   size_t,
                                                                   UnsafeMutableRawPointer) -> Void)?,
                                    _ user_data: UnsafeMutableRawPointer,
                                    _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_context? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(properties: \(properties), device_type: \(device_type), pfn_notify: \(String(describing: pfn_notify)), user_data: \(user_data))")
    }

    return nil
}

@_cdecl("clCreateImage")
public func clCreateImage(_ context: cl_context,
                          _ flags: cl_mem_flags,
                          _ image_format: UnsafePointer <cl_image_format>,
                          _ image_desc: UnsafePointer <cl_image_desc>,
                          _ host_ptr: UnsafeMutableRawPointer?,
                          _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_mem? {
    let _context = context.toContext()
    let image_desc = Image.Descriptor(image_type: image_desc.pointee.image_type,
                                      image_width: image_desc.pointee.image_width,
                                      image_height: image_desc.pointee.image_height,
                                      image_depth: image_desc.pointee.image_depth,
                                      image_array_size: image_desc.pointee.image_array_size,
                                      image_row_pitch: image_desc.pointee.image_row_pitch,
                                      image_slice_pitch: image_desc.pointee.image_slice_pitch,
                                      num_mip_levels: Int(image_desc.pointee.num_mip_levels),
                                      num_samples: Int(image_desc.pointee.num_samples))

    guard let image = _context.createImage(flags: flags,
                                           imageFormat: image_format,
                                           imageDesc: image_desc,
                                           hostPtr: host_ptr) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return image.toOpaquePointer(retained: true)
}

@_cdecl("clCreateImage2D")
public func clCreateImage2D(_ context: cl_context,
                            _ flags: cl_mem_flags,
                            _ image_format: UnsafePointer <cl_image_format>,
                            _ image_width: size_t,
                            _ image_height: size_t,
                            _ image_row_pitch: size_t,
                            _ host_ptr: UnsafeMutableRawPointer?,
                            _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_mem? {
    let _context = context.toContext()
    let image_desc = Image.Descriptor(image_type: cl_mem_object_type(CL_MEM_OBJECT_IMAGE2D),
                                      image_width: image_width,
                                      image_height: image_height,
                                      image_depth: 1,
                                      image_array_size: 1,
                                      image_row_pitch: image_row_pitch,
                                      image_slice_pitch: image_row_pitch * image_height,
                                      num_mip_levels: 1,
                                      num_samples: 1)


    guard let image = _context.createImage(flags: flags,
                                           imageFormat: image_format,
                                           imageDesc: image_desc,
                                           hostPtr: host_ptr) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return image.toOpaquePointer(retained: true)
}

@_cdecl("clCreateImage3D")
public func clCreateImage3D(_ context: cl_context,
                            _ flags: cl_mem_flags,
                            _ image_format: UnsafePointer <cl_image_format>,
                            _ image_width: size_t,
                            _ image_height: size_t,
                            _ image_depth: size_t,
                            _ image_row_pitch: size_t,
                            _ image_slice_pitch: size_t,
                            _ host_ptr: UnsafeMutableRawPointer?,
                            _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_mem? {
    let _context = context.toContext()
    let image_desc = Image.Descriptor(image_type: cl_mem_object_type(CL_MEM_OBJECT_IMAGE3D),
                                      image_width: image_width,
                                      image_height: image_height,
                                      image_depth: image_depth,
                                      image_array_size: 1,
                                      image_row_pitch: image_row_pitch,
                                      image_slice_pitch: image_slice_pitch,
                                      num_mip_levels: 1,
                                      num_samples: 1)


    guard let image = _context.createImage(flags: flags,
                                           imageFormat: image_format,
                                           imageDesc: image_desc,
                                           hostPtr: host_ptr) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return image.toOpaquePointer(retained: true)
}

@_cdecl("clCreatePipe")
public func clCreatePipe(_ context: cl_context,
                         _ flags: cl_mem_flags,
                         _ pipe_packet_size: cl_uint,
                         _ pipe_max_packets: cl_uint,
                         _ properties: UnsafePointer <cl_pipe_properties>,
                         _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_mem? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), flags: \(flags), pipe_packet_size: \(pipe_packet_size), pipe_max_packets: \(pipe_max_packets), properties: \(properties))")
    }

    return nil
}

@_cdecl("clCreateProgramWithSource")
public func clCreateProgramWithSource(_ context: cl_context,
                                      _ count: cl_uint,
                                      _ strings: UnsafeMutablePointer <UnsafePointer <CChar>?>,
                                      _ lengths: UnsafePointer <size_t>?,
                                      _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_program? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), count: \(count), strings: \(strings), lengths: \(String(describing: lengths)))")
    }

    var sources: [String] = []

    for i in 0..<Int(count) {
        let source = String(cString: strings[i]!)

        sources.append(source)
    }

    let _context = context.toContext()

    guard let program = _context.createProgram(count: Int(count),
                                               sources: sources) else {
        errcode_ret?.pointee = CL_OUT_OF_RESOURCES
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return program.toCLProgram(retained: true)
}

@_cdecl("clCreateProgramWithBinary")
public func clCreateProgramWithBinary(_ context: cl_context,
                                      _ num_devices: cl_uint,
                                      _ device_list: UnsafePointer <cl_device_id>,
                                      _ lengths: UnsafePointer <size_t>,
                                      _ binaries: UnsafeMutablePointer <UnsafePointer <UInt8>>,
                                      _ binary_status: UnsafeMutablePointer <cl_int>?,
                                      _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_program? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), num_devices: \(num_devices), device_list: \(device_list), lengths: \(lengths), binaries: \(binaries), binary_status: \(String(describing: binary_status)))")
    }

    return nil
}

@_cdecl("clCreateProgramWithBuiltInKernels")
public func clCreateProgramWithBuiltInKernels(_ context: cl_context,
                                              _ num_devices: cl_uint,
                                              _ device_list: UnsafePointer <cl_device_id>,
                                              _ kernel_names: UnsafePointer <CChar>,
                                              _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_program? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), num_devices: \(num_devices), device_list: \(device_list), kernel_names: \(kernel_names))")
    }

    return nil
}

@_cdecl("clCreateProgramWithIL")
public func clCreateProgramWithIL(_ context: cl_context,
                                  _ il: UnsafeRawPointer,
                                  _ length: size_t,
                                  _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_program? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), il: \(il), length: \(length)")
    }

    let _context = context.toContext()

    guard let program = _context.createProgramWithIL(DispatchData(bytes: UnsafeRawBufferPointer(start: il,
                                                                                                count: length))) else {
        errcode_ret?.pointee = CL_INVALID_VALUE
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return program.toCLProgram(retained: true)
}

@_cdecl("clCreateSampler")
public func clCreateSampler(_ context: cl_context,
                            _ normalized_coords: cl_bool,
                            _ addressing_mode: cl_addressing_mode,
                            _ filter_mode: cl_filter_mode,
                            _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_sampler? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), normalized_coords: \(normalized_coords), addressing_mode: \(addressing_mode), filter_mode: \(filter_mode))")
    }

    let _context = context.toContext()

    guard let sampler = _context.createSampler(normalizedCoords: normalized_coords == CL_TRUE,
                                               addressingMode: addressing_mode,
                                               filterMode: filter_mode) else {
        errcode_ret?.pointee = CL_INVALID_VALUE
        return nil
    }

    errcode_ret?.pointee = CL_SUCCESS
    return sampler.toCLSampler(retained: true)
}

@_cdecl("clCreateSamplerWithProperties")
public func clCreateSamplerWithProperties(_ context: cl_context,
                                          _ normalized_coords: UnsafePointer <cl_sampler_properties>,
                                          _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_sampler? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), normalized_coords: \(normalized_coords))")
    }

    return nil
}

@_cdecl("clCreateUserEvent")
public func clCreateUserEvent(_ context: cl_context,
                              _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_event? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context))")
    }

    let _context = context.toContext()
    let event = _context.createEvent()

    if let _errcode_ret = errcode_ret {
        _errcode_ret.pointee = event != nil ? CL_SUCCESS : CL_OUT_OF_RESOURCES
    }

    return event?.toOpaquePointer(retained: true)
}

@_cdecl("clGetContextInfo")
public func clGetContextInfo(_ context: cl_context,
                             _ param_name: cl_context_info,
                             _ param_value_size: size_t,
                             _ param_value: UnsafeMutableRawPointer,
                             _ param_value_size_ret: UnsafeMutablePointer <size_t>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context))")
    }

    return CL_SUCCESS
}

@_cdecl("clGetSupportedImageFormats")
public func clGetSupportedImageFormats(_ context: cl_context,
                                       _ flags: cl_mem_flags,
                                       _ image_type: cl_mem_object_type,
                                       _ num_entries: cl_uint,
                                       _ image_formats: UnsafeMutablePointer <cl_image_format>,
                                       _ num_image_formats: UnsafeMutablePointer <cl_uint>) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context))")
    }

    return CL_SUCCESS
}

@_cdecl("clLinkProgram")
public func clLinkProgram(_ context: cl_context,
                          _ num_devices: cl_uint,
                          _ device_list: UnsafePointer <cl_device_id>?,
                          _ options: UnsafePointer <CChar>,
                          _ num_input_programs: cl_uint,
                          _ input_programs: UnsafePointer <cl_program>,
                          _ pfn_notify: (@convention(c) (cl_program,
                                                         UnsafeMutableRawPointer) -> Void)?,
                          _ user_data: UnsafeMutableRawPointer?,
                          _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> cl_program? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context))")
    }

    var programs: [Program] = []

    for index in 0..<Int(num_input_programs) {
        let _program = input_programs[index]
        let program = _program.toMetalProgram()

        programs.append(program)
    }

    return nil
}

@_cdecl("clReleaseContext") @discardableResult
public func clReleaseContext(_ context: cl_context) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context))")
    }

    let _ = context.toContext(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainContext") @discardableResult
public func clRetainContext(_ context: cl_context) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(memobj: \(context))")
    }

    let _context = context.toContext()
    let _ = _context.toOpaquePointer(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetDefaultDeviceCommandQueue") @discardableResult
public func clSetDefaultDeviceCommandQueue(_ context: cl_context,
                                           _ device: cl_device_id,
                                           _ command_queue: cl_command_queue) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(context: \(context), device: \(device), command_queue: \(command_queue))")
    }

    return CL_SUCCESS
}

@_cdecl("clSVMAlloc")
public func clSVMAlloc(_ context: cl_context,
                       _ flags: cl_svm_mem_flags,
                       _ size: size_t,
                       _ alignment: cl_uint) -> UnsafeMutableRawPointer? {
    let _context = context.toContext()
    let metalDevice = _context.metalDevice as! Device

    return metalDevice.svmAlloc(flags: flags,
                                size: size,
                                alignment: Int(alignment))
}

@_cdecl("clSVMFree")
public func clSVMFree(_ context: cl_context,
                      _ pointer: UnsafeMutableRawPointer) {
    let _context = context.toContext()
    let metalDevice = _context.metalDevice as! Device

    _context.commandQueue().enqueueMetalNativeEvent {
        metalDevice.svmFree(pointer: pointer)
    }
}

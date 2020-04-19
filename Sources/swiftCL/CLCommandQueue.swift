import swiftMetal
import COpenCL
import Foundation

internal extension cl_command_queue {
    func toCommandQueue(retained: Bool = false) -> CommandQueue {
        guard retained else {
            return Unmanaged <CommandQueue>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <CommandQueue>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension CommandQueue {
    func toCLCommandQueue(retained: Bool = false) -> cl_command_queue {
        guard retained else {
            return cl_command_queue(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_command_queue(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clEnqueueMapBuffer") @discardableResult
public func clEnqueueMapBuffer(_ command_queue: cl_command_queue,
                               _ buffer: cl_mem,
                               _ blocking_map: cl_bool,
                               _ map_flags: cl_map_flags,
                               _ offset: size_t,
                               _ size: size_t,
                               _ num_events_in_wait_list: cl_uint,
                               _ event_wait_list: UnsafePointer <cl_event?>?,
                               _ event: UnsafeMutablePointer <cl_event?>?,
                               _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> UnsafeMutableRawPointer? {
    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()
    let result = commandQueue.map(buffer: _buffer,
                                  blockingMap: blocking_map == CL_TRUE)

    errcode_ret?.pointee = CL_SUCCESS
    return result
}

@_cdecl("clEnqueueNDRangeKernel") @discardableResult
public func clEnqueueNDRangeKernel(_ command_queue: cl_command_queue,
                                   _ kernel: cl_kernel,
                                   _ work_dim: cl_uint,
                                   _ global_work_offset: UnsafePointer <size_t>?,
                                   _ global_work_size: UnsafePointer <size_t>,
                                   _ local_work_size: UnsafePointer <size_t>?,
                                   _ num_events_in_wait_list: cl_uint,
                                   _ event_wait_list: UnsafePointer <cl_event?>?,
                                   _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let commandQueue = command_queue.toCommandQueue()
    let _kernel = kernel.toMetalKernel()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue), kernel: \(kernel), work_dim: \(work_dim), num_events_in_wait_list: \(num_events_in_wait_list), event_wait_list: \(String(describing: event_wait_list)), event: \(String(describing: event))")

        for i in 0..<Int(work_dim) {
            print("    global [work_offset: %zu, work_size: %zu], local_work_size: %zu",
                  (global_work_offset != nil) ? global_work_offset![i] : 0, global_work_size[i],
                  (local_work_size != nil) ? local_work_size![i] : 0)
        }
    }

    commandQueue.enqueueNDRangeKernel(kernel: _kernel,
                                      workDim: Int(work_dim),
                                      global_work_offset: global_work_offset,
                                      global_work_size: global_work_size,
                                      local_work_size: local_work_size,
                                      eventWaitList: nil,
                                      event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueReadBuffer") @discardableResult
public func clEnqueueReadBuffer(_ command_queue: cl_command_queue,
                                _ buffer: cl_mem,
                                _ blocking_read: cl_bool,
                                _ offset: size_t,
                                _ size: size_t,
                                _ ptr: UnsafeMutableRawPointer,
                                _ num_events_in_wait_list: cl_uint,
                                _ event_wait_list: UnsafePointer <cl_event?>?,
                                _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue), buffer: \(buffer), blocking_read: \(blocking_read), offset: \(offset), size: \(size), ptr: \(ptr), num_events_in_wait_list: \(num_events_in_wait_list), event_wait_list: \(String(describing: event_wait_list)), event: \(String(describing: event))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()

    commandQueue.enqueueReadBuffer(buffer: _buffer,
                                   blockingRead: blocking_read == CL_TRUE,
                                   offset: offset,
                                   size: size,
                                   ptr: ptr,
                                   eventWaitList: nil,
                                   event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMFree") @discardableResult
public func clEnqueueSVMFree(_ command_queue: cl_command_queue,
                             _ num_svm_pointers: cl_uint,
                             _ svm_pointers: UnsafeMutablePointer <UnsafeMutableRawPointer?>,
                             _ pfn_free_func: (@convention (c) (cl_command_queue?,
                                                                cl_uint,
                                                                UnsafeMutablePointer <UnsafeMutableRawPointer?>?,
                                                                UnsafeMutableRawPointer?) -> Void)!,
                             _ user_data: UnsafeMutableRawPointer,
                             _ num_events_in_wait_list: cl_uint,
                             _ event_wait_list: UnsafePointer <cl_event?>?,
                             _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let _ = command_queue.toCommandQueue()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function):")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMMap") @discardableResult
public func clEnqueueSVMMap(_ command_queue: cl_command_queue,
                            _ blocking_map: cl_bool,
                            _ flags: cl_map_flags,
                            _ svm_ptr: UnsafeMutableRawPointer,
                            _ size: size_t,
                            _ num_events_in_wait_list: cl_uint,
                            _ event_wait_list: UnsafePointer <cl_event?>,
                            _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let _ = command_queue.toCommandQueue()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function):")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMMemcpy") @discardableResult
public func clEnqueueSVMMemcpy(_ command_queue: cl_command_queue,
                               _ blocking_copy: cl_bool,
                               _ dst_ptr: UnsafeMutableRawPointer,
                               _ src_ptr: UnsafeRawPointer,
                               _ size: size_t,
                               _ num_events_in_wait_list: cl_uint,
                               _ eventWaitList: UnsafePointer <cl_event?>?,
                               _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let commandQueue = command_queue.toCommandQueue()

    commandQueue.enqueueSVMMemcpy(blocking_copy: blocking_copy == CL_TRUE,
                                  dst_ptr: dst_ptr,
                                  src_ptr: src_ptr,
                                  size: size,
                                  num_events_in_wait_list: Int(num_events_in_wait_list),
                                  eventWaitList: eventWaitList,
                                  event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMMemFill") @discardableResult
public func clEnqueueSVMMemFill(_ command_queue: cl_command_queue,
                                _ svm_ptr: UnsafeMutableRawPointer,
                                _ pattern: UnsafeRawPointer,
                                _ pattern_size: size_t,
                                _ size: size_t,
                                _ num_events_in_wait_list: cl_uint,
                                _ event_wait_list: UnsafePointer <cl_event?>?,
                                _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let _ = command_queue.toCommandQueue()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function):")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMMigrateMem") @discardableResult
public func clEnqueueSVMMigrateMem(_ command_queue: cl_command_queue,
                                   _ num_svm_pointers: cl_uint,
                                   _ svm_pointers: UnsafeMutablePointer <UnsafeRawPointer?>,
                                   _ sizes: UnsafePointer <Int>,
                                   _ flags: cl_mem_migration_flags,
                                   _ num_events_in_wait_list: cl_uint,
                                   _ event_wait_list: UnsafePointer <cl_event?>?,
                                   _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let _ = command_queue.toCommandQueue()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function):")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueSVMUnmap") @discardableResult
public func clEnqueueSVMUnmap(_ command_queue: cl_command_queue,
                              _ svm_ptr: UnsafeMutableRawPointer,
                              _ num_events_in_wait_list: cl_uint,
                              _ event_wait_list: UnsafePointer <cl_event?>?,
                              _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let _ = command_queue.toCommandQueue()

    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function):")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueTask") @discardableResult
public func clEnqueueTask(_ command_queue: cl_command_queue,
                          _ kernel: cl_kernel,
                          _ num_events_in_wait_list: cl_uint,
                          _ event_wait_list: UnsafePointer <cl_event?>?,
                          _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let workSize = [1]

    return clEnqueueNDRangeKernel(command_queue, kernel, 1, nil, workSize, workSize,
                                  num_events_in_wait_list, event_wait_list, event)
}

@_cdecl("clEnqueueUnmapMemObject") @discardableResult
public func clEnqueueUnmapMemObject(_ command_queue: cl_command_queue,
                                    _ memobj: cl_mem,
                                    _ mapped_ptr: UnsafeMutableRawPointer,
                                    _ num_events_in_wait_list: cl_uint,
                                    _ event_wait_list: UnsafePointer <cl_event?>?,
                                    _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    let commandQueue = command_queue.toCommandQueue()
    let _memObj = memobj.toMetalMemObj()

    commandQueue.unmap(memObj: _memObj)
    return CL_SUCCESS
}

@_cdecl("clFinish") @discardableResult
public func clFinish(_ command_queue: cl_command_queue) -> cl_int {
    let commandQueue = command_queue.toCommandQueue()

    commandQueue.finish()
    return CL_SUCCESS
}

@_cdecl("clFlush") @discardableResult
public func clFlush(_ command_queue: cl_command_queue) -> cl_int {
    let commandQueue = command_queue.toCommandQueue()

    commandQueue.flush()
    return CL_SUCCESS
}

@_cdecl("clEnqueueBarrier") @discardableResult
public func clEnqueueBarrier(_ command_queue: cl_command_queue) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()

    commandQueue.enqueueBarrier()
    return CL_SUCCESS
}

@_cdecl("clEnqueueBarrierWithWaitList") @discardableResult
public func clEnqueueBarrierWithWaitList(_ command_queue: cl_command_queue,
                                         _ num_events_in_wait_list: cl_uint,
                                         _ event_wait_list: UnsafePointer <cl_event?>?,
                                         _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()

    commandQueue.enqueueBarrier(eventWaitList: nil,
                                event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueCopyBuffer") @discardableResult
public func clEnqueueCopyBuffer(_ command_queue: cl_command_queue,
                                _ src_buffer: cl_mem,
                                _ dst_buffer: cl_mem,
                                _ src_offset: size_t,
                                _ dst_offset: size_t,
                                _ size: size_t,
                                _ num_events_in_wait_list: cl_uint,
                                _ event_wait_list: UnsafePointer <cl_event?>?,
                                _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let sourceBuffer = src_buffer.toBuffer()
    let destinationBuffer = dst_buffer.toBuffer()

    commandQueue.enqueueCopyBuffer(sourceBuffer: sourceBuffer,
                                   destinationBuffer: destinationBuffer,
                                   sourceOffset: src_offset,
                                   destinationOffset: dst_offset,
                                   size: size,
                                   eventWaitList: nil,
                                   event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueCopyBufferRect") @discardableResult
public func clEnqueueCopyBufferRect(_ command_queue: cl_command_queue,
                                    _ src_buffer: cl_mem,
                                    _ dst_buffer: cl_mem,
                                    _ src_origin: UnsafePointer <size_t>,
                                    _ dst_origin: UnsafePointer <size_t>,
                                    _ region: UnsafePointer <size_t>,
                                    _ src_row_pitch: size_t,
                                    _ src_slice_pitch: size_t,
                                    _ dst_row_pitch: size_t,
                                    _ dst_slice_pitch: size_t,
                                    _ num_events_in_wait_list: cl_uint,
                                    _ event_wait_list: UnsafePointer <cl_event?>?,
                                    _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let sourceBuffer = src_buffer.toBuffer()
    let destinationBuffer = dst_buffer.toBuffer()
    let srcOrigin = [(src_origin[0]), (src_origin[1]), (src_origin[2])]
    let dstOrigin = [(dst_origin[0]), (dst_origin[1]), (dst_origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueCopyBufferRect(sourceBuffer: sourceBuffer,
                                       destinationBuffer: destinationBuffer,
                                       srcOrigin: srcOrigin,
                                       dstOrigin: dstOrigin,
                                       region: rectRegion,
                                       srcRowPitch: src_row_pitch,
                                       srcSlicePitch: src_slice_pitch,
                                       dstRowPitch: dst_row_pitch,
                                       dstSlicePitch: dst_slice_pitch,
                                       eventWaitList: nil,
                                       event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueCopyBufferToImage") @discardableResult
public func clEnqueueCopyBufferToImage(_ command_queue: cl_command_queue,
                                       _ src_buffer: cl_mem,
                                       _ dst_image: cl_mem,
                                       _ src_offset: size_t,
                                       _ dst_origin: UnsafePointer <size_t>,
                                       _ region: UnsafePointer <size_t>,
                                       _ num_events_in_wait_list: cl_uint,
                                       _ event_wait_list: UnsafePointer <cl_event?>?,
                                       _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let sourceBuffer = src_buffer.toBuffer()
    let destinationImage = dst_image.toImage()
    let dstOrigin = [(dst_origin[0]), (dst_origin[1]), (dst_origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueCopyBufferToImage(sourceBuffer: sourceBuffer,
                                          destinationImage: destinationImage,
                                          srcOffset: src_offset,
                                          dstOrigin: dstOrigin,
                                          region: rectRegion,
                                          eventWaitList: nil,
                                          event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueCopyImage") @discardableResult
public func clEnqueueCopyImage(_ command_queue: cl_command_queue,
                               _ src_image: cl_mem,
                               _ dst_image: cl_mem,
                               _ src_origin: UnsafePointer <size_t>,
                               _ dst_origin: UnsafePointer <size_t>,
                               _ region: UnsafePointer <size_t>,
                               _ num_events_in_wait_list: cl_uint,
                               _ event_wait_list: UnsafePointer <cl_event?>?,
                               _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let sourceImage = src_image.toImage()
    let destinationImage = dst_image.toImage()
    let srcOrigin = [(src_origin[0]), (src_origin[1]), (src_origin[2])]
    let dstOrigin = [(dst_origin[0]), (dst_origin[1]), (dst_origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueCopyImage(sourceImage: sourceImage,
                                  destinationImage: destinationImage,
                                  srcOrigin: srcOrigin,
                                  dstOrigin: dstOrigin,
                                  region: rectRegion,
                                  eventWaitList: nil,
                                  event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueCopyImageToBuffer") @discardableResult
public func clEnqueueCopyImageToBuffer(_ command_queue: cl_command_queue,
                                       _ src_image: cl_mem,
                                       _ dst_buffer: cl_mem,
                                       _ src_origin: UnsafePointer <size_t>,
                                       _ region: UnsafePointer <size_t>,
                                       _ dst_offset: size_t,
                                       _ num_events_in_wait_list: cl_uint,
                                       _ event_wait_list: UnsafePointer <cl_event?>?,
                                       _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let sourceImage = src_image.toImage()
    let destinationBuffer = dst_buffer.toBuffer()
    let srcOrigin = [(src_origin[0]), (src_origin[1]), (src_origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueCopyImageToBuffer(sourceImage: sourceImage,
                                          destinationBuffer: destinationBuffer,
                                          srcOrigin: srcOrigin,
                                          region: rectRegion,
                                          dstOffset: dst_offset,
                                          eventWaitList: nil,
                                          event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueFillBuffer") @discardableResult
public func clEnqueueFillBuffer(_ command_queue: cl_command_queue,
                                _ buffer: cl_mem,
                                _ pattern: UnsafeRawPointer,
                                _ pattern_size: size_t,
                                _ offset: size_t,
                                _ size: size_t,
                                _ num_events_in_wait_list: cl_uint,
                                _ event_wait_list: UnsafePointer <cl_event?>?,
                                _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()

    commandQueue.enqueueFillBuffer(buffer: _buffer,
                                   pattern: pattern,
                                   patternSize: pattern_size,
                                   offset: offset,
                                   size: size,
                                   eventWaitList: nil,
                                   event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueFillImage") @discardableResult
public func clEnqueueFillImage(_ command_queue: cl_command_queue,
                               _ image: cl_mem,
                               _ fill_color: UnsafeRawPointer,
                               _ origin: UnsafePointer <size_t>,
                               _ region: UnsafePointer <size_t>,
                               _ num_events_in_wait_list: cl_uint,
                               _ event_wait_list: UnsafePointer <cl_event?>?,
                               _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _image = image.toImage()
    let rectOrigin = [(origin[0]), (origin[1]), (origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueFillImage(image: _image,
                                  fillDolor: fill_color,
                                  origin: rectOrigin,
                                  region: rectRegion,
                                  eventWaitList: nil,
                                  event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueMapImage") @discardableResult
public func clEnqueueMapImage(_ command_queue: cl_command_queue,
                              _ image: cl_mem,
                              _ blocking_map: cl_bool,
                              _ map_flags: cl_map_flags,
                              _ origin: UnsafePointer <size_t>,
                              _ region: UnsafePointer <size_t>,
                              _ image_row_pitch: UnsafeMutablePointer <size_t>,
                              _ image_slice_pitch: UnsafeMutablePointer <size_t>,
                              _ num_events_in_wait_list: cl_uint,
                              _ event_wait_list: UnsafePointer <cl_event?>?,
                              _ event: UnsafeMutablePointer <cl_event?>?,
                              _ errcode_ret: UnsafeMutablePointer <cl_int>?) -> UnsafeMutableRawPointer? {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let _ = command_queue.toCommandQueue()
    let _ = image.toImage()

    return nil
}

@_cdecl("clEnqueueMigrateMemObjects") @discardableResult
public func clEnqueueMigrateMemObjects(_ command_queue: cl_command_queue,
                                       _ num_mem_objects: cl_uint,
                                       _ mem_objects: UnsafePointer <cl_mem>,
                                       _ flags: cl_mem_migration_flags,
                                       _ num_events_in_wait_list: cl_uint,
                                       _ event_wait_list: UnsafePointer <cl_event?>?,
                                       _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    return CL_SUCCESS
}

@_cdecl("clEnqueueMarker") @discardableResult
public func clEnqueueMarker(command_queue: cl_command_queue,
                            event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue), event: \(String(describing: event)))")
    }

    let commandQueue = command_queue.toCommandQueue()

    commandQueue.enqueueMarker(waitList: nil,
                              event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueMarkerWithWaitList") @discardableResult
public func clEnqueueMarkerWithWaitList(_ command_queue: cl_command_queue,
                                        _ num_events_in_wait_list: cl_uint,
                                        _ event_wait_list: UnsafePointer <cl_event>?,
                                        _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue), num_events_in_wait_list: \(num_events_in_wait_list), event_wait_list: \(String(describing: event_wait_list)), event: \(String(describing: event)))")
    }

    let commandQueue = command_queue.toCommandQueue()
    var metalEventWaitList: [MetalEvent] = []

    for i in 0..<Int(num_events_in_wait_list) {
        let metalEvent = event_wait_list![i].toMetalEvent()

        metalEventWaitList.append(metalEvent)
    }

    commandQueue.enqueueMarker(waitList: metalEventWaitList,
                               event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueNativeKernel") @discardableResult
public func clEnqueueNativeKernel(_ command_queue: cl_command_queue?,
                                  _ user_func: (@convention (c) (UnsafeMutableRawPointer) -> Void)?,
                                  _ args: UnsafeMutableRawPointer,
                                  _ cb_args: size_t,
                                  _ num_mem_objects: cl_uint,
                                  _ mem_list: UnsafePointer <cl_mem>,
                                  _ args_mem_loc: UnsafeMutablePointer <UnsafeRawPointer>,
                                  _ num_events_in_wait_list: cl_uint,
                                  _ event_wait_list: UnsafePointer <cl_event?>?,
                                  _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(String(describing: command_queue)))")
    }

    guard let _command_queue = command_queue else {
        return CL_INVALID_COMMAND_QUEUE
    }

    guard let _user_func = user_func else {
        return CL_INVALID_KERNEL
    }

    let commandQueue = _command_queue.toCommandQueue()

    commandQueue.enqueueNativeKernel(userFunction: {
        _user_func(args)
    },
                                     eventWaitList: nil,
                                     event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueReadBufferRect") @discardableResult
public func clEnqueueReadBufferRect(_ command_queue: cl_command_queue,
                                    _ buffer: cl_mem,
                                    _ blocking_read: cl_bool,
                                    _ buffer_offset: UnsafePointer <size_t>,
                                    _ host_offset: UnsafePointer <size_t>,
                                    _ region: UnsafePointer <size_t>,
                                    _ buffer_row_pitch: size_t,
                                    _ buffer_slice_pitch: size_t,
                                    _ host_row_pitch: size_t,
                                    _ host_slice_pitch: size_t,
                                    _ ptr: UnsafeMutableRawPointer,
                                    _ num_events_in_wait_list: cl_uint,
                                    _ event_wait_list: UnsafePointer <cl_event?>?,
                                    _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()
    let bufferOffset = [(buffer_offset[0]), (buffer_offset[1]), (buffer_offset[2])]
    let hostOffset = [(host_offset[0]), (host_offset[1]), (host_offset[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueReadBufferRect(buffer: _buffer,
                                       blockingRead: blocking_read == CL_TRUE,
                                       bufferOffset: bufferOffset,
                                       hostOffset: hostOffset,
                                       region: rectRegion,
                                       bufferRowPitch: buffer_row_pitch,
                                       bufferSlicePitch: buffer_slice_pitch,
                                       hostRowPitch: host_row_pitch,
                                       hostSlicePitch: host_slice_pitch,
                                       ptr: ptr,
                                       eventWaitList: nil,
                                       event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueReadImage") @discardableResult
public func clEnqueueReadImage(_ command_queue: cl_command_queue,
                               _ image: cl_mem,
                               _ blocking_read: cl_bool,
                               _ origin: UnsafePointer <size_t>,
                               _ region: UnsafePointer <size_t>,
                               _ row_pitch: size_t,
                               _ slice_pitch: size_t,
                               _ ptr: UnsafeMutableRawPointer,
                               _ num_events_in_wait_list: cl_uint,
                               _ event_wait_list: UnsafePointer <cl_event?>?,
                               _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _image = image.toImage()
    let rectOrigin = [(origin[0]), (origin[1]), (origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueReadImage(image: _image,
                                  blockingRead: blocking_read == CL_TRUE,
                                  origin: rectOrigin,
                                  region: rectRegion,
                                  rowPitch: row_pitch,
                                  slicePitch: slice_pitch,
                                  ptr: ptr,
                                  eventWaitList: nil,
                                  event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueWaitForEvents") @discardableResult
public func clEnqueueWaitForEvents(_ command_queue: cl_command_queue,
                                   _ num_events: cl_uint,
                                   _ event_list: UnsafePointer <cl_event>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue), num_events: \(num_events), event_list: \(String(describing: event_list)))")
    }

    let commandQueue = command_queue.toCommandQueue()
    var metalEvents: [MetalEvent] = []

    for i in 0..<Int(num_events) {
        let metalEvent = event_list![i].toMetalEvent()

        metalEvents.append(metalEvent)
    }

    commandQueue.enqueueWait(forEvents: metalEvents)
    return CL_SUCCESS
}

@_cdecl("clEnqueueWriteBuffer") @discardableResult
public func clEnqueueWriteBuffer(_ command_queue: cl_command_queue,
                                 _ buffer: cl_mem,
                                 _ blocking_write: cl_bool,
                                 _ offset: size_t,
                                 _ size: size_t,
                                 _ ptr: UnsafeRawPointer,
                                 _ num_events_in_wait_list: cl_uint,
                                 _ event_wait_list: UnsafePointer <cl_event?>?,
                                 _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()

    commandQueue.enqueueWriteBuffer(buffer: _buffer,
                                    blockingWrite: blocking_write == CL_TRUE,
                                    offset: offset,
                                    size: size,
                                    ptr: ptr,
                                    eventWaitList: nil,
                                    event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueWriteBufferRect") @discardableResult
public func clEnqueueWriteBufferRect(_ command_queue: cl_command_queue,
                                     _ buffer: cl_mem,
                                     _ blocking_write: cl_bool,
                                     _ buffer_offset: UnsafePointer <size_t>,
                                     _ host_offset: UnsafePointer <size_t>,
                                     _ region: UnsafePointer <size_t>,
                                     _ buffer_row_pitch: size_t,
                                     _ buffer_slice_pitch: size_t,
                                     _ host_row_pitch: size_t,
                                     _ host_slice_pitch: size_t,
                                     _ ptr: UnsafeRawPointer,
                                     _ num_events_in_wait_list: cl_uint,
                                     _ event_wait_list: UnsafePointer <cl_event?>?,
                                     _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _buffer = buffer.toBuffer()
    let bufferOffset = [(buffer_offset[0]), (buffer_offset[1]), (buffer_offset[2])]
    let hostOffset = [(host_offset[0]), (host_offset[1]), (host_offset[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueWriteBufferRect(buffer: _buffer,
                                        blockingWrite: blocking_write == CL_TRUE,
                                        bufferOffset: bufferOffset,
                                        hostOffset: hostOffset,
                                        region: rectRegion,
                                        bufferRowPitch: buffer_row_pitch,
                                        bufferSlicePitch: buffer_slice_pitch,
                                        hostRowPitch: host_row_pitch,
                                        hostSlicePitch: host_slice_pitch,
                                        ptr: ptr,
                                        eventWaitList: nil,
                                        event: event)
    return CL_SUCCESS
}

@_cdecl("clEnqueueWriteImage") @discardableResult
public func clEnqueueWriteImage(_ command_queue: cl_command_queue,
                                _ image: cl_mem,
                                _ blocking_write: cl_bool,
                                _ origin: UnsafePointer <size_t>,
                                _ region: UnsafePointer <size_t>,
                                _ input_row_pitch: size_t,
                                _ input_slice_pitch: size_t,
                                _ ptr: UnsafeRawPointer,
                                _ num_events_in_wait_list: cl_uint,
                                _ event_wait_list: UnsafePointer <cl_event?>?,
                                _ event: UnsafeMutablePointer <cl_event?>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _image = image.toImage()
    let rectOrigin = [(origin[0]), (origin[1]), (origin[2])]
    let rectRegion = [(region[0]), (region[1]), (region[2])]

    commandQueue.enqueueWriteImage(image: _image,
                                   blockingWrite: blocking_write == CL_TRUE,
                                   origin: rectOrigin,
                                   region: rectRegion,
                                   inputRowPitch: input_row_pitch,
                                   inputSlicePitch: input_slice_pitch,
                                   ptr: ptr,
                                   eventWaitList: nil,
                                   event: event)
    return CL_SUCCESS
}

@_cdecl("clGetCommandQueueInfo") @discardableResult
public func clGetCommandQueueInfo(_ command_queue: cl_command_queue,
                                  _ param_name: cl_command_queue_info,
                                  _ param_value_size: size_t,
                                  _ param_value: UnsafeMutableRawPointer,
                                  _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    return CL_SUCCESS
}

@_cdecl("clReleaseCommandQueue") @discardableResult
public func clReleaseCommandQueue(_ command_queue: cl_command_queue) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let _ = command_queue.toCommandQueue(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainCommandQueue") @discardableResult
public func clRetainCommandQueue(_ command_queue: cl_command_queue) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    let commandQueue = command_queue.toCommandQueue()
    let _ = commandQueue.toCLCommandQueue(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetCommandQueueProperty") @discardableResult
public func clSetCommandQueueProperty(_ command_queue: cl_command_queue,
                                      _ properties: cl_command_queue_properties,
                                      _ enable: cl_bool,
                                      _ old_properties: UnsafeMutablePointer <cl_command_queue_properties>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(command_queue: \(command_queue))")
    }

    return CL_SUCCESS
}

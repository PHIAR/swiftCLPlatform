import swiftMetal
import COpenCL

@_cdecl("clGetEventInfo")
public func clGetEventInfo(_ event: cl_event,
                           _ param_name: cl_event_info,
                           _ param_value_size: size_t,
                           _ param_value: UnsafeMutableRawPointer?,
                           _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event))")
    }

    let _ = event.toMetalEvent()

    return CL_SUCCESS
}

@_cdecl("clGetEventProfilingInfo") @discardableResult
public func clGetEventProfilingInfo(_ event: cl_event,
                                    _ param_name: cl_profiling_info,
                                    _ param_value_size: size_t,
                                    _ param_value: UnsafeMutableRawPointer?,
                                    _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event))")
    }

    let _ = event.toMetalEvent()

    return CL_SUCCESS
}

@_cdecl("clReleaseEvent") @discardableResult
public func clReleaseEvent(_ event: cl_event) -> cl_int
{
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event))")
    }

    let _ = event.toMetalEvent(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainEvent") @discardableResult
public func clRetainEvent(_ event: cl_event) -> cl_int
{
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event))")
    }

    let metalEvent = event.toMetalEvent()
    let _ = metalEvent.toOpaquePointer(retained: true)

    return CL_SUCCESS
}

@_cdecl("clSetEventCallback") @discardableResult
public func clSetEventCallback(_ event: cl_event,
                               _ command_exec_callback_type: cl_int,
                               _ pfn_notify: (@convention (c) (cl_event?,
                                                               cl_int,
                                                               UnsafeMutableRawPointer?) -> Void)!,
                               _ user_data: UnsafeMutableRawPointer?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event), command_exec_callback_type: \(command_exec_callback_type), pfn_notify: \(String(describing: pfn_notify)), user_data: \(String(describing: user_data))")
    }

    let metalEvent = event.toMetalEvent()

    metalEvent.metalCommandQueue.enqueueMetalNativeEvent {
        pfn_notify(event, command_exec_callback_type, user_data)
    }

    return CL_SUCCESS
}

@_cdecl("clSetUserEventStatus") @discardableResult
public func clSetUserEventStatus(_ event: cl_event,
                                 _ execution_status: cl_int) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(event: \(event))")
    }

    let _ = event.toMetalEvent()

    return CL_SUCCESS
}

@_cdecl("clWaitForEvents") @discardableResult
public func clWaitForEvents(_ num_events: cl_uint,
                            _ event_list: UnsafePointer <cl_event>?) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(num_events: \(num_events), event_list: \(String(describing: event_list)))")
    }

    return CL_SUCCESS
}

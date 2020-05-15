import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class Device: MetalDevice {
    private static let driverVersion = "2.0"

    private final weak var platform: Platform? = nil

    internal lazy var paramValues: [cl_device_info: Any] = [
        cl_device_info(CL_DEVICE_ADDRESS_BITS): UInt32(32),
        cl_device_info(CL_DEVICE_AVAILABLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_BUILT_IN_KERNELS): "",
        cl_device_info(CL_DEVICE_COMPILER_AVAILABLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_DOUBLE_FP_CONFIG): UInt64(cl_device_fp_config()),
        cl_device_info(CL_DEVICE_ENDIAN_LITTLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_ERROR_CORRECTION_SUPPORT): cl_bool(CL_FALSE),
        cl_device_info(CL_DEVICE_EXECUTION_CAPABILITIES): UInt32(cl_device_exec_capabilities(CL_EXEC_KERNEL)),
        cl_device_info(CL_DEVICE_EXTENSIONS): Platform.extensions,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE): UInt64(),
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE): cl_device_mem_cache_type(),
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_SIZE): UInt64(Device.globalMemorySize),
        cl_device_info(CL_DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE): UInt32(4),
        cl_device_info(CL_DEVICE_HALF_FP_CONFIG): UInt64(cl_device_fp_config(CL_FP_ROUND_TO_NEAREST |
                                                                             CL_FP_INF_NAN)),
        cl_device_info(CL_DEVICE_HOST_UNIFIED_MEMORY): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_IMAGE_MAX_ARRAY_SIZE): UInt64(self.device.maxBufferLength),
        cl_device_info(CL_DEVICE_IMAGE_MAX_BUFFER_SIZE): UInt64(self.device.maxBufferLength),
        cl_device_info(CL_DEVICE_IMAGE_SUPPORT): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_HEIGHT): UInt64(2048),
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_WIDTH): UInt64(2048),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_DEPTH): UInt64(512),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_HEIGHT): UInt64(512),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_WIDTH): UInt64(512),
        cl_device_info(CL_DEVICE_LINKER_AVAILABLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_LOCAL_MEM_SIZE): UInt64(self.device.maxThreadgroupMemoryLength),
        cl_device_info(CL_DEVICE_LOCAL_MEM_TYPE): UInt64(cl_device_local_mem_type(CL_LOCAL)),
        cl_device_info(CL_DEVICE_MAX_CLOCK_FREQUENCY): UInt32(800),
        cl_device_info(CL_DEVICE_MAX_COMPUTE_UNITS): UInt32(32),
        cl_device_info(CL_DEVICE_MAX_CONSTANT_ARGS): UInt32(16),
        cl_device_info(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE): UInt64(self.device.maxBufferLength),
        cl_device_info(CL_DEVICE_MAX_GLOBAL_VARIABLE_SIZE): UInt32(64),
        cl_device_info(CL_DEVICE_MAX_MEM_ALLOC_SIZE): UInt64(Device.globalMemorySize),
        cl_device_info(CL_DEVICE_MAX_ON_DEVICE_EVENTS): UInt32(1024),
        cl_device_info(CL_DEVICE_MAX_ON_DEVICE_QUEUES): UInt32(1),
        cl_device_info(CL_DEVICE_MAX_PARAMETER_SIZE): UInt64(64),
        cl_device_info(CL_DEVICE_MAX_PIPE_ARGS): UInt32(0),
        cl_device_info(CL_DEVICE_MAX_READ_IMAGE_ARGS): UInt32(16),
        cl_device_info(CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS): UInt32(0),
        cl_device_info(CL_DEVICE_MAX_SAMPLERS): UInt32(32),
        cl_device_info(CL_DEVICE_MAX_WORK_GROUP_SIZE): UInt64(self.testLimitsComputePipelineState.maxTotalThreadsPerThreadgroup),
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS): UInt32(3),
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_SIZES): (2048, 2048, 2048),
        cl_device_info(CL_DEVICE_MAX_WRITE_IMAGE_ARGS): UInt32(8),
        cl_device_info(CL_DEVICE_MEM_BASE_ADDR_ALIGN): UInt32(16),
        cl_device_info(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE): UInt32(4),
        cl_device_info(CL_DEVICE_NAME): "swiftCL",
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR): UInt32(4),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE): UInt32(0),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT): UInt32(1),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF): UInt32(1),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_INT): UInt32(1),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG): UInt32(1),
        cl_device_info(CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT): UInt32(1),
        cl_device_info(CL_DEVICE_OPENCL_C_VERSION): "OpenCL 1.2",
        cl_device_info(CL_DEVICE_PARTITION_AFFINITY_DOMAIN): UInt32(0),
        cl_device_info(CL_DEVICE_PARTITION_PROPERTIES): UInt64(cl_device_partition_property(0)),
        cl_device_info(CL_DEVICE_PARTITION_MAX_SUB_DEVICES): UInt32(0),
        cl_device_info(CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS): UInt32(0),
        cl_device_info(CL_DEVICE_PIPE_MAX_PACKET_SIZE): UInt32(0),
        cl_device_info(CL_DEVICE_PLATFORM): MemoryLayout <cl_platform_id>.size,
        cl_device_info(CL_DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT): UInt32(4),
        cl_device_info(CL_DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT): UInt32(4),
        cl_device_info(CL_DEVICE_PREFERRED_INTEROP_USER_SYNC): cl_bool(CL_FALSE),
        cl_device_info(CL_DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT): UInt32(4),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR): UInt32(4),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE): UInt32(0),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT): UInt32(1),
        cl_device_info(CL_DEVICE_PRINTF_BUFFER_SIZE): UInt64(0),
        cl_device_info(CL_DEVICE_PROFILE): "EMBEDDED_PROFILE",
        cl_device_info(CL_DEVICE_PROFILING_TIMER_RESOLUTION): UInt64(1000),
        cl_device_info(CL_DEVICE_QUEUE_ON_DEVICE_MAX_SIZE): UInt32(65536),
        cl_device_info(CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE): UInt32(65536),
        cl_device_info(CL_DEVICE_QUEUE_ON_DEVICE_PROPERTIES): UInt32(0),
        cl_device_info(CL_DEVICE_QUEUE_ON_HOST_PROPERTIES): UInt32(cl_command_queue_properties()),
        cl_device_info(CL_DEVICE_SINGLE_FP_CONFIG): UInt64(cl_device_fp_config(CL_FP_ROUND_TO_NEAREST |
                                                                               CL_FP_INF_NAN)),
        cl_device_info(CL_DEVICE_SVM_CAPABILITIES): UInt32(CL_DEVICE_SVM_FINE_GRAIN_BUFFER),
        cl_device_info(CL_DEVICE_TYPE): UInt32(CL_DEVICE_TYPE_GPU),
        cl_device_info(CL_DEVICE_VENDOR): "swiftCL",
        cl_device_info(CL_DEVICE_VENDOR_ID): UInt32(0x00000000),
        cl_device_info(CL_DEVICE_VERSION): Platform.version,
        cl_device_info(CL_DRIVER_VERSION): Device.driverVersion,
    ]

    internal func createContext() -> Context? {
        return Context(metalDevice: self)
    }

    internal func getDeviceInfo(paramName: cl_device_info,
                                paramValueSize: Int,
                                paramValue: UnsafeMutableRawPointer?,
                                paramValueSizeRet: UnsafeMutablePointer <size_t>?) -> Bool {
        switch Int32(paramName) {
        case CL_DEVICE_ADDRESS_BITS,
             CL_DEVICE_EXECUTION_CAPABILITIES,
             CL_DEVICE_GLOBAL_MEM_CACHE_TYPE,
             CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE,
             CL_DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE,
             CL_DEVICE_MAX_CLOCK_FREQUENCY,
             CL_DEVICE_MAX_COMPUTE_UNITS,
             CL_DEVICE_MAX_CONSTANT_ARGS,
             CL_DEVICE_MAX_GLOBAL_VARIABLE_SIZE,
             CL_DEVICE_MAX_ON_DEVICE_EVENTS,
             CL_DEVICE_MAX_ON_DEVICE_QUEUES,
             CL_DEVICE_MAX_PIPE_ARGS,
             CL_DEVICE_MAX_READ_IMAGE_ARGS,
             CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS,
             CL_DEVICE_MAX_SAMPLERS,
             CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS,
             CL_DEVICE_MAX_WRITE_IMAGE_ARGS,
             CL_DEVICE_MEM_BASE_ADDR_ALIGN,
             CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_INT,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG,
             CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT,
             CL_DEVICE_PARTITION_AFFINITY_DOMAIN,
             CL_DEVICE_PARTITION_MAX_SUB_DEVICES,
             CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS,
             CL_DEVICE_PIPE_MAX_PACKET_SIZE,
             CL_DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT,
             CL_DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT,
             CL_DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT,
             CL_DEVICE_QUEUE_ON_DEVICE_MAX_SIZE,
             CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE,
             CL_DEVICE_QUEUE_ON_DEVICE_PROPERTIES,
             CL_DEVICE_QUEUE_ON_HOST_PROPERTIES,
             CL_DEVICE_SVM_CAPABILITIES,
             CL_DEVICE_TYPE,
             CL_DEVICE_VENDOR_ID:
            paramValueSizeRet?.pointee = MemoryLayout <UInt32>.size
            paramValue?.assumingMemoryBound(to: UInt32.self).pointee = self.paramValues[paramName] as! UInt32

        case CL_DEVICE_AVAILABLE,
             CL_DEVICE_COMPILER_AVAILABLE,
             CL_DEVICE_ENDIAN_LITTLE,
             CL_DEVICE_ERROR_CORRECTION_SUPPORT,
             CL_DEVICE_HOST_UNIFIED_MEMORY,
             CL_DEVICE_IMAGE_SUPPORT,
             CL_DEVICE_LINKER_AVAILABLE,
             CL_DEVICE_PREFERRED_INTEROP_USER_SYNC:
            paramValueSizeRet?.pointee = MemoryLayout <cl_bool>.size
            paramValue?.assumingMemoryBound(to: cl_bool.self).pointee = self.paramValues[paramName] as! cl_bool

        case CL_DEVICE_DOUBLE_FP_CONFIG,
             CL_DEVICE_LOCAL_MEM_SIZE,
             CL_DEVICE_LOCAL_MEM_TYPE,
             CL_DEVICE_GLOBAL_MEM_CACHE_SIZE,
             CL_DEVICE_GLOBAL_MEM_SIZE,
             CL_DEVICE_HALF_FP_CONFIG,
             CL_DEVICE_IMAGE_MAX_ARRAY_SIZE,
             CL_DEVICE_IMAGE_MAX_BUFFER_SIZE,
             CL_DEVICE_IMAGE2D_MAX_HEIGHT,
             CL_DEVICE_IMAGE2D_MAX_WIDTH,
             CL_DEVICE_IMAGE3D_MAX_DEPTH,
             CL_DEVICE_IMAGE3D_MAX_HEIGHT,
             CL_DEVICE_IMAGE3D_MAX_WIDTH,
             CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE,
             CL_DEVICE_MAX_MEM_ALLOC_SIZE,
             CL_DEVICE_MAX_WORK_GROUP_SIZE,
             CL_DEVICE_MAX_PARAMETER_SIZE,
             CL_DEVICE_PARTITION_PROPERTIES,
             CL_DEVICE_PRINTF_BUFFER_SIZE,
             CL_DEVICE_PROFILING_TIMER_RESOLUTION,
             CL_DEVICE_SINGLE_FP_CONFIG:
            paramValueSizeRet?.pointee = MemoryLayout <UInt64>.size
            paramValue?.assumingMemoryBound(to: UInt64.self).pointee = self.paramValues[paramName] as! UInt64

        case CL_DEVICE_MAX_WORK_ITEM_SIZES:
            paramValueSizeRet?.pointee = MemoryLayout <(Int, Int, Int)>.size
            paramValue?.assumingMemoryBound(to: (Int, Int, Int).self).pointee = self.paramValues[paramName] as! (Int, Int, Int)

        case CL_DEVICE_BUILT_IN_KERNELS,
             CL_DEVICE_EXTENSIONS,
             CL_DEVICE_NAME,
             CL_DEVICE_OPENCL_C_VERSION,
             CL_DEVICE_PROFILE,
             CL_DEVICE_VENDOR,
             CL_DEVICE_VERSION,
             CL_DRIVER_VERSION:
            let stringValue = self.paramValues[paramName] as! String

            paramValueSizeRet?.pointee = stringValue.count

            if let pointer = paramValue?.assumingMemoryBound(to: CChar.self) {
                let _ = stringValue.withCString { memcpy(pointer, $0) }
            }

        case CL_DEVICE_PLATFORM:
            let platform = cl_platform_id(UnsafeRawPointer(Unmanaged.passUnretained(self.platform!).toOpaque()))

            paramValueSizeRet?.pointee = MemoryLayout <cl_platform_id>.size
            paramValue?.assumingMemoryBound(to: cl_platform_id.self).pointee = platform

        default:
            print(String(format: "\(#function)(device: \(device), paramName: 0x%04x, paramValueSize: \(paramValueSize), paramValue: \(String(describing: paramValue)), paramValueSizeRet: \(String(describing: paramValueSizeRet)))", paramName))
        }

        return true
    }

    internal func set(platform: Platform) {
        self.platform = platform
    }

    internal func svmAlloc(flags: cl_svm_mem_flags,
                           size: size_t,
                           alignment: Int) -> UnsafeMutableRawPointer? {
        return self.sharedVirtualMemoryAlloc(size: size,
                                             alignment: alignment)
    }

    internal func svmFree(pointer: UnsafeMutableRawPointer) {
        self.sharedVirtualMemoryFree(pointer: pointer)
    }
}

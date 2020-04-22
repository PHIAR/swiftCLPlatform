import swiftMetal
import COpenCL
import Foundation
import Metal

public final class Device: MetalDevice {
    private static let deviceVersion = "OpenCL 2.0"
    private static let driverVersion = "2.0"
    private static let paramValueSizes: [cl_device_info: Int] = [
        cl_device_info(CL_DEVICE_ADDRESS_BITS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_AVAILABLE): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_COMPILER_AVAILABLE): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_DOUBLE_FP_CONFIG): MemoryLayout <cl_device_fp_config>.size,
        cl_device_info(CL_DEVICE_ENDIAN_LITTLE): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_ERROR_CORRECTION_SUPPORT): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_EXECUTION_CAPABILITIES): MemoryLayout <cl_device_exec_capabilities>.size,
        cl_device_info(CL_DEVICE_EXTENSIONS): 1,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE): MemoryLayout <cl_device_mem_cache_type>.size,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_HALF_FP_CONFIG): MemoryLayout <cl_device_fp_config>.size,
        cl_device_info(CL_DEVICE_HOST_UNIFIED_MEMORY): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_IMAGE_SUPPORT): MemoryLayout <cl_bool>.size,
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_HEIGHT): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_WIDTH): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_DEPTH): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_HEIGHT): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_WIDTH): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_LOCAL_MEM_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_LOCAL_MEM_TYPE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_MAX_CLOCK_FREQUENCY): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_COMPUTE_UNITS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_CONSTANT_ARGS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_MAX_MEM_ALLOC_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_MAX_PARAMETER_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_MAX_READ_IMAGE_ARGS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_SAMPLERS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_WORK_GROUP_SIZE): MemoryLayout <UInt64>.size,
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_SIZES): 3 * MemoryLayout <Int>.size,
        cl_device_info(CL_DEVICE_MAX_WRITE_IMAGE_ARGS): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MEM_BASE_ADDR_ALIGN): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_NAME): 1,
        cl_device_info(CL_DEVICE_PLATFORM): MemoryLayout <cl_platform_id>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_PROFILE): 1,
        cl_device_info(CL_DEVICE_PROFILING_TIMER_RESOLUTION): MemoryLayout <Int>.size,
        cl_device_info(CL_DEVICE_QUEUE_ON_HOST_PROPERTIES): MemoryLayout <cl_command_queue_properties>.size,
        cl_device_info(CL_DEVICE_SINGLE_FP_CONFIG): MemoryLayout <cl_device_fp_config>.size,
        cl_device_info(CL_DEVICE_SVM_CAPABILITIES): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_TYPE): MemoryLayout <cl_device_type>.size,
        cl_device_info(CL_DEVICE_VENDOR): 1,
        cl_device_info(CL_DEVICE_VENDOR_ID): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_VERSION): 1,
        cl_device_info(CL_DRIVER_VERSION): 1,
    ]

    internal lazy var paramValues: [cl_device_info: Any] = [
        cl_device_info(CL_DEVICE_ADDRESS_BITS): UInt32(32),
        cl_device_info(CL_DEVICE_AVAILABLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_COMPILER_AVAILABLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_DOUBLE_FP_CONFIG): cl_device_fp_config(),
        cl_device_info(CL_DEVICE_ENDIAN_LITTLE): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_ERROR_CORRECTION_SUPPORT): cl_bool(CL_FALSE),
        cl_device_info(CL_DEVICE_EXECUTION_CAPABILITIES): cl_device_exec_capabilities(),
        cl_device_info(CL_DEVICE_EXTENSIONS): "",
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE): UInt64(),
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE): cl_device_mem_cache_type(),
        cl_device_info(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE): MemoryLayout <UInt32>.size,
        cl_device_info(CL_DEVICE_GLOBAL_MEM_SIZE): Device.globalMemorySize,
        cl_device_info(CL_DEVICE_HALF_FP_CONFIG): cl_device_fp_config(),
        cl_device_info(CL_DEVICE_HOST_UNIFIED_MEMORY): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_IMAGE_SUPPORT): cl_bool(CL_TRUE),
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_HEIGHT): UInt64(2048),
        cl_device_info(CL_DEVICE_IMAGE2D_MAX_WIDTH): UInt64(2048),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_DEPTH): UInt64(512),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_HEIGHT): UInt64(512),
        cl_device_info(CL_DEVICE_IMAGE3D_MAX_WIDTH): UInt64(512),
        cl_device_info(CL_DEVICE_LOCAL_MEM_SIZE): UInt64(self.device.maxThreadgroupMemoryLength),
        cl_device_info(CL_DEVICE_LOCAL_MEM_TYPE): UInt64(cl_device_local_mem_type(CL_LOCAL)),
        cl_device_info(CL_DEVICE_MAX_CLOCK_FREQUENCY): UInt32(800),
        cl_device_info(CL_DEVICE_MAX_COMPUTE_UNITS): UInt32(32),
        cl_device_info(CL_DEVICE_MAX_CONSTANT_ARGS): UInt32(16),
        cl_device_info(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE): UInt64(self.device.maxBufferLength),
        cl_device_info(CL_DEVICE_MAX_MEM_ALLOC_SIZE): Device.globalMemorySize,
        cl_device_info(CL_DEVICE_MAX_PARAMETER_SIZE): UInt64(64),
        cl_device_info(CL_DEVICE_MAX_READ_IMAGE_ARGS): UInt32(16),
        cl_device_info(CL_DEVICE_MAX_SAMPLERS): UInt32(32),
        cl_device_info(CL_DEVICE_MAX_WORK_GROUP_SIZE): UInt64(self.testLimitsComputePipelineState.maxTotalThreadsPerThreadgroup),
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS): UInt32(3),
        cl_device_info(CL_DEVICE_MAX_WORK_ITEM_SIZES): [2048, 2048, 2048],
        cl_device_info(CL_DEVICE_MAX_WRITE_IMAGE_ARGS): UInt32(8),
        cl_device_info(CL_DEVICE_MEM_BASE_ADDR_ALIGN): UInt32(16),
        cl_device_info(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE): UInt32(1),
        cl_device_info(CL_DEVICE_NAME): "swiftCL",
        cl_device_info(CL_DEVICE_PLATFORM): MemoryLayout <cl_platform_id>.size,
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT): UInt32(1),
        cl_device_info(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE): UInt32(1),
        cl_device_info(CL_DEVICE_PROFILE): "FULL_PROFILE",
        cl_device_info(CL_DEVICE_PROFILING_TIMER_RESOLUTION): MemoryLayout <Int>.size,
        cl_device_info(CL_DEVICE_QUEUE_ON_HOST_PROPERTIES): MemoryLayout <cl_command_queue_properties>.size,
        cl_device_info(CL_DEVICE_SINGLE_FP_CONFIG): cl_device_fp_config(CL_FP_ROUND_TO_NEAREST | CL_FP_INF_NAN),
        cl_device_info(CL_DEVICE_SVM_CAPABILITIES): UInt32(CL_DEVICE_SVM_FINE_GRAIN_BUFFER),
        cl_device_info(CL_DEVICE_TYPE): UInt32(CL_DEVICE_TYPE_GPU),
        cl_device_info(CL_DEVICE_VENDOR): "swiftCL",
        cl_device_info(CL_DEVICE_VENDOR_ID): UInt32(0x00000000),
        cl_device_info(CL_DEVICE_VERSION): Device.deviceVersion,
        cl_device_info(CL_DRIVER_VERSION): Device.driverVersion,
    ]

    internal func createContext() -> Context? {
        return Context(metalDevice: self)
    }

    internal func getDeviceInfo(paramName: cl_device_info,
                                paramValueSize: Int,
                                paramValue _paramValue: UnsafeMutableRawPointer?,
                                paramValueSizeRet: UnsafeMutablePointer <size_t>?) -> Bool {
        guard var paramNameValueSize = Device.paramValueSizes[paramName] else {
            return false
        }

        guard paramValueSize != 0 else {
            guard let _paramValueSizeRet = paramValueSizeRet else {
                return false
            }

            _paramValueSizeRet.pointee = paramNameValueSize
            return true
        }

        guard let paramValue = _paramValue else {
            return false
        }

        switch Int32(paramName) {
        case CL_DEVICE_ADDRESS_BITS,
             CL_DEVICE_MAX_CLOCK_FREQUENCY,
             CL_DEVICE_MAX_COMPUTE_UNITS,
             CL_DEVICE_MAX_CONSTANT_ARGS,
             CL_DEVICE_MAX_READ_IMAGE_ARGS,
             CL_DEVICE_MAX_SAMPLERS,
             CL_DEVICE_MAX_WRITE_IMAGE_ARGS,
             CL_DEVICE_MEM_BASE_ADDR_ALIGN,
             CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT,
             CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE,
             CL_DEVICE_SVM_CAPABILITIES,
             CL_DEVICE_TYPE:
            let value = self.paramValues[paramName] as! UInt32
            let pointer = paramValue.assumingMemoryBound(to: UInt32.self)

            pointer.pointee = value

        case CL_DEVICE_AVAILABLE,
             CL_DEVICE_COMPILER_AVAILABLE,
             CL_DEVICE_ENDIAN_LITTLE,
             CL_DEVICE_ERROR_CORRECTION_SUPPORT,
             CL_DEVICE_HOST_UNIFIED_MEMORY,
             CL_DEVICE_IMAGE_SUPPORT:
            let value = self.paramValues[paramName] as! cl_bool
            let pointer = paramValue.assumingMemoryBound(to: cl_bool.self)

            pointer.pointee = value

        case CL_DEVICE_DOUBLE_FP_CONFIG:
            let value = self.paramValues[paramName] as! UInt64
            let pointer = paramValue.assumingMemoryBound(to: UInt64.self)

            pointer.pointee = value

        case CL_DEVICE_MAX_WORK_ITEM_SIZES:
            let value = self.paramValues[paramName] as! [Int]
            let pointer = paramValue.assumingMemoryBound(to: Int.self)

            pointer.pointee = value[0]
            pointer.advanced(by: 1).pointee = value[1]
            pointer.advanced(by: 2).pointee = value[2]

        case CL_DEVICE_LOCAL_MEM_SIZE,
             CL_DEVICE_LOCAL_MEM_TYPE,
             CL_DEVICE_MAX_WORK_GROUP_SIZE,
             CL_DEVICE_MAX_PARAMETER_SIZE,
             CL_DEVICE_IMAGE2D_MAX_HEIGHT,
             CL_DEVICE_IMAGE2D_MAX_WIDTH,
             CL_DEVICE_IMAGE3D_MAX_DEPTH,
             CL_DEVICE_IMAGE3D_MAX_HEIGHT,
             CL_DEVICE_IMAGE3D_MAX_WIDTH:
             print(paramName)
            let value = self.paramValues[paramName] as! UInt64
            let pointer = paramValue.assumingMemoryBound(to: UInt64.self)

            pointer.pointee = value

        case CL_DEVICE_EXTENSIONS,
             CL_DEVICE_NAME,
             CL_DEVICE_VENDOR,
             CL_DEVICE_VERSION,
             CL_DRIVER_VERSION:
            let stringValue = self.paramValues[paramName] as! String
            let pointer = paramValue.assumingMemoryBound(to: CChar.self)
            let _ = stringValue.withCString { strcpy(pointer, $0) }

            paramNameValueSize = stringValue.count

        case CL_DEVICE_PLATFORM:
            let platform = cl_platform_id(UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()))
            let pointer = paramValue.assumingMemoryBound(to: cl_platform_id.self)

            pointer.pointee = platform

        default:
            print(String(format: "\(#function)(device: \(device), paramName: 0x%04x, paramValueSize: \(paramValueSize), paramValue: \(paramValue), paramValueSizeRet: \(String(describing: paramValueSizeRet)))", paramName))
        }

        if let _paramValueSizeRet = paramValueSizeRet {
            _paramValueSizeRet.pointee = paramNameValueSize
        }

        return true
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

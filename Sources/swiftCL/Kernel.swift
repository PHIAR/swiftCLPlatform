import swiftMetal
import COpenCL
import Foundation
import Metal

public final class Kernel: MetalKernel {
    private static let paramValueSizes: [cl_kernel_work_group_info: Int] = [
        cl_kernel_work_group_info(CL_KERNEL_COMPILE_WORK_GROUP_SIZE): MemoryLayout <size_t>.size,
        cl_kernel_work_group_info(CL_KERNEL_LOCAL_MEM_SIZE): MemoryLayout <UInt64>.size,
        cl_kernel_work_group_info(CL_KERNEL_WORK_GROUP_SIZE): 3 * MemoryLayout <size_t>.size,
    ]

    private lazy var paramValues: [cl_kernel_work_group_info: Any] = [
        cl_kernel_work_group_info(CL_KERNEL_COMPILE_WORK_GROUP_SIZE): [
            size_t(self.computePipelineState.threadExecutionWidth),
            size_t(self.computePipelineState.threadExecutionWidth),
            size_t(self.computePipelineState.threadExecutionWidth)],
        cl_kernel_work_group_info(CL_KERNEL_LOCAL_MEM_SIZE): UInt64(0),
        cl_kernel_work_group_info(CL_KERNEL_WORK_GROUP_SIZE): self.computePipelineState.maxTotalThreadsPerThreadgroup,
    ]

    internal func clone() -> Kernel {
        return Kernel(metalContext: self.metalContext,
                      computePipelineState: self.computePipelineState)
    }

    public func getKernelWorkGroupInfo(paramName: cl_kernel_work_group_info ,
                                       paramValueSize: size_t,
                                       paramValue: UnsafeMutableRawPointer,
                                       paramValueSizeRet: UnsafeMutablePointer <size_t>?) -> Bool {
        guard let paramNameValueSize = Kernel.paramValueSizes[paramName] else {
            return false
        }

        guard paramValueSize != 0 else {
            guard let _paramValueSizeRet = paramValueSizeRet else {
                return false
            }

            _paramValueSizeRet.pointee = paramNameValueSize
            return true
        }

        switch Int32(paramName) {
        case CL_KERNEL_COMPILE_WORK_GROUP_SIZE:
            let value = self.paramValues[paramName] as! [size_t]
            let pointer = paramValue.assumingMemoryBound(to: size_t.self)

            pointer.pointee = value[0]
            pointer.advanced(by: 1).pointee = value[1]
            pointer.advanced(by: 2).pointee = value[2]
            break

        case CL_KERNEL_LOCAL_MEM_SIZE:
            let value = self.paramValues[paramName] as! UInt64
            let pointer = paramValue.assumingMemoryBound(to: UInt64.self)

            pointer.pointee = value
            break

        case CL_KERNEL_WORK_GROUP_SIZE:
            let value = self.paramValues[paramName] as! size_t
            let pointer = paramValue.assumingMemoryBound(to: size_t.self)

            pointer.pointee = value
            break

        default:
            break
        }

        if let _paramValueSizeRet = paramValueSizeRet {
            _paramValueSizeRet.pointee = paramNameValueSize
        }

        return true
    }
    public func setKernelArg(index: Int,
                             size: Int,
                             value: UnsafeRawPointer) {
        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("\(#function)(arg_index: \(index), arg_size: \(size), arg_value: \(value))")
        }

        precondition(index < self.arguments.count)

        if size == MemoryLayout <cl_mem>.size {
            let metalContext = self.metalContext
            let metalDevice = metalContext.metalDevice
            let memoryObject = value.assumingMemoryBound(to: Int.self).pointee
            var hasMemObj = false

            metalDevice.resourceQueue.sync {
                hasMemObj = metalDevice.aliveMemObjects.contains(memoryObject)
            }

            guard !hasMemObj else {
                let buffer = value.assumingMemoryBound(to: cl_mem.self).pointee.toMetalBuffer().metalBuffer()

                self.arguments[index] = KernelArg(buffer: (buffer, 0))
                self.maxSetArgument = max(index, self.maxSetArgument)
                return
            }
        }

        let kernelArg: KernelArg

        if size <= MemoryLayout <KernelArg.Constant>.size {
            kernelArg = KernelArg(pointer: value,
                                  size: size)
        } else {
            kernelArg = KernelArg(data: Data(bytes: value,
                                             count: size))
        }

        self.arguments[index] = kernelArg
        self.maxSetArgument = max(index, self.maxSetArgument)
    }

    public func setKernelArgSVMPointer(index: Int,
                                       value: UnsafeRawPointer) {
        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("\(#function)(index: \(index), value: \(value))")
        }

        precondition(index < self.arguments.count)

        let _value = Int(bitPattern: value)
        let (buffer: buffer,
             offset: offset) = self.metalContext.metalDevice.getBuffer(pointer: _value)!

        self.arguments[index] = KernelArg(buffer: (buffer, offset))
        self.maxSetArgument = max(index, self.maxSetArgument)
    }
}

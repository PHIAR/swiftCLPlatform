import COpenCL
import Foundation
import XCTest

private let DATA_SIZE = 1024

internal final class swiftCLTests: XCTestCase {
    func testExample() {
        let source = ("""
            __kernel void square(__global float *input, __global float *output, const unsigned int count) {
                int i = get_global_id(0);

                if (i < count) {
                    output[i] = input[i] * input[i];
                }
            }
        """).utf8CString

        var err = cl_int(0)
        var device_id: cl_device_id? = nil

        clGetDeviceIDs(nil, cl_device_type(CL_DEVICE_TYPE_GPU), 1, &device_id, nil)

        let context = clCreateContext(nil, 1, &device_id, nil, nil, &err)!
        let commands = clCreateCommandQueue(context, device_id, 0, &err)!
        var sources = [
            source.withUnsafeBufferPointer { $0 }.baseAddress
        ]

        guard let program = clCreateProgramWithSource(context, 1, &sources[0], nil, &err) else {
            return
        }

        clBuildProgram(program, 0, nil, nil, nil, nil)

        let kernel = clCreateKernel(program, "square", &err)!
        var input = clCreateBuffer(context,  cl_mem_flags(CL_MEM_READ_ONLY),  MemoryLayout <Float>.size * DATA_SIZE, nil, nil)!
        var output = clCreateBuffer(context, cl_mem_flags(CL_MEM_WRITE_ONLY), MemoryLayout <Float>.size * DATA_SIZE, nil, nil)!
        var data: [Float] = []

        for i in 0..<DATA_SIZE {
            data.append(Float(i))
        }

        err = clEnqueueWriteBuffer(commands, input, cl_bool(CL_TRUE), 0, MemoryLayout <Float>.size * DATA_SIZE, data, 0, nil, nil)
        clSetKernelArg(kernel, 0, MemoryLayout <cl_mem>.size, &input)
        clSetKernelArg(kernel, 1, MemoryLayout <cl_mem>.size, &output)

        var count = DATA_SIZE

        clSetKernelArg(kernel, 2, MemoryLayout <UInt32>.size, &count);

        var local = size_t(0)

        clGetKernelWorkGroupInfo(kernel, device_id, cl_kernel_work_group_info(CL_KERNEL_WORK_GROUP_SIZE), MemoryLayout <size_t>.size, &local, nil)

        var global = count

        clEnqueueNDRangeKernel(commands, kernel, 1, nil, &global, &local, 0, nil, nil)
        clFinish(commands)

        var results = Array(repeating: Float(0.0),
                            count: DATA_SIZE)

        clEnqueueReadBuffer(commands, output, cl_bool(CL_TRUE), 0, MemoryLayout <Float>.size * count, &results[0], 0, nil, nil)

        var correct = 0

        for i in 0..<count {
            if results[i] == (data[i] * data[i]) {
                correct += 1
            }
        }

        print("Computed '\(correct)/\(count)' correct values!\n")
        clReleaseMemObject(input)
        clReleaseMemObject(output)
        clReleaseProgram(program)
        clReleaseKernel(kernel)
        clReleaseCommandQueue(commands)
        clReleaseContext(context)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}


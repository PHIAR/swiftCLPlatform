import COpenCL
import Foundation
import XCTest

private let SWIFTCL_ENABLE_LOG = false

internal final class swiftCLTests: XCTestCase {
    private static let maxIterations = 2048

    func testSquareValues() {
        let source = ("""
        __kernel void
        square(__global float *input,
               __global float *output,
               unsigned int const count)
        {
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

        let maxIterations = swiftCLTests.maxIterations
        let kernel = clCreateKernel(program, "square", &err)!
        var input = clCreateBuffer(context,  cl_mem_flags(CL_MEM_READ_ONLY),  MemoryLayout <Float>.size * maxIterations, nil, nil)!
        var output = clCreateBuffer(context, cl_mem_flags(CL_MEM_WRITE_ONLY), MemoryLayout <Float>.size * maxIterations, nil, nil)!

        for iteration in 1...maxIterations {
            var count = iteration
            var data = Array(repeating: Float(1.0),
                             count: count)

            for i in 0..<count {
                data[i] = Float(min(Int(sqrt(Float(65504))), i * iteration))
            }

            err = clEnqueueWriteBuffer(commands, input, cl_bool(CL_TRUE), 0, MemoryLayout <Float>.size * count, data, 0, nil, nil)

            clSetKernelArg(kernel, 0, MemoryLayout <cl_mem>.size, &input)
            clSetKernelArg(kernel, 1, MemoryLayout <cl_mem>.size, &output)
            clSetKernelArg(kernel, 2, MemoryLayout <UInt32>.size, &count);

            var local = size_t(0)

            clGetKernelWorkGroupInfo(kernel, device_id, cl_kernel_work_group_info(CL_KERNEL_WORK_GROUP_SIZE), MemoryLayout <size_t>.size, &local, nil)

            var global = count

            clEnqueueNDRangeKernel(commands, kernel, 1, nil, &global, &local, 0, nil, nil)
            clFinish(commands)

            var results = Array(repeating: Float(0.0),
                                count: count)

            clEnqueueReadBuffer(commands, output, cl_bool(CL_TRUE), 0, MemoryLayout <Float>.size * count, &results[0], 0, nil, nil)

            var correct = 0
            let expected = data.map { $0 * $0 }

            for i in 0..<count {
                if results[i] == expected[i] {
                    correct += 1
                }
            }

            if SWIFTCL_ENABLE_LOG {
                print("Expected: \(expected)")
                print("Got: \(results)")
            }

            print("Iteration \(iteration) computed '\(correct)/\(count)' correct values!")
            XCTAssertEqual(correct, count)
        }

        clReleaseMemObject(input)
        clReleaseMemObject(output)
        clReleaseProgram(program)
        clReleaseKernel(kernel)
        clReleaseCommandQueue(commands)
        clReleaseContext(context)
    }

    static var allTests = [
        ("testSquareValues", testSquareValues),
    ]
}


import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class CommandQueue: MetalCommandQueue {
    public var context: Context {
        return self.metalContext as! Context
    }

    public func enqueueBarrier() {
    }

    public func enqueueBarrier(eventWaitList: [MetalEvent]?,
                               event: UnsafeMutablePointer <cl_event?>?) {
    }

    public func enqueueCopyBuffer(sourceBuffer: Buffer,
                                  destinationBuffer: Buffer,
                                  sourceOffset: size_t,
                                  destinationOffset: size_t,
                                  size: size_t,
                                  eventWaitList: [MetalEvent]?,
                                  event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalBlitCommand(eventWaitList: eventWaitList,
                                     event: event) { blitCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                blitCommandEncoder.label = "clEnqueueCopyBuffer"
            }

            blitCommandEncoder.copy(from: sourceBuffer.buffer,
                                    sourceOffset: sourceOffset,
                                    to: destinationBuffer.buffer,
                                    destinationOffset: destinationOffset,
                                    size: size)
        }
    }

    public func enqueueCopyBufferRect(sourceBuffer: Buffer,
                                      destinationBuffer: Buffer,
                                      srcOrigin: [size_t],
                                      dstOrigin: [size_t],
                                      region: [size_t],
                                      srcRowPitch: size_t,
                                      srcSlicePitch: size_t,
                                      dstRowPitch: size_t,
                                      dstSlicePitch: size_t,
                                      eventWaitList: [MetalEvent]?,
                                      event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueCopyBufferRect"
            }
        }
    }

    public func enqueueCopyBufferToImage(sourceBuffer: Buffer,
                                         destinationImage: Image,
                                         srcOffset: size_t,
                                         dstOrigin: [size_t],
                                         region: [size_t],
                                         eventWaitList: [MetalEvent]?,
                                         event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueCopyBufferToImage"
            }
        }
    }

    public func enqueueCopyImage(sourceImage: Image,
                                 destinationImage: Image,
                                 srcOrigin: [size_t],
                                 dstOrigin: [size_t],
                                 region: [size_t],
                                 eventWaitList: [MetalEvent]?,
                                 event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueCopyImage"
            }
        }
    }

    public func enqueueCopyImageToBuffer(sourceImage: Image,
                                         destinationBuffer: Buffer,
                                         srcOrigin: [size_t],
                                         region: [size_t],
                                         dstOffset: size_t,
                                         eventWaitList: [MetalEvent]?,
                                         event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueCopyImageToBuffer"
            }
        }
    }

    public func enqueueFillBuffer(buffer: Buffer,
                                  pattern: UnsafeRawPointer,
                                  patternSize: size_t ,
                                  offset: size_t,
                                  size: size_t,
                                  eventWaitList: [MetalEvent]?,
                                  event: UnsafeMutablePointer <cl_event?>?) {
        let range = offset..<(offset + size)
        let value = pattern.assumingMemoryBound(to: UInt8.self).pointee

        self.enqueueMetalBlitCommand(eventWaitList: eventWaitList,
                                     event: event) { blitCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                blitCommandEncoder.label = "clEnqueueFillBuffer"
            }

            blitCommandEncoder.fill(buffer: buffer.buffer,
                                    range: range,
                                    value: value)
        }
    }

    public func enqueueFillImage(image: Image,
                                 fillDolor: UnsafeRawPointer,
                                 origin: [size_t],
                                 region: [size_t],
                                 eventWaitList: [MetalEvent]?,
                                 event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueFillImage"
            }
        }
    }

    public func enqueueMarker(waitList eventWaitList: [MetalEvent]?,
                              event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueMarker"
            }
        }
    }

    public func enqueueNativeKernel(userFunction: () -> Void,
                                    eventWaitList: [MetalEvent]?,
                                    event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueNativeKernel"
            }
        }
    }

    public func enqueueNDRangeKernel(kernel: Kernel,
                                     workDim: Int,
                                     global_work_offset: UnsafePointer <size_t>?,
                                     global_work_size: UnsafePointer <size_t>?,
                                     local_work_size: UnsafePointer <size_t>?,
                                     eventWaitList: [MetalEvent]?,
                                     event: UnsafeMutablePointer <cl_event?>?) {
        var threadGroupsPerGrid =  MTLSize(width: 1,
                                           height: 1,
                                           depth: 1)
        var threadsPerThreadgroup = threadGroupsPerGrid

        if let _global_work_size = global_work_size {
            threadGroupsPerGrid.width = _global_work_size.pointee

            if workDim > 1 {
                threadGroupsPerGrid.height = _global_work_size.advanced(by: 1).pointee

                if workDim > 2 {
                    threadGroupsPerGrid.depth = _global_work_size.advanced(by: 2).pointee
                }
            }
        }

        let performDispatchThreadsOptimization = self.dispatchThreadsAPISupported
        let computePipelineState = kernel.computePipelineState

        if let _local_work_size = local_work_size {
            if performDispatchThreadsOptimization {
                threadsPerThreadgroup.width = max(_local_work_size.pointee, 1)

                if workDim > 1 {
                    threadsPerThreadgroup.height = max(_local_work_size.advanced(by: 1).pointee, 1)

                    if workDim > 2 {
                        threadsPerThreadgroup.depth = max(_local_work_size.advanced(by: 2).pointee, 1)
                    }
                }
            } else {
                threadsPerThreadgroup.width = max(_local_work_size.pointee, 1)
                threadGroupsPerGrid.width = max(threadGroupsPerGrid.width / threadsPerThreadgroup.width, 1)

                if workDim > 1 {
                    threadsPerThreadgroup.height = _local_work_size.advanced(by: 1).pointee
                    threadGroupsPerGrid.height = max(threadGroupsPerGrid.height / threadsPerThreadgroup.height, 1)

                    if workDim > 2 {
                        threadsPerThreadgroup.depth = _local_work_size.advanced(by: 2).pointee
                        threadGroupsPerGrid.depth = max(threadGroupsPerGrid.depth / threadsPerThreadgroup.depth, 1)
                    }
                }
            }
        } else {
            if performDispatchThreadsOptimization {
                let maxTotalThreadsPerThreadgroup = computePipelineState.maxTotalThreadsPerThreadgroup
                let width = threadGroupsPerGrid.width
                let height = threadGroupsPerGrid.height

                if ((maxTotalThreadsPerThreadgroup == 512) ||
                    (maxTotalThreadsPerThreadgroup == 1024)) &&
                   ((width % 32) == 0) {
                    threadsPerThreadgroup.width = 32
                } else if width % 16 == 0 {
                    threadsPerThreadgroup.width = 16
                } else if width % 8 == 0 {
                    threadsPerThreadgroup.width = 8
                } else if width % 4 == 0 {
                    threadsPerThreadgroup.width = 4
                } else if width % 2 == 0 {
                    threadsPerThreadgroup.width = 2
                } else {
                    threadsPerThreadgroup.width = 1
                }

                if (maxTotalThreadsPerThreadgroup == 1024) &&
                   ((height % 32) == 0) {
                    threadsPerThreadgroup.height = 32
                } else if height % 16 == 0 {
                    threadsPerThreadgroup.height = 16
                } else if height % 8 == 0 {
                    threadsPerThreadgroup.height = 8
                } else if height % 4 == 0 {
                    threadsPerThreadgroup.height = 4
                } else if height % 2 == 0 {
                    threadsPerThreadgroup.height = 2
                } else {
                    threadsPerThreadgroup.height = 1
                }
            }
        }

        let arguments = kernel.arguments
        let maxSetArgument = kernel.maxSetArgument

        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("threadsPerThreadgroup: \(threadsPerThreadgroup)")
        }

        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueNDRangeKernel"
            }

            computeCommandEncoder.setComputePipelineState(computePipelineState)

            for index in 0...maxSetArgument {
                let argument = arguments[index]

                switch argument.type {
                case .none:
                    computeCommandEncoder.setBuffer(nil,
                                                    offset: 0,
                                                    index: index)

                case .buffer:
                    let (buffer, offset) = argument.buffer!

                    computeCommandEncoder.setBuffer(buffer,
                                                    offset: offset,
                                                    index: index)

                case .constant:
                    var value = argument.constant

                    computeCommandEncoder.setBytes(&value,
                                                   length: argument.size,
                                                   index: index)

                case .data:
                    let data = argument.data!

                    data.withUnsafeBytes {
                        computeCommandEncoder.setBytes($0.baseAddress!,
                                                       length: data.count,
                                                       index: index)
                    }
                }
            }

            if SWIFTCL_ENABLE_CONSOLE_LOG {
                print("    arguments: \(arguments)")
            }

            if performDispatchThreadsOptimization {
            #if os(tvOS)
                computeCommandEncoder.dispatchThreadgroups(threadGroupsPerGrid,
                                                           threadsPerThreadgroup: threadsPerThreadgroup)
            #else
                computeCommandEncoder.dispatchThreads(threadGroupsPerGrid,
                                                      threadsPerThreadgroup: threadsPerThreadgroup)
            #endif
            } else {
                computeCommandEncoder.dispatchThreadgroups(threadGroupsPerGrid,
                                                           threadsPerThreadgroup: threadsPerThreadgroup)
            }
        }
    }

    public func enqueueReadBuffer(buffer: Buffer,
                                  blockingRead: Bool,
                                  offset: Int,
                                  size: Int,
                                  ptr: UnsafeMutableRawPointer,
                                  eventWaitList: [MetalEvent]? = nil,
                                  event: UnsafeMutablePointer <cl_event?>?) {
        guard let ptrBuffer = self.blitHeap.makeBuffer(length: size,
                                                       options: .storageModeShared) else {
            preconditionFailure("Failed to create heap buffer. Blit heap exhausted with stats: \(self.blitHeap.maxAvailableSize(alignment: 1))")
        }

        self.enqueueMetalBlitCommand(eventWaitList: eventWaitList,
                                     event: event) { blitCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                blitCommandEncoder.label = "clEnqueueReadBuffer"
            }

            blitCommandEncoder.copy(from: buffer.buffer,
                                    sourceOffset: offset,
                                    to: ptrBuffer,
                                    destinationOffset: 0,
                                    size: size)
        }

        if blockingRead {
            self.finish()
            memcpy(ptr, ptrBuffer.contents(), size)
        } else {
            self.enqueueMetalNativeEvent {
                memcpy(ptr, ptrBuffer.contents(), size)
            }
        }
    }

    public func enqueueReadBufferRect(buffer: Buffer,
                                      blockingRead: Bool,
                                      bufferOffset: [size_t],
                                      hostOffset: [size_t],
                                      region: [size_t],
                                      bufferRowPitch: size_t,
                                      bufferSlicePitch: size_t,
                                      hostRowPitch: size_t,
                                      hostSlicePitch: size_t,
                                      ptr: UnsafeMutableRawPointer,
                                      eventWaitList: [MetalEvent]?,
                                      event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueReadBufferRect"
            }
        }
    }

    public func enqueueReadImage(image: Image,
                                 blockingRead: Bool,
                                 origin: [size_t],
                                 region: [size_t],
                                 rowPitch: size_t,
                                 slicePitch: size_t,
                                 ptr: UnsafeMutableRawPointer,
                                 eventWaitList: [MetalEvent]?,
                                 event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueReadImage"
            }
        }
    }

    public func enqueueSVMMemcpy(blocking_copy: Bool,
                                 dst_ptr: UnsafeMutableRawPointer,
                                 src_ptr: UnsafeRawPointer,
                                 size: size_t,
                                 num_events_in_wait_list: Int,
                                 eventWaitList: UnsafePointer <cl_event?>?,
                                 event: UnsafeMutablePointer <cl_event?>?) {
        guard let metalContext = self.metalContext as? Context else {
            return
        }

        let dstPtr = Int(bitPattern: dst_ptr)
        let srcPtr = Int(bitPattern: src_ptr)

        guard let (buffer: destinationBuffer,
                   offset: destinationOffset) = metalContext.metalDevice.getBuffer(pointer: dstPtr) else {
            return
        }

        guard let (buffer: sourceBuffer,
                   offset: sourceOffset) = metalContext.metalDevice.getBuffer(pointer: srcPtr) else {
            return
        }

        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("\(#function):")
        }

        self.enqueueMetalBlitCommand(eventWaitList: nil,
                                     event: nil) { blitCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                blitCommandEncoder.label = "enqueueSVMMemcpy"
            }

            blitCommandEncoder.copy(from: sourceBuffer,
                                    sourceOffset: sourceOffset,
                                    to: destinationBuffer,
                                    destinationOffset: destinationOffset,
                                    size: size)
        }

        if blocking_copy {
            self.finish()
        }
    }

    public func enqueueWait(forEvents events: [MetalEvent]) {
    }

    public func enqueueWriteBuffer(buffer: Buffer,
                                   blockingWrite: Bool,
                                   offset: Int,
                                   size: Int,
                                   ptr: UnsafeRawPointer,
                                   eventWaitList: [MetalEvent]?,
                                   event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueWriteMetalBuffer(metalBuffer: buffer.buffer,
                                     blockingWrite: blockingWrite,
                                     offset: offset,
                                     size: size,
                                     ptr: ptr,
                                     eventWaitList: eventWaitList,
                                     event: event)
    }

    public func enqueueWriteBufferRect(buffer: Buffer,
                                       blockingWrite: Bool,
                                       bufferOffset: [size_t],
                                       hostOffset: [size_t],
                                       region: [size_t],
                                       bufferRowPitch: size_t,
                                       bufferSlicePitch: size_t,
                                       hostRowPitch: size_t,
                                       hostSlicePitch: size_t,
                                       ptr: UnsafeRawPointer,
                                       eventWaitList: [MetalEvent]?,
                                       event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueWriteBufferRect"
            }
        }
    }

    public func enqueueWriteImage(image: Image,
                                  blockingWrite: Bool,
                                  origin: [size_t],
                                  region: [size_t],
                                  inputRowPitch: size_t,
                                  inputSlicePitch: size_t,
                                  ptr: UnsafeRawPointer,
                                  eventWaitList: [MetalEvent]?,
                                  event: UnsafeMutablePointer <cl_event?>?) {
        self.enqueueMetalComputeCommand(eventWaitList: eventWaitList,
                                        event: event) { computeCommandEncoder in
            if SWIFTCL_ENABLE_INSTRUMENTATION {
                computeCommandEncoder.label = "clEnqueueWriteImage"
            }
        }
    }

    public func map(buffer: Buffer,
                    blockingMap: Bool = false) -> UnsafeMutableRawPointer? {
        if blockingMap {
            self.finish()

            if buffer.requiresSynchronization() {
                buffer.download()
            }
        }

        let contents = buffer.contents()

        if SWIFTCL_ENABLE_CONSOLE_LOG {
            print("\(#function): \(buffer.buffer), blockingMap: \(blockingMap)) -> \(contents)")
        }

        return contents
    }

    public func unmap(memObj: MetalResource) {
        guard memObj.requiresSynchronization() else {
            return
        }

        self.enqueueMetalNativeCommand { _ in
            memObj.upload()
        }
    }
}

import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class Buffer: MetalBuffer {
}

internal final class Image: MetalTexture {
    public struct Descriptor {
        var image_type = cl_mem_object_type()
        var image_width = size_t()
        var image_height = size_t()
        var image_depth = size_t()
        var image_array_size = size_t()
        var image_row_pitch = size_t()
        var image_slice_pitch = size_t()
        var num_mip_levels = 0
        var num_samples = 0
    }

    internal init?(metalDevice: MetalDevice,
                   flags: cl_mem_flags,
                   imageFormat: cl_image_format,
                   imageDesc: Descriptor,
                   hostPtr: UnsafeRawPointer?) {
        let descriptor = MTLTextureDescriptor()
        let textureTypeForMemObjectType: [cl_mem_object_type: MTLTextureType] = [
            cl_mem_object_type(CL_MEM_OBJECT_IMAGE1D): .type1D,
            cl_mem_object_type(CL_MEM_OBJECT_IMAGE1D_ARRAY): .type1DArray,
            //cl_mem_object_type(CL_MEM_OBJECT_IMAGE1D_BUFFER): .typeTextureBuffercl_image_format,
            cl_mem_object_type(CL_MEM_OBJECT_IMAGE2D): .type2D,
            cl_mem_object_type(CL_MEM_OBJECT_IMAGE2D_ARRAY): .type2DArray,
            cl_mem_object_type(CL_MEM_OBJECT_IMAGE3D): .type3D,
        ]

        guard let textureType = textureTypeForMemObjectType[imageDesc.image_type] else {
            return nil
        }

        let pixelFormatsForImageFormat: [cl_channel_order: [cl_channel_type: MTLPixelFormat]] = [
            cl_channel_order(CL_BGRA): [
                cl_channel_type(CL_UNORM_INT8): .bgra8Unorm,
            ],
        ]

        guard let pixelFormats = pixelFormatsForImageFormat[imageFormat.image_channel_order] else {
            return nil
        }

        guard let pixelFormat = pixelFormats[imageFormat.image_channel_data_type] else {
            return nil
        }

        descriptor.textureType = textureType
        descriptor.pixelFormat = pixelFormat
        descriptor.width = imageDesc.image_width
        descriptor.height = imageDesc.image_height
        descriptor.depth = imageDesc.image_depth
        descriptor.arrayLength = imageDesc.image_array_size
        descriptor.mipmapLevelCount = Int(imageDesc.num_mip_levels)

        guard let texture = metalDevice.device.makeTexture(descriptor: descriptor) else {
            return nil
        }

        if let _hostPtr = hostPtr {
            texture.replace(region: MTLRegion(origin: MTLOrigin(),
                                              size: MTLSize(width: texture.width,
                                                            height: texture.height,
                                                            depth: texture.depth)),
                                              mipmapLevel: 0,
                                              withBytes: _hostPtr,
                                              bytesPerRow: 0)
        }

        super.init(metalDevice: metalDevice,
                   texture: texture)
    }
}

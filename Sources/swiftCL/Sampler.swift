import swiftMetal
import COpenCL
import Foundation
import Metal

public final class Sampler: MetalSampler {
    private static let addressingModesTable: [cl_addressing_mode: MTLSamplerAddressMode] = [
        cl_addressing_mode(CL_ADDRESS_NONE): .clampToEdge,
        cl_addressing_mode(CL_ADDRESS_REPEAT): .repeat,
        cl_addressing_mode(CL_ADDRESS_CLAMP): .clampToZero,
        cl_addressing_mode(CL_ADDRESS_CLAMP_TO_EDGE): .clampToEdge,
    ]
    private static let filterModesTable: [cl_filter_mode: MTLSamplerMinMagFilter] = [
        cl_addressing_mode(CL_FILTER_LINEAR): .linear,
        cl_addressing_mode(CL_FILTER_NEAREST): .nearest,
    ]

    public init?(metalDevice: Device,
                 normalizedCoords: Bool,
                 addressingMode: cl_addressing_mode,
                 filterMode: cl_filter_mode) {
        let device = metalDevice.device
        let descriptor = MTLSamplerDescriptor()

        guard let metalAddressingMode = Sampler.addressingModesTable[addressingMode],
              let metalFilterMode = Sampler.filterModesTable[filterMode] else {
            return nil
        }

        descriptor.minFilter = metalFilterMode
        descriptor.magFilter = metalFilterMode
        descriptor.mipFilter = .notMipmapped
        descriptor.sAddressMode = metalAddressingMode
        descriptor.tAddressMode = metalAddressingMode
        descriptor.rAddressMode = .clampToEdge
        descriptor.normalizedCoordinates = normalizedCoords

        guard let samplerState = device.makeSamplerState(descriptor: descriptor) else {
            return nil
        }

        super.init(samplerState: samplerState)
    }
}

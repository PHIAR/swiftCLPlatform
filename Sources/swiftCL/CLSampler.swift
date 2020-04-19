import swiftMetal
import COpenCL

internal extension cl_sampler {
    func toMetalSampler(retained: Bool = false) -> Sampler {
        guard retained else {
            return Unmanaged <Sampler>.fromOpaque(UnsafeRawPointer(self)!).takeUnretainedValue()
        }

        return Unmanaged <Sampler>.fromOpaque(UnsafeRawPointer(self)!).takeRetainedValue()
    }
}

internal extension Sampler {
    func toCLSampler(retained: Bool = false) -> cl_sampler {
        guard retained else {
            return cl_sampler(Unmanaged.passUnretained(self).toOpaque())
        }

        return cl_sampler(Unmanaged.passRetained(self).toOpaque())
    }
}

@_cdecl("clGetSamplerInfo") @discardableResult
public func clGetSamplerInfo(_ sampler: cl_sampler,
                             _ param_name: cl_sampler_info,
                             _ param_value_size: size_t,
                             _ param_value: UnsafeMutableRawPointer?,
                             _ param_value_size_ret: UnsafeMutablePointer <size_t>?) -> cl_int {
    let _ = sampler.toMetalSampler()

    return CL_SUCCESS
}

@_cdecl("clReleaseSampler") @discardableResult
public func clReleaseSampler(sampler: cl_sampler) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(sampler: \(sampler))")
    }

    let _ = sampler.toMetalSampler(retained: true)

    return CL_SUCCESS
}

@_cdecl("clRetainSampler") @discardableResult
public func clRetainSampler(sampler: cl_sampler) -> cl_int {
    if SWIFTCL_ENABLE_CONSOLE_LOG {
        print("\(#function)(sampler: \(sampler))")
    }

    let metalSampler = sampler.toMetalSampler()
    let _ = metalSampler.toCLSampler(retained: true)

    return CL_SUCCESS
}

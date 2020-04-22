# swiftCL

An OpenCL API implementation in Swift on top of the Metal API.

Note this is a proof of concept implementation and is not complete.

## Building and Verification

swiftCL requires the Google clspv compiler available at https://github.com/google/clspv.
clspv must be built as a shared library called libclspv_core.so and both this library and
the include path to clspv's Compiler.h need to be provided to successfully build

swiftCL uses the Swift Package Manager (swiftpm) for building.

To build:
```
swift build -Xcc -I<path to clspv Compiler.h> -Xlinker -L<path to libclspv_core.so>
```

To test:
In the build output directory link libOpenCL.so to libOpenCL.so.1, i.e.
```
ln -sf libOpenCL.so libOpenCL.so.1
```
and then issue the regular test invocation for SwiftPM.
```
swift test
```


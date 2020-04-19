// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swiftCL",
    products: [
        .library(name: "OpenCL",
                 type: .dynamic,
                 targets: [
            "OpenCL",
        ]),
        .library(name: "COpenCL",
                 targets: [
            "COpenCL",
        ]),
    ],
    dependencies: [
        .package(url: "https://github.com/PHIAR/swiftMetal.git",
                 .branch("master")),
        .package(url: "https://github.com/PHIAR/swiftMetalPlatform.git",
                 .branch("master")),
    ],
    targets: [
        .systemLibrary(name: "COpenCL",
                       providers: [
            .apt([
                "opencl-c-headers",
            ]),
         ]),
        .target(name: "OpenCL",
                dependencies: [
            "COpenCL",
            .product(name: "swiftMetal",
                     package: "swiftMetal"),
            .product(name: "Metal",
                     package: "swiftMetalPlatform"),
        ],
                path: "Sources/swiftCL",
                linkerSettings: [
            .unsafeFlags([ "-Xlinker", "--version-script=Sources/swiftCL/OpenCL.map" ])
        ]),
        .testTarget(name: "swiftCLTests",
                    dependencies: [ "OpenCL" ]),
    ]
)


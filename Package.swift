// swift-tools-version:5.2

import Foundation
import PackageDescription

// MARK - Platform configuration

let platforms: [SupportedPlatform] = [
    .iOS("13.2"),
    .macOS("10.15"),
    .tvOS("13.2")
]

let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
let openCLMapFile = packageURL.appendingPathComponent("Sources/swiftCL/OpenCL.map").path

let package = Package(
    name: "swiftCL",
    platforms: platforms,
    products: [
        .library(name: "OpenCL",
                 type: .dynamic,
                 targets: [
            "OpenCL",
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
        .target(name: "clspv"),
        .target(name: "OpenCL",
                dependencies: [
            "clspv",
            "COpenCL",
            .product(name: "swiftMetal",
                     package: "swiftMetal"),
            .product(name: "Metal",
                     package: "swiftMetalPlatform"),
        ],
                path: "Sources/swiftCL",
                exclude: [
            "OpenCL.map",
        ],
                linkerSettings: [
            .unsafeFlags([
                "-Xlinker", "-soname", "-Xlinker", "libOpenCL.so.1",
                "-Xlinker", "--version-script=\(openCLMapFile)",
            ]),
        ]),
        .testTarget(name: "swiftCLTests",
                    dependencies: [
            "COpenCL",
        ],
                    linkerSettings: [
            .unsafeFlags([
                "-lOpenCL",
            ]),
        ]),
    ]
)


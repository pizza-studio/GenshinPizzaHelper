// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HoYoKit",
    platforms: [
        .iOS(.v15), .watchOS(.v9), .macOS(.v12),
    ],
    products: [
        .library(
            name: "HoYoKit",
            targets: ["HoYoKit"]
        ),
    ],
    targets: [
        .target(
            name: "HoYoKit",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "HoYoKitTests",
            dependencies: ["HoYoKit"]
        ),
    ]
)

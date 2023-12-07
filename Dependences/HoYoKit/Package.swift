// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HoYoKit",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
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

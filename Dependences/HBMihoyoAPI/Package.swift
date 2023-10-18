// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HBMihoyoAPI",
    platforms: [
        .iOS(.v15), .watchOS(.v9), .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HBMihoyoAPI",
            targets: ["HBMihoyoAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(url: "./Dependences/DefaultsKeys", from: "1.0.0"),
        .package(url: "./Dependences/HoYoKit", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HBMihoyoAPI",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "HoYoKit", package: "HoYoKit"),
            ]
        ),
        .testTarget(
            name: "HBMihoyoAPITests",
            dependencies: ["HBMihoyoAPI"]
        ),
    ]
)

// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OPHelper_SharedAssembly",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OPHelper_SharedAssembly",
            targets: ["OPHelper_SharedAssembly"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(path: "../HBMihoyoAPI"),
        .package(path: "../GIPizzaKit"),
        .package(path: "../DefaultsKeys"),
        .package(path: "../SwiftPieChart-1.0.61"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OPHelper_SharedAssembly",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "SwiftPieChart", package: "SwiftPieChart-1.0.61"),
                .product(name: "HBMihoyoAPI", package: "HBMihoyoAPI"),
                .product(name: "GIPizzaKit", package: "GIPizzaKit"),
            ]
        ),
        .testTarget(
            name: "OPHelper_SharedAssemblyTests",
            dependencies: ["OPHelper_SharedAssembly"]
        ),
    ]
)

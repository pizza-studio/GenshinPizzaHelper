// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GIPizzaKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16), .watchOS(.v9), .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GIPizzaKit",
            targets: ["GIPizzaKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.1"),
        .package(url: "https://github.com/pizza-studio/GachaMetaGenerator", from: "2.3.1"),
        .package(path: "../HBMihoyoAPI"),
        .package(path: "../DefaultsKeys"),
        .package(path: "../HoYoKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GIPizzaKit",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "DefaultsKeys", package: "DefaultsKeys"),
                .product(name: "GachaMetaDB", package: "GachaMetaGenerator"),
                .product(name: "HBMihoyoAPI", package: "HBMihoyoAPI"),
                .product(name: "HoYoKit", package: "HoYoKit"),
            ],
            resources: [
                .process("Enka/Assets/characters.json"),
                .process("Enka/Assets/loc.json"),
                .process("Enka/Assets/pfps.json"),
            ]
        ),
        .testTarget(
            name: "GIPizzaKitTests",
            dependencies: [
                "GIPizzaKit",
                .product(name: "GachaMetaDB", package: "GachaMetaGenerator"),
            ]
        ),
    ]
)

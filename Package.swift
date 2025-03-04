// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureFITProfile",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PureFITProfile",
            targets: ["PureFITProfile"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "../purefit", from: "0.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PureFITProfile",
            dependencies: [
                .product(name: "PureFIT", package: "purefit"),
            ]
        ),
        .testTarget(
            name: "PureFITProfileTests",
            dependencies: ["PureFITProfile"],
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)

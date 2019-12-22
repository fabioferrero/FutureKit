// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FutureKit",
    products: [
        .library(name: "FutureKit",targets: ["FutureKit"])
    ],
    targets: [
        .target(
            name: "FutureKit",
            dependencies: []),
        .testTarget(
            name: "FutureKitTests",
            dependencies: ["FutureKit"])
    ]
)

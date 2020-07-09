// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraX",
    platforms: [ .iOS(.v11)],
    products: [
        .library(
            name: "CameraX",
            targets: ["CameraX"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CameraX",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CameraXTests",
            dependencies: ["CameraX"]),
    ]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WarmupUIKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "WarmupUIKit",
            targets: ["WarmupUIKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WarmupUIKit",
            dependencies: [],
            path: "Sources/WarmupUIKit"
        ),
        .testTarget(
            name: "WarmupUIKitTests",
            dependencies: ["WarmupUIKit"],
            path: "Tests/WarmupUIKitTests"
        ),
    ]
)

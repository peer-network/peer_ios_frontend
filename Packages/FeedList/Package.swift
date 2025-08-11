// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedList",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeedList",
            targets: ["FeedList"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Models", path: "../Models"),
        .package(name: "Post", path: "../Post"),
        .package(name: "Environment", path: "../Environment")
    ],
    targets: [
        .target(
            name: "FeedList",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Models", package: "Models"),
                .product(name: "Post", package: "Post"),
                .product(name: "Environment", package: "Environment")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

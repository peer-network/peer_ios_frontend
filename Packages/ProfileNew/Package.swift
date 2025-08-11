// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProfileNew",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ProfileNew",
            targets: ["ProfileNew"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "FeedNew", path: "../FeedNew"),
        .package(name: "FeedList", path: "../FeedList"),
        .package(name: "Analytics", path: "../Analytics")
    ],
    targets: [
        .target(
            name: "ProfileNew",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "FeedNew", package: "FeedNew"),
                .product(name: "FeedList", package: "FeedList"),
                .product(name: "Analytics", package: "Analytics")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PostCreation",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PostCreation",
            targets: ["PostCreation"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "FeedNew", path: "../FeedNew"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser")
    ],
    targets: [
        .target(
            name: "PostCreation",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "FeedNew", package: "FeedNew"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

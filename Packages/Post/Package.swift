// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Post",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Post",
            targets: ["Post"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser")
    ],
    targets: [
        .target(
            name: "Post",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

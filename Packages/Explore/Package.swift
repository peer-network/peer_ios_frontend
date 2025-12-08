// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Explore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Explore",
            targets: ["Explore"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "Models", path: "../Models"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser")
    ],
    targets: [
        .target(
            name: "Explore",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "Models", package: "Models"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

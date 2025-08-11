// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Auth",
            targets: ["Auth"]),
    ],
    dependencies: [
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser"),
        .package(name: "GQLOperationsGuest", path: "../GQLOperationsGuest"),
        .package(name: "DesignSystem", path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
                .product(name: "GQLOperationsGuest", package: "GQLOperationsGuest"),
                .product(name: "DesignSystem", package: "DesignSystem")
            ]
        ),

    ],
    swiftLanguageModes: [.v5]
)

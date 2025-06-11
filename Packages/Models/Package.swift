// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    dependencies: [
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
              ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wallet",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Wallet",
            targets: ["Wallet"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser"),
        .package(name: "Models", path: "../Models"),
        .package(name: "Environment", path: "../Environment"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.1.0"))
    ],
    targets: [
        .target(
            name: "Wallet",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
                .product(name: "Models", package: "Models"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

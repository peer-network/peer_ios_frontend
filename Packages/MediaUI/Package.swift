// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MediaUI",
            targets: ["MediaUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.3.0")),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Models", path: "../Models"),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.8.0"))
    ],
    targets: [
        .target(
            name: "MediaUI",
            dependencies: [
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Models", package: "Models"),
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),

    ],
    swiftLanguageModes: [.v5]
)

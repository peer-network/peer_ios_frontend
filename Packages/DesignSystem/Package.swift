// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.8.0")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.3.0")),
        .package(name: "Environment", path: "../Environment")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Environment", package: "Environment")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

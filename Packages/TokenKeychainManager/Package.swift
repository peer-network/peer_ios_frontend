// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TokenKeychainManager",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TokenKeychainManager",
            targets: ["TokenKeychainManager"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/evgenyneu/keychain-swift.git",
            .upToNextMajor(from: "24.0.0")
        )
    ],
    targets: [
        .target(
            name: "TokenKeychainManager",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift")
            ]
        ),

    ],
    swiftLanguageModes: [.v5]
)

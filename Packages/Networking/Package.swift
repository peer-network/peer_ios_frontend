// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMajor(from: "1.15.3")
        ),
        .package(name: "TokenKeychainManager", path: "../TokenKeychainManager")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloWebSocket", package: "apollo-ios"),
                .product(name: "TokenKeychainManager", package: "TokenKeychainManager")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Environment",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Environment",
            targets: ["Environment"]),
    ],
    dependencies: [
        .package(name: "Networking", path: "../Networking"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser"),
        .package(name: "GQLOperationsGuest", path: "../GQLOperationsGuest"),
        .package(name: "Models", path: "../Models"),
        .package(name: "TokenKeychainManager", path: "../TokenKeychainManager"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.1.0"))
    ],
    targets: [
        .target(
            name: "Environment",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
                .product(name: "GQLOperationsGuest", package: "GQLOperationsGuest"),
                .product(name: "Models", package: "Models"),
                .product(name: "TokenKeychainManager", package: "TokenKeychainManager"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

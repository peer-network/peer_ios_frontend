// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteConfig",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RemoteConfig",
            targets: ["RemoteConfig"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.9.0"))
    ],
    targets: [
        .target(
            name: "RemoteConfig",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

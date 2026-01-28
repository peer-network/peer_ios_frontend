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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.1.0"))
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCoreExtension", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreInternalWrapper", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

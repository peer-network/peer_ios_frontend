// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedNew",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeedNew",
            targets: ["FeedNew"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../DesignSystem"),
        .package(name: "Environment", path: "../Environment"),
        .package(name: "Networking", path: "../Networking"),
        .package(name: "GQLOperationsUser", path: "../GQLOperationsUser"),
        .package(name: "Post", path: "../Post"),
        .package(name: "FeedList", path: "../FeedList"),
        .package(name: "Analytics", path: "../Analytics"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.1.0")),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.8.0"))
    ],
    targets: [
        .target(
            name: "FeedNew",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "GQLOperationsUser", package: "GQLOperationsUser"),
                .product(name: "Post", package: "Post"),
                .product(name: "FeedList", package: "FeedList"),
                .product(name: "Analytics", package: "Analytics"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "NukeUI", package: "Nuke")
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

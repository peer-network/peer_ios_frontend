// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chat",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Chat",
            targets: ["Chat"]
        )
    ],
    
    dependencies: [
            .package(name: "DesignSystem", path: "../DesignSystem"), // Optional if using buttons, fonts, etc.
            .package(name: "Networking", path: "../Networking"),     // Optional if integrating chat API later
            .package(name: "Environment", path: "../Environment") ,   // Optional if using env configuration
            .package(name: "FeedNew", path: "../FeedNew"),
            .package(name: "FeedList", path: "../FeedList"),
            .package(name: "Analytics", path: "../Analytics"),
            .package(name: "ProfileNew", path: "../ProfileNew")
    ],
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Networking", package: "Networking"),
                .product(name: "Environment", package: "Environment"),
                .product(name: "FeedNew", package: "FeedNew"),
                .product(name: "FeedList", package: "FeedList"),
                .product(name: "ProfileNew", package: "ProfileNew")
            ]
           // path: "Sources/Chat/Views"
        )
    ],
    swiftLanguageModes: [.v5]
)


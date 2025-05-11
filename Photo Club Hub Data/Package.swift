// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Photo Club Hub Data",
    defaultLocalization: .english,
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Photo Club Hub Data",
            targets: ["Photo Club Hub Data"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Photo Club Hub Data",
            dependencies: [.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2")]
        ),
        .testTarget(
            name: "Photo Club Hub DataTests",
            dependencies: ["Photo Club Hub Data"]
        )
    ]
)

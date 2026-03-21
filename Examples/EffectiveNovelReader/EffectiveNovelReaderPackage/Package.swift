// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EffectiveNovelReaderPackage",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EffectiveNovelReaderPackage",
            targets: ["EffectiveNovelReaderPackage"])
    ],
    dependencies: [
        .package(path: "../../..")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EffectiveNovelReaderPackage",
            dependencies: [.product(name: "EffectiveNovelCore", package: "EffectiveNovelCore")]),
        .testTarget(
            name: "EffectiveNovelReaderPackageTests",
            dependencies: ["EffectiveNovelReaderPackage"])
    ]
)

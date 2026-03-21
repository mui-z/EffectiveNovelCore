// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "EffectiveNovelCLI",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "EffectiveNovelCLI", targets: ["EffectiveNovelCLI"])
  ],
  dependencies: [
    .package(path: "../..")
  ],
  targets: [
    .executableTarget(
      name: "EffectiveNovelCLI",
      dependencies: [.product(name: "EffectiveNovelCore", package: "EffectiveNovelCore")]
    )
  ]
)

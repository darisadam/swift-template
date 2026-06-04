// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Modules",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .visionOS(.v1),
    .watchOS(.v10)
  ],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "CounterFeature", targets: ["CounterFeature"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    .library(name: "SharedModels", targets: ["SharedModels"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.15.0"
    )
  ],
  targets: [
    .target(
      name: "SharedModels",
      path: "SharedModels/Sources"
    ),

    .target(
      name: "CounterFeature",
      dependencies: [
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "CounterFeature/Sources"
    ),
    .testTarget(
      name: "CounterFeatureTests",
      dependencies: [
        "CounterFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "CounterFeature/Tests"
    ),

    .target(
      name: "SettingsFeature",
      dependencies: [
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "SettingsFeature/Sources"
    ),
    .testTarget(
      name: "SettingsFeatureTests",
      dependencies: [
        "SettingsFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "SettingsFeature/Tests"
    ),

    .target(
      name: "AppFeature",
      dependencies: [
        "CounterFeature",
        "SettingsFeature",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "AppFeature/Sources"
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        "AppFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      path: "AppFeature/Tests"
    )
  ],
  swiftLanguageModes: [.v6]
)

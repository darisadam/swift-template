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
    // Core
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "CommonUI", targets: ["CommonUI"]),
    .library(name: "CoreNavigation", targets: ["CoreNavigation"]),
    // Features
    .library(name: "HomeFeature", targets: ["HomeFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"])
  ],
  dependencies: [
    // Add external dependencies here. Example:
    // .package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.0"),
  ],
  targets: [
    // MARK: - Core

    .target(
      name: "AppCore",
      path: "Core/AppCore/Sources"
    ),
    .target(
      name: "CommonUI",
      dependencies: ["AppCore"],
      path: "Core/CommonUI/Sources"
    ),
    .target(
      name: "CoreNavigation",
      dependencies: ["AppCore"],
      path: "Core/CoreNavigation/Sources"
    ),

    // MARK: - Features

    .target(
      name: "HomeFeature",
      dependencies: [
        "AppCore",
        "CommonUI",
        "CoreNavigation"
      ],
      path: "Features/HomeFeature/Sources"
    ),
    .testTarget(
      name: "HomeFeatureTests",
      dependencies: ["HomeFeature"],
      path: "Features/HomeFeature/Tests"
    ),

    .target(
      name: "ProfileFeature",
      dependencies: [
        "AppCore",
        "CommonUI",
        "CoreNavigation"
      ],
      path: "Features/ProfileFeature/Sources"
    ),
    .testTarget(
      name: "ProfileFeatureTests",
      dependencies: ["ProfileFeature"],
      path: "Features/ProfileFeature/Tests"
    )
  ],
  swiftLanguageModes: [.v6]
)

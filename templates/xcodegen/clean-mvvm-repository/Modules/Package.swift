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
    .library(name: "CoreNetwork", targets: ["CoreNetwork"]),
    .library(name: "CorePersistence", targets: ["CorePersistence"]),
    .library(name: "CoreKeychain", targets: ["CoreKeychain"]),

    // Feature umbrellas (presentation entry points)
    .library(name: "HomeFeature", targets: ["HomeFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"])
  ],
  dependencies: [
    // Add external dependencies here. Example:
    // .package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.0"),
  ],
  targets: [
    // MARK: - Core

    .target(name: "AppCore", path: "Core/AppCore/Sources"),
    .target(name: "CommonUI", dependencies: ["AppCore"], path: "Core/CommonUI/Sources"),
    .target(name: "CoreNavigation", dependencies: ["AppCore"], path: "Core/CoreNavigation/Sources"),
    .target(name: "CoreNetwork", dependencies: ["AppCore"], path: "Core/CoreNetwork/Sources"),
    .target(name: "CorePersistence", dependencies: ["AppCore"], path: "Core/CorePersistence/Sources"),
    .target(name: "CoreKeychain", dependencies: ["AppCore"], path: "Core/CoreKeychain/Sources"),

    // MARK: - HomeFeature (Domain → Data → Presentation)

    .target(
      name: "HomeFeatureDomain",
      dependencies: ["AppCore"],
      path: "Features/HomeFeature/Domain"
    ),
    .target(
      name: "HomeFeatureData",
      dependencies: [
        "AppCore",
        "CoreNetwork",
        "CorePersistence",
        "HomeFeatureDomain"
      ],
      path: "Features/HomeFeature/Data"
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        "AppCore",
        "CommonUI",
        "CoreNavigation",
        "HomeFeatureDomain",
        "HomeFeatureData"
      ],
      path: "Features/HomeFeature/Presentation"
    ),
    .testTarget(
      name: "HomeFeatureTests",
      dependencies: [
        "HomeFeature",
        "HomeFeatureDomain",
        "HomeFeatureData"
      ],
      path: "Features/HomeFeature/Tests"
    ),

    // MARK: - ProfileFeature

    .target(
      name: "ProfileFeatureDomain",
      dependencies: ["AppCore"],
      path: "Features/ProfileFeature/Domain"
    ),
    .target(
      name: "ProfileFeatureData",
      dependencies: [
        "AppCore",
        "CoreKeychain",
        "CorePersistence",
        "ProfileFeatureDomain"
      ],
      path: "Features/ProfileFeature/Data"
    ),
    .target(
      name: "ProfileFeature",
      dependencies: [
        "AppCore",
        "CommonUI",
        "CoreNavigation",
        "ProfileFeatureDomain",
        "ProfileFeatureData"
      ],
      path: "Features/ProfileFeature/Presentation"
    ),
    .testTarget(
      name: "ProfileFeatureTests",
      dependencies: [
        "ProfileFeature",
        "ProfileFeatureDomain",
        "ProfileFeatureData"
      ],
      path: "Features/ProfileFeature/Tests"
    )
  ],
  swiftLanguageModes: [.v6]
)

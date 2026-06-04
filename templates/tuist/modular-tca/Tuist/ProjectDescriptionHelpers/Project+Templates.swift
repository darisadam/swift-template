//
//  Project+Templates.swift
//  ProjectDescriptionHelpers
//

import Foundation
import ProjectDescription

public extension DeploymentTargets {
  static func multiplatform(
    iOS: String = "__DEPLOYMENT_TARGET__",
    macOS: String? = nil,
    watchOS: String? = nil,
    visionOS: String? = nil
  ) -> DeploymentTargets {
    .multiplatform(iOS: iOS, macOS: macOS, watchOS: watchOS, tvOS: nil, visionOS: visionOS)
  }
}

public extension Project {
  static func module(
    _ module: Module,
    destinations: Destinations = [.iPhone, .iPad],
    deploymentTargets: DeploymentTargets = .multiplatform(),
    dependencies: [TargetDependency] = []
  ) -> Project {
    Project(
      name: module.targetName,
      organizationName: "__ORG_NAME__",
      settings: .settings(
        base: [
          "SWIFT_STRICT_CONCURRENCY": "complete",
          "SWIFT_VERSION": "__SWIFT_VERSION__"
        ]
      ),
      targets: [
        .target(
          name: module.targetName,
          destinations: destinations,
          product: .framework,
          bundleId: module.bundleId,
          deploymentTargets: deploymentTargets,
          sources: ["Sources/**"],
          dependencies: dependencies
        ),
        .target(
          name: "\(module.targetName)Tests",
          destinations: destinations,
          product: .unitTests,
          bundleId: "\(module.bundleId).tests",
          deploymentTargets: deploymentTargets,
          sources: ["Tests/**"],
          dependencies: [.target(name: module.targetName)]
        )
      ]
    )
  }

  static func app(
    name: String,
    bundleId: String,
    destinations: Destinations = [.iPhone, .iPad],
    deploymentTargets: DeploymentTargets = .multiplatform(),
    dependencies: [TargetDependency] = []
  ) -> Project {
    Project(
      name: name,
      organizationName: "__ORG_NAME__",
      settings: .settings(
        base: [
          "SWIFT_STRICT_CONCURRENCY": "complete",
          "SWIFT_VERSION": "__SWIFT_VERSION__",
          "CURRENT_PROJECT_VERSION": "1",
          "MARKETING_VERSION": "1.0.0"
        ]
      ),
      targets: [
        .target(
          name: name,
          destinations: destinations,
          product: .app,
          bundleId: bundleId,
          deploymentTargets: deploymentTargets,
          infoPlist: .extendingDefault(with: [
            "CFBundleDisplayName": .string(name),
            "UIApplicationSceneManifest": ["UIApplicationSupportsMultipleScenes": false]
          ]),
          sources: ["App/Sources/**"],
          resources: ["App/Resources/**"],
          dependencies: dependencies
        ),
        .target(
          name: "\(name)Tests",
          destinations: destinations,
          product: .unitTests,
          bundleId: "\(bundleId).tests",
          deploymentTargets: deploymentTargets,
          sources: ["__APP_NAME__Tests/**"],
          dependencies: [.target(name: name)]
        ),
        .target(
          name: "\(name)UITests",
          destinations: destinations,
          product: .uiTests,
          bundleId: "\(bundleId).uitests",
          deploymentTargets: deploymentTargets,
          sources: ["__APP_NAME__UITests/**"],
          dependencies: [.target(name: name)]
        )
      ]
    )
  }
}

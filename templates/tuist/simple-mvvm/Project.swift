//
//  Project.swift
//  __APP_NAME__
//

import ProjectDescription

let project = Project(
  name: "__APP_NAME__",
  organizationName: "__ORG_NAME__",
  settings: .settings(
    base: [
      "SWIFT_STRICT_CONCURRENCY": "complete",
      "SWIFT_VERSION": "__SWIFT_VERSION__",
      "ENABLE_USER_SCRIPT_SANDBOXING": "YES"
    ]
  ),
  targets: [
    .target(
      name: "__APP_NAME__",
      destinations: [.iPhone, .iPad],
      // Uncomment to add platforms:
      // destinations: [.iPhone, .iPad, .mac, .appleVision],
      product: .app,
      bundleId: "__BUNDLE_ID__",
      deploymentTargets: .iOS("__DEPLOYMENT_TARGET__"),
      infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "__APP_NAME__",
        "UIApplicationSceneManifest": [
          "UIApplicationSupportsMultipleScenes": false
        ]
      ]),
      sources: ["App/Sources/**"],
      resources: ["App/Resources/**"],
      dependencies: []
    ),
    .target(
      name: "__APP_NAME__Tests",
      destinations: [.iPhone, .iPad],
      product: .unitTests,
      bundleId: "__BUNDLE_ID__.tests",
      deploymentTargets: .iOS("__DEPLOYMENT_TARGET__"),
      sources: ["__APP_NAME__Tests/**"],
      dependencies: [.target(name: "__APP_NAME__")]
    ),
    .target(
      name: "__APP_NAME__UITests",
      destinations: [.iPhone, .iPad],
      product: .uiTests,
      bundleId: "__BUNDLE_ID__.uitests",
      deploymentTargets: .iOS("__DEPLOYMENT_TARGET__"),
      sources: ["__APP_NAME__UITests/**"],
      dependencies: [.target(name: "__APP_NAME__")]
    )
  ]
)

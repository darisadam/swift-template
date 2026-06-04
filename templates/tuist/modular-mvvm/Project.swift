//
//  Project.swift
//  __APP_NAME__
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
  name: "__APP_NAME__",
  bundleId: "__BUNDLE_ID__",
  destinations: [.iPhone, .iPad],
  // For multi-platform, swap to:
  // destinations: [.iPhone, .iPad, .mac, .appleVision],
  // deploymentTargets: .multiplatform(iOS: "__DEPLOYMENT_TARGET__", macOS: "14.0", visionOS: "1.0"),
  dependencies: [
    // Core modules
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
    .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)),
    .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path)),
    // Feature modules
    .project(target: Module.home.targetName, path: .relativeToRoot(Module.home.path)),
    .project(target: Module.profile.targetName, path: .relativeToRoot(Module.profile.path))
  ]
)

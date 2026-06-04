//
//  Project.swift
//  __APP_NAME__
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
  name: "__APP_NAME__",
  bundleId: "__BUNDLE_ID__",
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
    .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)),
    .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path)),
    .project(target: Module.coreNetwork.targetName, path: .relativeToRoot(Module.coreNetwork.path)),
    .project(target: Module.coreKeychain.targetName, path: .relativeToRoot(Module.coreKeychain.path)),
    .project(target: Module.home.targetName, path: .relativeToRoot(Module.home.path)),
    .project(target: Module.profile.targetName, path: .relativeToRoot(Module.profile.path))
  ]
)

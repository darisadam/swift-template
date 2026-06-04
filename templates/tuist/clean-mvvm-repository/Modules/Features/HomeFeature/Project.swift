//
//  Project.swift
//  HomeFeature
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .home,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
    .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)),
    .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path)),
    .project(target: Module.coreNetwork.targetName, path: .relativeToRoot(Module.coreNetwork.path))
  ]
)

//
//  Project.swift
//  ProfileFeature
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .profile,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
    .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)),
    .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path))
  ]
)

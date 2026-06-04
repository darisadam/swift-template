//
//  Project.swift
//  CoreNavigation
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .coreNavigation,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
)

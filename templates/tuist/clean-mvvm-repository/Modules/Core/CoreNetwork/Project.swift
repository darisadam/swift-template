//
//  Project.swift
//  CoreNetwork
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .coreNetwork,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
)

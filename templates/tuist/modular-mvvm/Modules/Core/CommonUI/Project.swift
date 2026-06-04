//
//  Project.swift
//  CommonUI
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .commonUI,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
)

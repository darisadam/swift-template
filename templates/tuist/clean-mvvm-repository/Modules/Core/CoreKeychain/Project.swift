//
//  Project.swift
//  CoreKeychain
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .coreKeychain,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
)

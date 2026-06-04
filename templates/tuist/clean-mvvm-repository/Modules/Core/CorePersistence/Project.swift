//
//  Project.swift
//  CorePersistence
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .corePersistence,
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
)

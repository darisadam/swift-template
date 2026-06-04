//
//  Project.swift
//  CounterFeature
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .counterFeature,
  dependencies: [
    .project(target: Module.sharedModels.targetName, path: .relativeToRoot(Module.sharedModels.path)),
    .external(name: "ComposableArchitecture")
  ]
)

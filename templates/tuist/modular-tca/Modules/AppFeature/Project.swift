//
//  Project.swift
//  AppFeature
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .appFeature,
  dependencies: [
    .project(target: Module.sharedModels.targetName, path: .relativeToRoot(Module.sharedModels.path)),
    .project(target: Module.counterFeature.targetName, path: .relativeToRoot(Module.counterFeature.path)),
    .project(target: Module.settingsFeature.targetName, path: .relativeToRoot(Module.settingsFeature.path)),
    .external(name: "ComposableArchitecture")
  ]
)

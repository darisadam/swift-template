//
//  Project.swift
//  SettingsFeature
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  .settingsFeature,
  dependencies: [
    .project(target: Module.sharedModels.targetName, path: .relativeToRoot(Module.sharedModels.path)),
    .external(name: "ComposableArchitecture")
  ]
)

//
//  Project.swift
//  __APP_NAME__
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
  name: "__APP_NAME__",
  bundleId: "__BUNDLE_ID__",
  dependencies: [
    .project(target: Module.appFeature.targetName, path: .relativeToRoot(Module.appFeature.path)),
    .external(name: "ComposableArchitecture")
  ]
)

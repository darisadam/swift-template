//
//  Module.swift
//  ProjectDescriptionHelpers
//

import Foundation
import ProjectDescription

public enum Module: String, CaseIterable {
  case sharedModels = "SharedModels"
  case counterFeature = "CounterFeature"
  case settingsFeature = "SettingsFeature"
  case appFeature = "AppFeature"

  public var targetName: String { rawValue }
  public var path: String { "Modules/\(rawValue)" }
  public var bundleId: String { "__BUNDLE_ID__.\(rawValue.lowercased())" }
}

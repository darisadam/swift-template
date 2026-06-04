//
//  Module.swift
//  ProjectDescriptionHelpers
//
//  Central registry of every Tuist module in the workspace. Adding a new
//  module is a two-step change: add a case here, then add a `.project(target:)`
//  reference wherever it should be consumed.
//

import Foundation
import ProjectDescription

public enum Module: String, CaseIterable {
  // Core
  case appCore = "AppCore"
  case commonUI = "CommonUI"
  case coreNavigation = "CoreNavigation"

  // Features
  case home = "HomeFeature"
  case profile = "ProfileFeature"

  public var targetName: String { rawValue }

  public var path: String {
    switch self {
    case .appCore, .commonUI, .coreNavigation:
      "Modules/Core/\(rawValue)"
    case .home, .profile:
      "Modules/Features/\(rawValue)"
    }
  }

  public var bundleId: String {
    "__BUNDLE_ID__.\(rawValue.lowercased())"
  }
}

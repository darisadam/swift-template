//
//  Module.swift
//  ProjectDescriptionHelpers
//

import Foundation
import ProjectDescription

public enum Module: String, CaseIterable {
  // Core
  case appCore = "AppCore"
  case commonUI = "CommonUI"
  case coreNavigation = "CoreNavigation"
  case coreNetwork = "CoreNetwork"
  case coreKeychain = "CoreKeychain"
  case corePersistence = "CorePersistence"

  // Features
  case home = "HomeFeature"
  case profile = "ProfileFeature"

  public var targetName: String { rawValue }

  public var path: String {
    switch self {
    case .appCore, .commonUI, .coreNavigation, .coreNetwork, .coreKeychain, .corePersistence:
      "Modules/Core/\(rawValue)"
    case .home, .profile:
      "Modules/Features/\(rawValue)"
    }
  }

  public var bundleId: String {
    "__BUNDLE_ID__.\(rawValue.lowercased())"
  }
}

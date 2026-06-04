//
//  AppTab.swift
//  SharedModels
//

import Foundation

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
  case counter
  case settings

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .counter: "Counter"
    case .settings: "Settings"
    }
  }

  public var systemImage: String {
    switch self {
    case .counter: "plus.forwardslash.minus"
    case .settings: "gearshape.fill"
    }
  }
}

//
//  AppRoute.swift
//  CoreNavigation
//

import Foundation

public enum AppTab: String, CaseIterable, Identifiable, Sendable {
  case home
  case profile

  public var id: String { rawValue }

  public var title: String {
    switch self {
    case .home: "Home"
    case .profile: "Profile"
    }
  }

  public var systemImage: String {
    switch self {
    case .home: "house.fill"
    case .profile: "person.fill"
    }
  }
}

public enum AppRoute: Hashable, Sendable {
  case homeDetail(id: String)
  case profileSettings
}

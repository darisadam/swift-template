//
//  AppRouter.swift
//  CoreNavigation
//

import Foundation
import Observation
import SwiftUI

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

@Observable
@MainActor
public final class AppRouter {
  public var selectedTab: AppTab = .home
  public var homePath = NavigationPath()
  public var profilePath = NavigationPath()

  public init() {}

  public func push(_ route: AppRoute, on tab: AppTab) {
    switch tab {
    case .home: homePath.append(route)
    case .profile: profilePath.append(route)
    }
  }
}

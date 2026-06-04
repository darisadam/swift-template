//
//  AppRouter.swift
//  CoreNavigation
//

import Foundation
import Observation
import SwiftUI

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

  public func pop(on tab: AppTab) {
    switch tab {
    case .home:
      if !homePath.isEmpty { homePath.removeLast() }
    case .profile:
      if !profilePath.isEmpty { profilePath.removeLast() }
    }
  }

  public func popToRoot(on tab: AppTab) {
    switch tab {
    case .home: homePath = NavigationPath()
    case .profile: profilePath = NavigationPath()
    }
  }
}

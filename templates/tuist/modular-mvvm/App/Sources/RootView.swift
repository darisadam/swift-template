//
//  RootView.swift
//  __APP_NAME__
//

import CoreNavigation
import HomeFeature
import ProfileFeature
import SwiftUI

struct RootView: View {
  @Environment(AppRouter.self) private var router

  var body: some View {
    @Bindable var router = router

    TabView(selection: $router.selectedTab) {
      NavigationStack(path: $router.homePath) {
        HomeView()
          .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .homeDetail(let id):
              HomeDetailView(itemID: id)
            case .profileSettings:
              EmptyView()
            }
          }
      }
      .tabItem { Label("Home", systemImage: "house.fill") }
      .tag(AppTab.home)

      NavigationStack(path: $router.profilePath) {
        ProfileView()
      }
      .tabItem { Label("Profile", systemImage: "person.fill") }
      .tag(AppTab.profile)
    }
  }
}

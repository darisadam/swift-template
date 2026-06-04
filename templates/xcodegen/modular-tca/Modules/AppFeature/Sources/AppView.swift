//
//  AppView.swift
//  AppFeature
//

import ComposableArchitecture
import CounterFeature
import SettingsFeature
import SharedModels
import SwiftUI

public struct AppView: View {
  @Bindable public var store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
      NavigationStack {
        CounterView(store: store.scope(state: \.counter, action: \.counter))
      }
      .tabItem { Label(AppTab.counter.title, systemImage: AppTab.counter.systemImage) }
      .tag(AppTab.counter)

      NavigationStack {
        SettingsView(store: store.scope(state: \.settings, action: \.settings))
      }
      .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
      .tag(AppTab.settings)
    }
  }
}

//
//  SettingsView.swift
//  SettingsFeature
//

import ComposableArchitecture
import SwiftUI

public struct SettingsView: View {
  @Bindable public var store: StoreOf<SettingsFeature>

  public init(store: StoreOf<SettingsFeature>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section("Account") {
        TextField("Display name", text: $store.displayName)
      }
    }
    .navigationTitle("Settings")
  }
}

//
//  __APP_NAME__App.swift
//  __APP_NAME__
//

import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct __APP_NAME__App: App {
  private let store = Store(initialState: AppFeature.State()) {
    AppFeature()
      ._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}

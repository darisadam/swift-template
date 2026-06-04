//
//  __APP_NAME__App.swift
//  __APP_NAME__
//

import CoreNavigation
import SwiftUI

@main
struct __APP_NAME__App: App {
  @State private var router = AppRouter()
  private let composer = AppComposer()

  var body: some Scene {
    WindowGroup {
      RootView(composer: composer)
        .environment(router)
    }
  }
}

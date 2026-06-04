//
//  RootView.swift
//  __APP_NAME__
//

import SwiftUI

struct RootView: View {
  var body: some View {
    NavigationStack {
      CounterView()
        .navigationTitle("__APP_NAME__")
    }
  }
}

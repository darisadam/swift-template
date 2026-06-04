//
//  CounterView.swift
//  CounterFeature
//

import ComposableArchitecture
import SwiftUI

public struct CounterView: View {
  @Bindable public var store: StoreOf<CounterFeature>

  public init(store: StoreOf<CounterFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 24) {
      Text("\(store.count)")
        .font(.system(size: 72, weight: .bold, design: .rounded))
        .contentTransition(.numericText())
        .animation(.snappy, value: store.count)

      HStack(spacing: 16) {
        Button {
          store.send(.decrementTapped)
        } label: { Image(systemName: "minus.circle.fill").font(.largeTitle) }
          .disabled(store.isAtZero)

        Button("Reset") { store.send(.resetTapped) }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)

        Button {
          store.send(.incrementTapped)
        } label: { Image(systemName: "plus.circle.fill").font(.largeTitle) }
      }
    }
    .padding()
    .navigationTitle("Counter")
  }
}

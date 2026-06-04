//
//  CounterView.swift
//  __APP_NAME__
//

import SwiftUI

struct CounterView: View {
  @State private var viewModel = CounterViewModel()

  var body: some View {
    VStack(spacing: 24) {
      Text("\(viewModel.count)")
        .font(.system(size: 72, weight: .bold, design: .rounded))
        .contentTransition(.numericText())
        .animation(.snappy, value: viewModel.count)

      HStack(spacing: 16) {
        Button {
          viewModel.decrement()
        } label: {
          Image(systemName: "minus.circle.fill").font(.largeTitle)
        }
        .disabled(viewModel.isAtZero)

        Button("Reset") { viewModel.reset() }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)

        Button {
          viewModel.increment()
        } label: {
          Image(systemName: "plus.circle.fill").font(.largeTitle)
        }
      }
    }
    .padding()
  }
}

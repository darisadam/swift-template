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
          Label("Decrement", systemImage: "minus.circle.fill")
            .labelStyle(.iconOnly)
            .font(.largeTitle)
        }
        .disabled(viewModel.isAtZero)

        Button {
          viewModel.reset()
        } label: {
          Text("Reset")
            .frame(minWidth: 80)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

        Button {
          viewModel.increment()
        } label: {
          Label("Increment", systemImage: "plus.circle.fill")
            .labelStyle(.iconOnly)
            .font(.largeTitle)
        }
      }
    }
    .padding()
  }
}

#Preview {
  CounterView()
}

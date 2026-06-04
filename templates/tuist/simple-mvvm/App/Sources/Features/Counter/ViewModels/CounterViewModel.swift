//
//  CounterViewModel.swift
//  __APP_NAME__
//

import Foundation
import Observation

@Observable
@MainActor
final class CounterViewModel {
  private(set) var count: Int = 0

  var isAtZero: Bool { count == 0 }

  func increment() { count += 1 }
  func decrement() {
    guard count > 0 else { return }
    count -= 1
  }
  func reset() { count = 0 }
}

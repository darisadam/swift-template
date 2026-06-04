//
//  CounterFeatureTests.swift
//  CounterFeatureTests
//

import ComposableArchitecture
@testable import CounterFeature
import XCTest

@MainActor
final class CounterFeatureTests: XCTestCase {
  func testIncrement() async {
    let store = TestStore(initialState: CounterFeature.State()) { CounterFeature() }
    await store.send(.incrementTapped) { $0.count = 1 }
  }

  func testDecrement_atZero() async {
    let store = TestStore(initialState: CounterFeature.State()) { CounterFeature() }
    await store.send(.decrementTapped)
  }

  func testDecrement_aboveZero() async {
    let store = TestStore(initialState: CounterFeature.State(count: 3)) { CounterFeature() }
    await store.send(.decrementTapped) { $0.count = 2 }
  }

  func testReset() async {
    let store = TestStore(initialState: CounterFeature.State(count: 7)) { CounterFeature() }
    await store.send(.resetTapped) { $0.count = 0 }
  }
}

//
//  AppFeatureTests.swift
//  AppFeatureTests
//

@testable import AppFeature
import ComposableArchitecture
import SharedModels
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
  func testTabSelection() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }
    await store.send(.tabSelected(.settings)) { $0.selectedTab = .settings }
  }

  func testCounterAction_propagatesToChildState() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }
    await store.send(.counter(.incrementTapped)) {
      $0.counter.count = 1
    }
  }
}

//
//  SettingsFeatureTests.swift
//  SettingsFeatureTests
//

import ComposableArchitecture
@testable import SettingsFeature
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
  func testInitialState() async {
    let store = TestStore(initialState: SettingsFeature.State()) {
      SettingsFeature()
    }
    XCTAssertEqual(store.state.displayName, "Guest")
  }

  func testBinding_updatesDisplayName() async {
    let store = TestStore(initialState: SettingsFeature.State()) {
      SettingsFeature()
    }
    await store.send(.binding(.set(\.displayName, "Adam"))) {
      $0.displayName = "Adam"
    }
  }
}

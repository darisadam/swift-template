//
//  SettingsFeatureTests.swift
//  SettingsFeatureTests
//

import ComposableArchitecture
@testable import SettingsFeature
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
  func testBinding() async {
    let store = TestStore(initialState: SettingsFeature.State()) { SettingsFeature() }
    await store.send(.binding(.set(\.displayName, "Adam"))) {
      $0.displayName = "Adam"
    }
  }
}

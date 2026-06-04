//
//  SharedModelsTests.swift
//  SharedModelsTests
//

@testable import SharedModels
import XCTest

final class SharedModelsTests: XCTestCase {
  func testAppTab_hasTitleForEveryCase() {
    for tab in AppTab.allCases {
      XCTAssertFalse(tab.title.isEmpty)
      XCTAssertFalse(tab.systemImage.isEmpty)
    }
  }
}

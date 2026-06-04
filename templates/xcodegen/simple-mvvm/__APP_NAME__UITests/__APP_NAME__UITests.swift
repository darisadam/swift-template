//
//  __APP_NAME__UITests.swift
//  __APP_NAME__UITests
//

import XCTest

final class __APP_NAME__UITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testCounter_incrementsWhenTapped() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 2))
    app.buttons["Increment"].tap()
    XCTAssertTrue(app.staticTexts["1"].exists)
  }
}

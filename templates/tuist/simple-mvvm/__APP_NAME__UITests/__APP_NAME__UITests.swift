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
  func testApp_launches() throws {
    let app = XCUIApplication()
    app.launch()
    XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 3))
  }
}

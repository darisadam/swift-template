//
//  AppCoreTests.swift
//  AppCoreTests
//

@testable import AppCore
import XCTest

final class AppCoreTests: XCTestCase {
  func testAppConstants_areSet() {
    XCTAssertFalse(AppConstants.appName.isEmpty)
    XCTAssertFalse(AppConstants.bundleID.isEmpty)
  }
}

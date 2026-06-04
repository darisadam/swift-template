//
//  CommonUITests.swift
//  CommonUITests
//

@testable import CommonUI
import XCTest

final class CommonUITests: XCTestCase {
  func testSpacing_isMonotonic() {
    XCTAssertLessThan(Spacing.xs, Spacing.xl)
  }
}

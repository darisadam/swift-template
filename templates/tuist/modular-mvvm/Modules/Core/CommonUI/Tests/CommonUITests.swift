//
//  CommonUITests.swift
//  CommonUITests
//

@testable import CommonUI
import XCTest

final class CommonUITests: XCTestCase {
  func testSpacingScale_isMonotonic() {
    XCTAssertLessThan(Spacing.xs, Spacing.sm)
    XCTAssertLessThan(Spacing.sm, Spacing.md)
    XCTAssertLessThan(Spacing.md, Spacing.lg)
    XCTAssertLessThan(Spacing.lg, Spacing.xl)
  }
}

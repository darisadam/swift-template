//
//  AppCoreTests.swift
//  AppCoreTests
//

@testable import AppCore
import XCTest

final class AppCoreTests: XCTestCase {
  func testAppError_localizedDescription() {
    XCTAssertEqual(AppError.notFound.localizedDescription, "Not found")
    XCTAssertEqual(AppError.unauthorized.localizedDescription, "Unauthorized")
  }
}

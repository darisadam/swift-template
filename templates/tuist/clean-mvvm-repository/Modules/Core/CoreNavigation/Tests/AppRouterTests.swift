//
//  AppRouterTests.swift
//  CoreNavigationTests
//

@testable import CoreNavigation
import XCTest

@MainActor
final class AppRouterTests: XCTestCase {
  func testInitialState() {
    let sut = AppRouter()
    XCTAssertEqual(sut.selectedTab, .home)
    XCTAssertTrue(sut.homePath.isEmpty)
  }
}

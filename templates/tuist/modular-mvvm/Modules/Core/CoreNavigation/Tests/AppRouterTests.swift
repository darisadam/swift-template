//
//  AppRouterTests.swift
//  CoreNavigationTests
//

@testable import CoreNavigation
import XCTest

@MainActor
final class AppRouterTests: XCTestCase {
  func testInitialState_homeTabSelected() {
    let sut = AppRouter()
    XCTAssertEqual(sut.selectedTab, .home)
  }

  func testPush_homeTab_growsHomePath() {
    let sut = AppRouter()
    XCTAssertTrue(sut.homePath.isEmpty)
    sut.push(.homeDetail(id: "1"), on: .home)
    XCTAssertEqual(sut.homePath.count, 1)
  }
}

//
//  HomeViewModelTests.swift
//  HomeFeatureTests
//

@testable import HomeFeature
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
  func testInitialState_isEmpty() {
    let sut = HomeViewModel()
    XCTAssertTrue(sut.items.isEmpty)
  }

  func testLoad_populates() async {
    let sut = HomeViewModel()
    await sut.load()
    XCTAssertEqual(sut.items.count, 5)
  }
}

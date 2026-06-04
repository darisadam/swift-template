//
//  HomeViewModelTests.swift
//  HomeFeatureTests
//

@testable import HomeFeature
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
  private var sut: HomeViewModel!

  override func setUp() async throws {
    try await super.setUp()
    sut = HomeViewModel()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testInitialState_isEmpty() {
    XCTAssertTrue(sut.items.isEmpty)
    XCTAssertFalse(sut.isLoading)
  }

  func testLoad_populatesItems() async {
    await sut.load()
    XCTAssertEqual(sut.items.count, 5)
    XCTAssertFalse(sut.isLoading)
  }
}

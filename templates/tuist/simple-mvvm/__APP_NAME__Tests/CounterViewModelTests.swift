//
//  CounterViewModelTests.swift
//  __APP_NAME__Tests
//

@testable import __APP_NAME__
import XCTest

@MainActor
final class CounterViewModelTests: XCTestCase {
  private var sut: CounterViewModel!

  override func setUp() async throws {
    try await super.setUp()
    sut = CounterViewModel()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testInitialState_isAtZero() {
    XCTAssertEqual(sut.count, 0)
    XCTAssertTrue(sut.isAtZero)
  }

  func testIncrement() {
    sut.increment()
    XCTAssertEqual(sut.count, 1)
  }

  func testDecrement_atZero_noChange() {
    sut.decrement()
    XCTAssertEqual(sut.count, 0)
  }

  func testReset() {
    sut.increment()
    sut.increment()
    sut.reset()
    XCTAssertEqual(sut.count, 0)
  }
}

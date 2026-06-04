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

  func testIncrement_incrementsByOne() {
    sut.increment()
    XCTAssertEqual(sut.count, 1)
    XCTAssertFalse(sut.isAtZero)
  }

  func testDecrement_atZero_doesNotGoNegative() {
    sut.decrement()
    XCTAssertEqual(sut.count, 0)
  }

  func testDecrement_aboveZero_decrementsByOne() {
    sut.increment()
    sut.increment()
    sut.decrement()
    XCTAssertEqual(sut.count, 1)
  }

  func testReset_setsCountToZero() {
    sut.increment()
    sut.increment()
    sut.reset()
    XCTAssertEqual(sut.count, 0)
  }
}

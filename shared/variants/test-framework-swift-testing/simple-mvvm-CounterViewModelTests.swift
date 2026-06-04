//
//  CounterViewModelTests.swift
//  __APP_NAME__Tests
//
//  Uses Apple's Swift Testing framework (Swift 6.0+).
//

@testable import __APP_NAME__
import Testing

@MainActor
struct CounterViewModelTests {
  @Test("initial state is zero")
  func initialState() {
    let sut = CounterViewModel()
    #expect(sut.count == 0)
    #expect(sut.isAtZero)
  }

  @Test("increment adds one")
  func increment() {
    let sut = CounterViewModel()
    sut.increment()
    #expect(sut.count == 1)
    #expect(!sut.isAtZero)
  }

  @Test("decrement at zero does not go negative")
  func decrementAtZero() {
    let sut = CounterViewModel()
    sut.decrement()
    #expect(sut.count == 0)
  }

  @Test("decrement above zero subtracts one")
  func decrementAboveZero() {
    let sut = CounterViewModel()
    sut.increment()
    sut.increment()
    sut.decrement()
    #expect(sut.count == 1)
  }

  @Test("reset returns to zero")
  func reset() {
    let sut = CounterViewModel()
    sut.increment()
    sut.increment()
    sut.reset()
    #expect(sut.count == 0)
  }

  @Test("multiple increments", arguments: [1, 5, 10, 100])
  func multipleIncrements(times: Int) {
    let sut = CounterViewModel()
    for _ in 1...times {
      sut.increment()
    }
    #expect(sut.count == times)
  }
}

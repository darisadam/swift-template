//
//  PersistenceControllerTests.swift
//  CorePersistenceTests
//

@testable import CorePersistence
import XCTest

@MainActor
final class PersistenceControllerTests: XCTestCase {
  func testInit_inMemory_succeeds() throws {
    _ = try PersistenceController(inMemory: true)
  }
}

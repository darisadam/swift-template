//
//  KeychainServiceTests.swift
//  CoreKeychainTests
//

@testable import CoreKeychain
import XCTest

final class KeychainServiceTests: XCTestCase {
  func testInit_succeeds() {
    _ = KeychainService(service: "test.service")
  }
}

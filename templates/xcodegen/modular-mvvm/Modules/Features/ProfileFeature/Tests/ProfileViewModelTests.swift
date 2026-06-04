//
//  ProfileViewModelTests.swift
//  ProfileFeatureTests
//

@testable import ProfileFeature
import XCTest

@MainActor
final class ProfileViewModelTests: XCTestCase {
  private var sut: ProfileViewModel!

  override func setUp() async throws {
    try await super.setUp()
    sut = ProfileViewModel()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testInitialState_isGuest() {
    XCTAssertEqual(sut.displayName, "Guest")
  }

  func testUpdate_validName_updates() {
    sut.updateDisplayName("Adam")
    XCTAssertEqual(sut.displayName, "Adam")
  }

  func testUpdate_blankName_keepsCurrent() {
    sut.updateDisplayName("   ")
    XCTAssertEqual(sut.displayName, "Guest")
  }
}

//
//  ProfileViewModelTests.swift
//  ProfileFeatureTests
//

@testable import ProfileFeature
import XCTest

@MainActor
final class ProfileViewModelTests: XCTestCase {
  func testInitialState() {
    let sut = ProfileViewModel()
    XCTAssertEqual(sut.displayName, "Guest")
  }

  func testUpdate_valid() {
    let sut = ProfileViewModel()
    sut.updateDisplayName("Adam")
    XCTAssertEqual(sut.displayName, "Adam")
  }

  func testUpdate_blank_keepsCurrent() {
    let sut = ProfileViewModel()
    sut.updateDisplayName("   ")
    XCTAssertEqual(sut.displayName, "Guest")
  }
}

//
//  ProfileViewModelTests.swift
//  ProfileFeatureTests
//

@testable import ProfileFeature
import XCTest

@MainActor
final class ProfileViewModelTests: XCTestCase {
  func testLoad_pullsFromRepository() async {
    let mock = MockProfileRepository()
    await mock.setStored(UserProfile(displayName: "Adam"))
    let sut = ProfileViewModel(repository: mock)
    await sut.load()
    XCTAssertEqual(sut.profile.displayName, "Adam")
  }

  func testUpdate_blank_doesNotSave() async {
    let mock = MockProfileRepository()
    let sut = ProfileViewModel(repository: mock)
    await sut.updateDisplayName("   ")
    let saved = await mock.lastSaved
    XCTAssertNil(saved)
  }

  func testUpdate_valid_savesAndUpdates() async {
    let mock = MockProfileRepository()
    let sut = ProfileViewModel(repository: mock)
    await sut.updateDisplayName("Bob")
    XCTAssertEqual(sut.profile.displayName, "Bob")
    let saved = await mock.lastSaved
    XCTAssertEqual(saved?.displayName, "Bob")
  }
}

private actor MockProfileRepository: ProfileRepositoryProtocol {
  private var stored: UserProfile = .guest
  private(set) var lastSaved: UserProfile?

  func setStored(_ profile: UserProfile) { stored = profile }
  func load() async throws -> UserProfile { stored }
  func save(_ profile: UserProfile) async throws {
    stored = profile
    lastSaved = profile
  }
}

//
//  ProfileViewModelTests.swift
//  ProfileFeatureTests
//

@testable import ProfileFeature
import ProfileFeatureDomain
import XCTest

@MainActor
final class ProfileViewModelTests: XCTestCase {
  private var sut: ProfileViewModel!
  private var mockRepository: MockProfileRepository!

  override func setUp() async throws {
    try await super.setUp()
    mockRepository = MockProfileRepository()
    sut = ProfileViewModel(repository: mockRepository)
  }

  override func tearDown() {
    sut = nil
    mockRepository = nil
    super.tearDown()
  }

  func testLoad_replacesProfileWithStored() async {
    await mockRepository.setStored(UserProfile(displayName: "Adam"))
    await sut.load()
    XCTAssertEqual(sut.profile.displayName, "Adam")
  }

  func testUpdate_validName_persistsAndUpdates() async {
    await sut.updateDisplayName("Bob")
    XCTAssertEqual(sut.profile.displayName, "Bob")
    let saved = await mockRepository.lastSaved
    XCTAssertEqual(saved?.displayName, "Bob")
  }

  func testUpdate_blankName_doesNotPersist() async {
    await sut.updateDisplayName("   ")
    let saved = await mockRepository.lastSaved
    XCTAssertNil(saved)
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

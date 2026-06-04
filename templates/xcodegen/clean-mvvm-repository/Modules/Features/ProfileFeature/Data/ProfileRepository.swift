//
//  ProfileRepository.swift
//  ProfileFeatureData
//
//  Stores the user profile in the Keychain. Easy to swap for a server-backed
//  implementation by introducing a new actor that conforms to
//  ProfileRepositoryProtocol — the Presentation layer doesn't change.
//

import AppCore
import CoreKeychain
import Foundation
import ProfileFeatureDomain

public actor ProfileRepository: ProfileRepositoryProtocol {
  private let keychain: KeychainServiceProtocol
  private let displayNameKey = "user.displayName"

  public init(keychain: KeychainServiceProtocol) {
    self.keychain = keychain
  }

  public func load() async throws -> UserProfile {
    let name = try await keychain.get(displayNameKey)
    return UserProfile(displayName: name ?? "Guest")
  }

  public func save(_ profile: UserProfile) async throws {
    try await keychain.set(profile.displayName, for: displayNameKey)
    AppLogger.data.info("Saved profile display name")
  }
}

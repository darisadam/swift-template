//
//  ProfileRepository.swift
//  ProfileFeature · Data layer
//

import AppCore
import CoreKeychain
import Foundation

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
    AppLogger.data.info("Saved profile")
  }
}

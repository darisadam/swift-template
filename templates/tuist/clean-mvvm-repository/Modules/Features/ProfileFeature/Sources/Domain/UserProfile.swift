//
//  UserProfile.swift
//  ProfileFeature · Domain layer
//

import Foundation

public struct UserProfile: Equatable, Sendable {
  public let displayName: String

  public init(displayName: String) {
    self.displayName = displayName
  }

  public static let guest = UserProfile(displayName: "Guest")
}

public protocol ProfileRepositoryProtocol: Sendable {
  func load() async throws -> UserProfile
  func save(_ profile: UserProfile) async throws
}

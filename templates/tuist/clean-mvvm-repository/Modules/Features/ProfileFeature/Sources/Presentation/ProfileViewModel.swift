//
//  ProfileViewModel.swift
//  ProfileFeature · Presentation layer
//

import AppCore
import Foundation
import Observation

@Observable
@MainActor
public final class ProfileViewModel {
  public private(set) var profile: UserProfile = .guest
  public private(set) var isSaving = false

  private let repository: ProfileRepositoryProtocol

  public init(repository: ProfileRepositoryProtocol) {
    self.repository = repository
  }

  public func load() async {
    do {
      profile = try await repository.load()
    } catch {
      AppLogger.ui.error("Profile load failed: \(error.localizedDescription)")
    }
  }

  public func updateDisplayName(_ newValue: String) async {
    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    isSaving = true
    defer { isSaving = false }
    let next = UserProfile(displayName: trimmed)
    do {
      try await repository.save(next)
      profile = next
    } catch {
      AppLogger.ui.error("Profile save failed: \(error.localizedDescription)")
    }
  }
}

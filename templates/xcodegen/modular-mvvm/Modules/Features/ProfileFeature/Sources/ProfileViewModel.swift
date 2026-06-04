//
//  ProfileViewModel.swift
//  ProfileFeature
//

import AppCore
import Foundation
import Observation

@Observable
@MainActor
public final class ProfileViewModel {
  public private(set) var displayName: String = "Guest"

  public init() {}

  public func updateDisplayName(_ newValue: String) {
    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    displayName = trimmed
    AppLogger.app.info("Profile name updated")
  }
}

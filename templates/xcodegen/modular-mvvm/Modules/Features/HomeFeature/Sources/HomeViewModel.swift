//
//  HomeViewModel.swift
//  HomeFeature
//

import AppCore
import Foundation
import Observation

@Observable
@MainActor
public final class HomeViewModel {
  public private(set) var items: [HomeItem] = []
  public private(set) var isLoading = false

  public init() {}

  public func load() async {
    isLoading = true
    defer { isLoading = false }
    // Simulated work — replace with a real data source.
    try? await Task.sleep(for: .milliseconds(300))
    items = (1...5).map { HomeItem(id: "item-\($0)", title: "Item \($0)") }
    AppLogger.app.info("HomeViewModel loaded \(self.items.count) items")
  }
}

public struct HomeItem: Identifiable, Hashable, Sendable {
  public let id: String
  public let title: String

  public init(id: String, title: String) {
    self.id = id
    self.title = title
  }
}

//
//  HomeItem.swift
//  HomeFeature · Domain layer
//

import Foundation

public struct HomeItem: Identifiable, Hashable, Sendable {
  public let id: String
  public let title: String
  public let createdAt: Date

  public init(id: String, title: String, createdAt: Date) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
  }
}

public protocol HomeRepositoryProtocol: Sendable {
  func fetchItems() async throws -> [HomeItem]
  func item(id: String) async throws -> HomeItem
}

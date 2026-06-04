//
//  HomeItem.swift
//  HomeFeatureDomain
//
//  Pure domain entity. No Foundation/UI/network types in the public surface.
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

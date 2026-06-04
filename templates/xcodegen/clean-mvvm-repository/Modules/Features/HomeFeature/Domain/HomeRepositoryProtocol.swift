//
//  HomeRepositoryProtocol.swift
//  HomeFeatureDomain
//
//  Repository protocol lives in the Domain layer. The Data layer provides
//  the concrete implementation; the Presentation layer depends only on this
//  protocol (Dependency Inversion).
//

import Foundation

public protocol HomeRepositoryProtocol: Sendable {
  func fetchItems() async throws -> [HomeItem]
  func item(id: String) async throws -> HomeItem
}

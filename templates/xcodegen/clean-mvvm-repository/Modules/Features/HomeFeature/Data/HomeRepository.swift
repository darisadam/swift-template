//
//  HomeRepository.swift
//  HomeFeatureData
//
//  Concrete implementation of the domain's HomeRepositoryProtocol.
//  Talks to CoreNetwork; could equally talk to CorePersistence, a mock,
//  or both (cache-then-network).
//

import AppCore
import CoreNetwork
import Foundation
import HomeFeatureDomain

public actor HomeRepository: HomeRepositoryProtocol {
  private let httpClient: HTTPClientProtocol

  public init(httpClient: HTTPClientProtocol) {
    self.httpClient = httpClient
  }

  public func fetchItems() async throws -> [HomeItem] {
    // For the template scaffold we return seed data. In a real app, replace with:
    // let dtos = try await httpClient.get("/items", as: [HomeItemDTO].self)
    // return dtos.map { $0.toDomain() }
    AppLogger.data.info("HomeRepository.fetchItems (stub)")
    return (1...5).map { idx in
      HomeItem(
        id: "item-\(idx)",
        title: "Item \(idx)",
        createdAt: Date().addingTimeInterval(Double(-idx * 3_600))
      )
    }
  }

  public func item(id: String) async throws -> HomeItem {
    let items = try await fetchItems()
    guard let match = items.first(where: { $0.id == id }) else {
      throw AppError.notFound
    }
    return match
  }
}

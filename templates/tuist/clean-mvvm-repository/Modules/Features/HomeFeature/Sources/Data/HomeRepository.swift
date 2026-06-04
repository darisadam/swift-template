//
//  HomeRepository.swift
//  HomeFeature · Data layer
//

import AppCore
import CoreNetwork
import Foundation

public actor HomeRepository: HomeRepositoryProtocol {
  private let httpClient: HTTPClientProtocol

  public init(httpClient: HTTPClientProtocol) {
    self.httpClient = httpClient
  }

  public func fetchItems() async throws -> [HomeItem] {
    AppLogger.data.info("HomeRepository.fetchItems (stub)")
    // Replace with: try await httpClient.get("/items", as: [HomeItemDTO].self).map { $0.toDomain() }
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

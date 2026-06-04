//
//  FetchHomeItemsUseCase.swift
//  HomeFeature · Domain layer
//

import Foundation

public protocol FetchHomeItemsUseCaseProtocol: Sendable {
  func execute() async throws -> [HomeItem]
}

public struct FetchHomeItemsUseCase: FetchHomeItemsUseCaseProtocol {
  private let repository: HomeRepositoryProtocol

  public init(repository: HomeRepositoryProtocol) {
    self.repository = repository
  }

  public func execute() async throws -> [HomeItem] {
    let items = try await repository.fetchItems()
    return items.sorted { $0.createdAt > $1.createdAt }
  }
}

//
//  FetchHomeItemsUseCase.swift
//  HomeFeatureDomain
//
//  Use cases encapsulate single, named business operations. ViewModels invoke
//  use cases, not repositories directly — this keeps presentation thin and
//  testable.
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

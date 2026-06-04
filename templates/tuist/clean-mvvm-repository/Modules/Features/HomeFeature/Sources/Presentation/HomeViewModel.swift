//
//  HomeViewModel.swift
//  HomeFeature · Presentation layer
//

import AppCore
import Foundation
import Observation

@Observable
@MainActor
public final class HomeViewModel {
  public enum State: Sendable {
    case idle
    case loading
    case loaded([HomeItem])
    case failure(String)
  }

  public private(set) var state: State = .idle

  private let fetchItems: FetchHomeItemsUseCaseProtocol

  public init(fetchItems: FetchHomeItemsUseCaseProtocol) {
    self.fetchItems = fetchItems
  }

  public func load() async {
    state = .loading
    do {
      let items = try await fetchItems.execute()
      state = .loaded(items)
    } catch {
      state = .failure(error.localizedDescription)
    }
  }
}

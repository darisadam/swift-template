//
//  HomeViewModelTests.swift
//  HomeFeatureTests
//

@testable import HomeFeature
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
  func testInitialState() {
    let sut = HomeViewModel(fetchItems: MockFetchHomeItemsUseCase())
    if case .idle = sut.state { return }
    XCTFail("Expected idle, got \(sut.state)")
  }

  func testLoad_success() async {
    let mock = MockFetchHomeItemsUseCase()
    mock.result = .success([HomeItem(id: "1", title: "One", createdAt: Date())])
    let sut = HomeViewModel(fetchItems: mock)
    await sut.load()
    if case .loaded(let items) = sut.state { XCTAssertEqual(items.count, 1); return }
    XCTFail("Expected loaded, got \(sut.state)")
  }

  func testLoad_failure() async {
    let mock = MockFetchHomeItemsUseCase()
    mock.result = .failure(MockError.boom)
    let sut = HomeViewModel(fetchItems: mock)
    await sut.load()
    if case .failure = sut.state { return }
    XCTFail("Expected failure, got \(sut.state)")
  }
}

private enum MockError: Error { case boom }

private final class MockFetchHomeItemsUseCase: FetchHomeItemsUseCaseProtocol, @unchecked Sendable {
  var result: Result<[HomeItem], Error> = .success([])
  func execute() async throws -> [HomeItem] { try result.get() }
}

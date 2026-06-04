//
//  HomeViewModelTests.swift
//  HomeFeatureTests
//

@testable import HomeFeature
import HomeFeatureDomain
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
  private var sut: HomeViewModel!
  private var mockUseCase: MockFetchHomeItemsUseCase!

  override func setUp() async throws {
    try await super.setUp()
    mockUseCase = MockFetchHomeItemsUseCase()
    sut = HomeViewModel(fetchItems: mockUseCase)
  }

  override func tearDown() {
    sut = nil
    mockUseCase = nil
    super.tearDown()
  }

  func testInitialState_isIdle() {
    if case .idle = sut.state { return }
    XCTFail("Expected idle, got \(sut.state)")
  }

  func testLoad_success_emitsLoaded() async {
    mockUseCase.result = .success([
      HomeItem(id: "1", title: "One", createdAt: Date())
    ])
    await sut.load()
    if case .loaded(let items) = sut.state {
      XCTAssertEqual(items.count, 1)
    } else {
      XCTFail("Expected loaded, got \(sut.state)")
    }
  }

  func testLoad_failure_emitsFailure() async {
    mockUseCase.result = .failure(SampleError.boom)
    await sut.load()
    if case .failure = sut.state { return }
    XCTFail("Expected failure, got \(sut.state)")
  }
}

private enum SampleError: Error { case boom }

private final class MockFetchHomeItemsUseCase: FetchHomeItemsUseCaseProtocol, @unchecked Sendable {
  var result: Result<[HomeItem], Error> = .success([])

  func execute() async throws -> [HomeItem] {
    try result.get()
  }
}

//
//  AppComposer.swift
//  __APP_NAME__
//
//  Composition root: wires concrete implementations to protocols.
//  This is the ONLY place that knows about all layers — every other module
//  depends only on its allowed dependencies.
//

import CoreKeychain
import CoreNetwork
import Foundation
import HomeFeature
import HomeFeatureData
import HomeFeatureDomain
import ProfileFeature
import ProfileFeatureData
import ProfileFeatureDomain

@MainActor
final class AppComposer {
  // Singletons live here. Repositories are actors so they're already isolated.
  private let httpClient: HTTPClientProtocol
  private let keychain: KeychainServiceProtocol

  private let homeRepository: HomeRepositoryProtocol
  private let profileRepository: ProfileRepositoryProtocol

  init() {
    httpClient = HTTPClient(baseURL: Self.defaultBaseURL)
    keychain = KeychainService()
    homeRepository = HomeRepository(httpClient: httpClient)
    profileRepository = ProfileRepository(keychain: keychain)
  }

  // Constant URL is validated at decode time. If the string is malformed
  // we fall back to a sentinel rather than crashing.
  private static let defaultBaseURL: URL = {
    URL(string: "https://api.example.com") ?? URL(filePath: "/")
  }()

  func makeHomeViewModel() -> HomeViewModel {
    let useCase = FetchHomeItemsUseCase(repository: homeRepository)
    return HomeViewModel(fetchItems: useCase)
  }

  func makeProfileViewModel() -> ProfileViewModel {
    ProfileViewModel(repository: profileRepository)
  }
}

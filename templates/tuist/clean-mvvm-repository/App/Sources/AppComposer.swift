//
//  AppComposer.swift
//  __APP_NAME__
//

import CoreKeychain
import CoreNetwork
import Foundation
import HomeFeature
import ProfileFeature

@MainActor
final class AppComposer {
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

  func makeHomeViewModel() -> HomeViewModel {
    HomeViewModel(fetchItems: FetchHomeItemsUseCase(repository: homeRepository))
  }

  func makeProfileViewModel() -> ProfileViewModel {
    ProfileViewModel(repository: profileRepository)
  }

  private static let defaultBaseURL: URL = {
    URL(string: "https://api.example.com") ?? URL(filePath: "/")
  }()
}

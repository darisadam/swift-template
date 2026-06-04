//
//  HomeView.swift
//  HomeFeature · Presentation layer
//

import CommonUI
import CoreNavigation
import SwiftUI

public struct HomeView: View {
  @State private var viewModel: HomeViewModel
  @Environment(AppRouter.self) private var router

  public init(viewModel: HomeViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  public var body: some View {
    Group {
      switch viewModel.state {
      case .idle, .loading: LoadingView()
      case .loaded(let items):
        List(items) { item in
          Button(item.title) {
            router.push(.homeDetail(id: item.id), on: .home)
          }
        }
      case .failure(let message):
        ErrorView(message) { Task { await viewModel.load() } }
      }
    }
    .task { await viewModel.load() }
    .navigationTitle("Home")
  }
}

public struct HomeDetailView: View {
  private let itemID: String

  public init(itemID: String) {
    self.itemID = itemID
  }

  public var body: some View {
    Text("Detail for \(itemID)")
      .font(.title)
      .padding(Spacing.lg)
      .navigationTitle("Detail")
  }
}

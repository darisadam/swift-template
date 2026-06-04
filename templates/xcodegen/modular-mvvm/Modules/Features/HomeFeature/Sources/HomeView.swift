//
//  HomeView.swift
//  HomeFeature
//

import CommonUI
import CoreNavigation
import SwiftUI

public struct HomeView: View {
  @State private var viewModel = HomeViewModel()
  @Environment(AppRouter.self) private var router

  public init() {}

  public var body: some View {
    Group {
      if viewModel.isLoading {
        ProgressView()
      } else {
        List(viewModel.items) { item in
          Button(item.title) {
            router.push(.homeDetail(id: item.id), on: .home)
          }
        }
      }
    }
    .task { await viewModel.load() }
    .navigationTitle("Home")
  }
}

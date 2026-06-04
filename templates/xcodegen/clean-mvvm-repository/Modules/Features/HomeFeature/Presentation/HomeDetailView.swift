//
//  HomeDetailView.swift
//  HomeFeature
//

import CommonUI
import SwiftUI

public struct HomeDetailView: View {
  private let itemID: String

  public init(itemID: String) {
    self.itemID = itemID
  }

  public var body: some View {
    VStack(spacing: Spacing.md) {
      Text("Detail for \(itemID)")
        .font(.title)
    }
    .padding()
    .navigationTitle("Detail")
  }
}

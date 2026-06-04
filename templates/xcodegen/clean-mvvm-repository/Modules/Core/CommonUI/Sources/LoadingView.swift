//
//  LoadingView.swift
//  CommonUI
//

import SwiftUI

public struct LoadingView: View {
  private let title: String

  public init(_ title: String = "Loading…") {
    self.title = title
  }

  public var body: some View {
    VStack(spacing: Spacing.md) {
      ProgressView()
        .controlSize(.large)
      Text(title)
        .foregroundStyle(.secondary)
    }
  }
}

public struct ErrorView: View {
  private let message: String
  private let retry: (() -> Void)?

  public init(_ message: String, retry: (() -> Void)? = nil) {
    self.message = message
    self.retry = retry
  }

  public var body: some View {
    VStack(spacing: Spacing.md) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.largeTitle)
        .foregroundStyle(.orange)
      Text(message)
        .multilineTextAlignment(.center)
      if let retry {
        Button("Retry", action: retry)
          .buttonStyle(.borderedProminent)
      }
    }
    .padding()
  }
}

//
//  DesignTokens.swift
//  CommonUI
//

import SwiftUI

public enum Spacing {
  public static let xs: CGFloat = 4
  public static let sm: CGFloat = 8
  public static let md: CGFloat = 16
  public static let lg: CGFloat = 24
  public static let xl: CGFloat = 32
}

public struct PrimaryButton: View {
  private let title: String
  private let action: () -> Void

  public init(_ title: String, action: @escaping () -> Void) {
    self.title = title
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
  }
}

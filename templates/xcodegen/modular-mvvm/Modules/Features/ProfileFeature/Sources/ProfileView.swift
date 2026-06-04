//
//  ProfileView.swift
//  ProfileFeature
//

import CommonUI
import SwiftUI

public struct ProfileView: View {
  @State private var viewModel = ProfileViewModel()
  @State private var editingName: String = ""

  public init() {}

  public var body: some View {
    Form {
      Section("Account") {
        LabeledContent("Display name", value: viewModel.displayName)
      }

      Section("Edit") {
        TextField("New name", text: $editingName)
        PrimaryButton("Save") {
          viewModel.updateDisplayName(editingName)
          editingName = ""
        }
      }
    }
    .navigationTitle("Profile")
  }
}

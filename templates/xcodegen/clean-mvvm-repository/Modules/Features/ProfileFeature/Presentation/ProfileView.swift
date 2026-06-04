//
//  ProfileView.swift
//  ProfileFeature
//

import CommonUI
import ProfileFeatureDomain
import SwiftUI

public struct ProfileView: View {
  @State private var viewModel: ProfileViewModel
  @State private var editingName: String = ""

  public init(viewModel: ProfileViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  public var body: some View {
    Form {
      Section("Account") {
        LabeledContent("Display name", value: viewModel.profile.displayName)
      }

      Section("Edit") {
        TextField("New name", text: $editingName)
        Button {
          Task {
            await viewModel.updateDisplayName(editingName)
            editingName = ""
          }
        } label: {
          if viewModel.isSaving {
            ProgressView()
          } else {
            Text("Save").frame(maxWidth: .infinity)
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isSaving)
      }
    }
    .navigationTitle("Profile")
    .task { await viewModel.load() }
  }
}

//
//  SettingsFeature.swift
//  SettingsFeature
//

import ComposableArchitecture
import Foundation

@Reducer
public struct SettingsFeature {
  @ObservableState
  public struct State: Equatable {
    public var displayName: String

    public init(displayName: String = "Guest") {
      self.displayName = displayName
    }
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
  }
}

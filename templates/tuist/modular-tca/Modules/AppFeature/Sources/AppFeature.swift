//
//  AppFeature.swift
//  AppFeature
//

import ComposableArchitecture
import CounterFeature
import Foundation
import SettingsFeature
import SharedModels

@Reducer
public struct AppFeature {
  @ObservableState
  public struct State: Equatable {
    public var selectedTab: AppTab = .counter
    public var counter = CounterFeature.State()
    public var settings = SettingsFeature.State()

    public init() {}
  }

  public enum Action {
    case tabSelected(AppTab)
    case counter(CounterFeature.Action)
    case settings(SettingsFeature.Action)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.counter, action: \.counter) { CounterFeature() }
    Scope(state: \.settings, action: \.settings) { SettingsFeature() }
    Reduce { state, action in
      switch action {
      case .tabSelected(let tab):
        state.selectedTab = tab
        return .none
      case .counter, .settings:
        return .none
      }
    }
  }
}

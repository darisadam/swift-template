//
//  CounterFeature.swift
//  CounterFeature
//

import ComposableArchitecture
import Foundation

@Reducer
public struct CounterFeature {
  @ObservableState
  public struct State: Equatable {
    public var count: Int

    public init(count: Int = 0) { self.count = count }
    public var isAtZero: Bool { count == 0 }
  }

  public enum Action: Equatable {
    case incrementTapped
    case decrementTapped
    case resetTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementTapped:
        state.count += 1
        return .none
      case .decrementTapped:
        guard state.count > 0 else { return .none }
        state.count -= 1
        return .none
      case .resetTapped:
        state.count = 0
        return .none
      }
    }
  }
}

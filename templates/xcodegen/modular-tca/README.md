# XcodeGen · Modular TCA

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA), by Point-Free, with each feature as its own SPM module. **Very different mental model from MVVM** — read on if you've never used TCA before.

Pick this when: you want every state change to be a testable value-type transformation, and you're comfortable investing in TCA's learning curve.

> 💡 What's TCA? `docs/architecture-decisions.md` (section #4-modular-tca) in the swift-template repo explains the big idea. Point-Free's [TCA documentation](https://pointfreeco.github.io/swift-composable-architecture/) is the canonical reference.

## What you see when you run it

`Cmd+R`. Two tabs:

- **Counter** — a counter screen with `−`, Reset, `+` buttons (same UI as Simple MVVM, very different code underneath).
- **Settings** — a Form with one TextField for display name (uses TCA's `BindableAction`).

The point of having both is to show **TCA's `Scope` composition**: a parent reducer (`AppFeature`) routes to two child reducers, each of which manages its own state slice.

## TCA's mental model in 60 seconds

In MVVM, your ViewModel is a class with methods. State changes happen ad-hoc inside methods.

In TCA, state is a plain **struct** (value type). State only ever changes inside a **reducer**, in response to a named **action**. The reducer is a pure function `(State, Action) -> Effect` — given the same state and action, the result is always identical.

```swift
@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable { var count = 0 }

  enum Action: Equatable { case incrementTapped, decrementTapped }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementTapped: state.count += 1; return .none
      case .decrementTapped: state.count -= 1; return .none
      }
    }
  }
}
```

Three things to internalize:

1. **State is a struct.** Never a class, never `@Observable`. Equality is value-equality.
2. **Actions are an enum.** Every user interaction, every async result, every navigation event is a case.
3. **The reducer is the only place state changes.** Views send actions; reducers update state.

Why bother? Because **every state change is now a pure function call you can test exhaustively**:

```swift
let store = TestStore(initialState: CounterFeature.State()) { CounterFeature() }
await store.send(.incrementTapped) { $0.count = 1 }   // ← the trailing closure asserts the state transition
```

If the count became 7 instead of 1, the test fails with a precise diff. **State bugs become impossible to hide.**

## Guided tour (the 7 places)

```
Modules/
├── Package.swift                                  # ← 1. Declares TCA via swift-composable-architecture
├── SharedModels/Sources/AppTab.swift              # ← 2. Cross-feature value types
├── CounterFeature/
│   ├── Sources/
│   │   ├── CounterFeature.swift                   # ← 3. @Reducer + State + Action + body
│   │   └── CounterView.swift                      # ← 4. SwiftUI view, consumes StoreOf<CounterFeature>
│   └── Tests/CounterFeatureTests.swift            # ← 5. TestStore-based tests
├── SettingsFeature/                               # same shape, demonstrates BindableAction
└── AppFeature/
    ├── Sources/
    │   ├── AppFeature.swift                       # ← 6. Root @Reducer composing children via `Scope`
    │   └── AppView.swift                          # TabView wiring child stores
    └── Tests/AppFeatureTests.swift
App/Sources/__APP_NAME__App.swift                  # ← 7. @main; builds the root Store and renders AppView
```

### The composition pattern

Open `Modules/AppFeature/Sources/AppFeature.swift`:

```swift
@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var selectedTab: AppTab = .counter
    var counter = CounterFeature.State()     // ← child state lives inside parent state
    var settings = SettingsFeature.State()
  }

  enum Action {
    case tabSelected(AppTab)
    case counter(CounterFeature.Action)      // ← child actions are wrapped in parent action
    case settings(SettingsFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.counter, action: \.counter) { CounterFeature() }
    Scope(state: \.settings, action: \.settings) { SettingsFeature() }
    Reduce { state, action in
      switch action {
      case .tabSelected(let tab): state.selectedTab = tab; return .none
      case .counter, .settings: return .none
      }
    }
  }
}
```

The `Scope` is the magic: it says "for actions with the `.counter` prefix, run the `CounterFeature` reducer on the `\.counter` slice of state." This is how features compose in TCA.

## Try this first (3 exercises)

### Exercise 1: Add a "double" action

1. In `Modules/CounterFeature/Sources/CounterFeature.swift`, add to the `Action` enum:
   ```swift
   case doubleTapped
   ```
2. Handle it in the `Reduce`:
   ```swift
   case .doubleTapped: state.count *= 2; return .none
   ```
3. In `CounterView.swift`, add a button: `Button("×2") { store.send(.doubleTapped) }`
4. Add a test:
   ```swift
   func testDouble() async {
     let store = TestStore(initialState: CounterFeature.State(count: 3)) { CounterFeature() }
     await store.send(.doubleTapped) { $0.count = 6 }
   }
   ```
5. `Cmd+U` to run tests, then `Cmd+R` to see the button.

### Exercise 2: Add an effect (async action)

Make `incrementTapped` wait 1 second before incrementing:

1. In `CounterFeature.swift`, change:
   ```swift
   case .incrementTapped:
     return .run { send in
       try await Task.sleep(for: .seconds(1))
       await send(.incrementCompleted)
     }
   case .incrementCompleted:
     state.count += 1
     return .none
   ```
   And add `case incrementCompleted` to the Action enum.
2. Tests now use `await store.receive(.incrementCompleted) { $0.count = 1 }`.

This shows how **effects** (async work) are explicit values in TCA, not hidden inside closures.

### Exercise 3: Add a third feature module

Mirror SettingsFeature — copy its `Sources/` and `Tests/` shape, add to `Package.swift`, then wire it into `AppFeature` with a new `Scope`.

## How to run

```bash
./setup.sh
open __APP_NAME__.xcodeproj
```

## Verification

```bash
swiftlint lint --fix --config .swiftlint.yml
swiftlint lint --config .swiftlint.yml

xcodebuild test \
  -project __APP_NAME__.xcodeproj \
  -scheme __APP_NAME__ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -skip-testing:__APP_NAME__UITests
```

## Adding a feature

1. `mkdir -p Modules/<Name>Feature/{Sources,Tests}`
2. Add a `.target` + `.testTarget` to `Modules/Package.swift`
3. Define `<Name>Feature` (`@Reducer` + State + Action) in `Sources/`
4. Build `<Name>View` consuming `StoreOf<<Name>Feature>`
5. Compose into `AppFeature`: add a state property + `Scope` in the body
6. Write a `TestStore`-based test in `Tests/`
7. `./setup.sh`

## Why no Factory / no Repository?

TCA replaces hand-rolled DI with `@Dependency` (TCA's built-in mechanism). Repositories become **dependency clients** — see Point-Free's docs for the canonical pattern. You don't add `Factory` to a TCA project.

## Adding more platforms

`Modules/Package.swift` already declares iOS, macOS, visionOS, and watchOS. Toggle the host target in `project.yml`. For multi-target apps (separate Watch app, etc.), prefer the **Tuist / Modular TCA** template.

# Tuist · Modular TCA

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA) with each feature as its own Tuist project. TCA itself is pulled in via `Tuist/Package.swift` as an external dependency. Same architecture as XcodeGen / Modular TCA, but each feature gets a full `.xcodeproj` instead of being one SPM library.

Pick this when: you want TCA *and* the production-grade module separation Tuist gives you.

> 💡 First time with TCA? Read `docs/architecture-decisions.md` (section #4-modular-tca) in the swift-template repo and [Point-Free's docs](https://pointfreeco.github.io/swift-composable-architecture/) first. The TCA-specific exercises in the XcodeGen / Modular TCA template README (in the swift-template repo) apply here too.

> 🎨 **SwiftUI only** — every template in this repo uses SwiftUI views, `@Observable` view models, and `async/await`. UIKit, Storyboards, and XIBs are not supported.

## What you see when you run it

`Cmd+R`. Two tabs:

- **Counter** — `−` Reset `+` buttons, count rendered above. Driven by `CounterFeature` reducer.
- **Settings** — A Form with a TextField. Uses TCA's `BindableAction` for two-way binding.

`AppFeature` (the root) composes both child features using TCA's `Scope` primitive.

## Guided tour (the 9 places)

```
Tuist.swift / Workspace.swift / Project.swift
Tuist/
├── Package.swift                                     # ← 1. Declares TCA as external dependency
└── ProjectDescriptionHelpers/
    ├── Module.swift                                  # ← 2. Module enum
    └── Project+Templates.swift
Modules/
├── SharedModels/                                     # ← 3. AppTab and cross-feature value types
├── CounterFeature/
│   ├── Project.swift                                 # ← 4. Declares dep on TCA via `.external(name:)`
│   ├── Sources/{CounterFeature.swift, CounterView.swift}
│   └── Tests/CounterFeatureTests.swift               # ← 5. TestStore-based
├── SettingsFeature/                                  # same shape (BindableAction example)
└── AppFeature/
    ├── Project.swift
    ├── Sources/{AppFeature.swift, AppView.swift}     # ← 6. Root reducer composing child features
    └── Tests/AppFeatureTests.swift
App/
├── Sources/__APP_NAME__App.swift                     # ← 7. Builds Store(initialState: …) { AppFeature() }
├── Tests/
└── UITests/
```

### Why is TCA in `Tuist/Package.swift` and not in module `Project.swift`s directly?

Tuist resolves external Swift packages once, via `tuist install`, and exposes them as `.external(name: "ComposableArchitecture")` dependencies in each module's `Project.swift`. This means:

- TCA gets compiled **once**, shared by every feature module
- `productTypes: ["ComposableArchitecture": .framework]` in `Tuist/Package.swift` keeps it as a dynamic framework (so no symbol duplication)
- Running `./setup.sh` does `tuist install && tuist generate` in one shot

If TCA isn't installed, run `./setup.sh` once.

## Try this first (3 exercises)

### Exercise 1: Add a "double" action

Same as the XcodeGen Modular TCA template — see those exercises in the swift-template repo's XcodeGen / Modular TCA template README.

### Exercise 2: Add a third feature module

1. Add to `Tuist/ProjectDescriptionHelpers/Module.swift`:
   ```swift
   case profile = "ProfileFeature"
   ```
2. Create `Modules/ProfileFeature/{Project.swift,Sources,Tests}/`
3. The `Project.swift`:
   ```swift
   import ProjectDescription
   import ProjectDescriptionHelpers

   let project = Project.module(
     .profile,
     dependencies: [
       .project(target: Module.sharedModels.targetName, path: .relativeToRoot(Module.sharedModels.path)),
       .external(name: "ComposableArchitecture")
     ]
   )
   ```
4. Add `ProfileFeature.swift` (`@Reducer`) and `ProfileView.swift`
5. Compose into `AppFeature` — add `var profile = ProfileFeature.State()`, `case profile(ProfileFeature.Action)`, and a `Scope(state: \.profile, action: \.profile) { ProfileFeature() }`
6. Add a third tab in `AppView`
7. Add to `Workspace.swift` and `AppFeature/Project.swift` dependencies
8. `./setup.sh`

### Exercise 3: Add a `@Dependency` (TCA's DI mechanism)

TCA's idiomatic alternative to Factory/Repository:

1. Add to `Modules/CounterFeature/Sources/`:
   ```swift
   import ComposableArchitecture

   struct CounterClient {
     var loadInitial: @Sendable () async -> Int
   }

   extension CounterClient: DependencyKey {
     static let liveValue = CounterClient(loadInitial: { 0 })
   }

   extension DependencyValues {
     var counter: CounterClient {
       get { self[CounterClient.self] }
       set { self[CounterClient.self] = newValue }
     }
   }
   ```
2. In `CounterFeature`:
   ```swift
   @Dependency(\.counter) var counter
   // ... use `counter.loadInitial()` from an effect
   ```
3. Override the dependency in tests:
   ```swift
   let store = TestStore(initialState: CounterFeature.State()) {
     CounterFeature()
   } withDependencies: {
     $0.counter.loadInitial = { 42 }
   }
   ```

This is how TCA replaces hand-rolled DI containers.

## How to run

```bash
./setup.sh                            # runs `tuist install` then `tuist generate`
open __APP_NAME__.xcworkspace
```

## Verification

```bash
swiftlint lint --fix --config .swiftlint.yml
swiftlint lint --config .swiftlint.yml

xcodebuild test \
  -workspace __APP_NAME__.xcworkspace \
  -scheme __APP_NAME__ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -skip-testing:__APP_NAME__UITests
```

## TCA gotchas in a Tuist project

- **TCA must be a framework**, not a static library, because multiple modules depend on it. That's what `productTypes: ["ComposableArchitecture": .framework]` does in `Tuist/Package.swift`.
- After bumping TCA's version in `Tuist/Package.swift`, re-run `tuist install`.
- If Xcode shows "No such module 'ComposableArchitecture'," you skipped `tuist install`. The `./setup.sh` script handles this for you.

## Adding more platforms

Edit each module's `Project.swift` destinations and `Tuist.swift` deployment targets. TCA itself supports iOS, macOS, watchOS, and tvOS — visionOS support arrived in TCA 1.8.

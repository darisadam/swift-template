# XcodeGen · Modular MVVM

Local Swift Package Manager (SPM) modules consumed by a single XcodeGen app target. Same MVVM pattern as Simple MVVM, but each feature lives in its own module so it can't accidentally reach into other features.

Pick this when you have 5+ features and want clear ownership boundaries without committing to Tuist.

> 💡 Don't know what "modules" or "SPM" mean? Read `docs/concepts.md` in the swift-template repo first.

## What you see when you run it

Hit `Cmd+R`. The Simulator opens with a **tab bar at the bottom** showing two tabs:

- **Home** — a list of 5 items. Tap an item to navigate to a detail screen.
- **Profile** — a form where you can edit a display name.

Two screens, two tabs, two feature modules. This is the smallest example that shows modular separation: `HomeFeature` and `ProfileFeature` don't import each other; both share a small `Core` of utilities.

## Guided tour (the 8 places you'll spend time)

```
Modules/
├── Package.swift                              # ← 1. All modules declared here
├── Core/
│   ├── AppCore/Sources/                       # ← 2. Logger, constants
│   ├── CommonUI/Sources/                      # ← 3. Design tokens, PrimaryButton
│   └── CoreNavigation/Sources/                # ← 4. AppRouter, AppRoute, AppTab
└── Features/
    ├── HomeFeature/                           # ← 5. The Home tab
    │   ├── Sources/{HomeViewModel.swift, HomeView.swift, HomeDetailView.swift}
    │   └── Tests/HomeViewModelTests.swift
    └── ProfileFeature/                        # ← 6. The Profile tab

App/
├── Sources/
│   ├── __APP_NAME__App.swift                  # ← 7. @main, injects AppRouter
│   └── RootView.swift                         # ← 8. The TabView that hosts both features
└── ...

project.yml                                    # XcodeGen config; pulls Modules/ as a package
```

1. **`Modules/Package.swift`** is the **single source of truth** for the module graph. To add a feature, you add a `.target(...)` and `.library(...)` here, then a folder under `Modules/Features/`.

2. **`Core/AppCore/`** holds tiny shared utilities (Logger, constants). Every module can depend on it.

3. **`Core/CommonUI/`** has design tokens (`Spacing.md`, etc.) and reusable views (`PrimaryButton`). Features import this for styling.

4. **`Core/CoreNavigation/`** owns the `AppRouter` (an `@Observable` class), the `AppRoute` enum (every navigable destination), and the `AppTab` enum. Features push routes onto the router; the App layer reads the router to navigate.

5. **`Features/HomeFeature/Sources/HomeViewModel.swift`** is a textbook MVVM ViewModel. Note it imports `AppCore` (logger) — that's allowed. It does **not** import `ProfileFeature` — that would be forbidden by the dependency rules.

6. **`Features/ProfileFeature/`** mirrors HomeFeature for the second tab.

7. **`App/Sources/__APP_NAME__App.swift`** is the `@main` entry. It creates `AppRouter` and injects it via `.environment(router)`.

8. **`App/Sources/RootView.swift`** is the `TabView` that wires `HomeFeature` and `ProfileFeature` together. **This is the only place in the codebase that knows about both features.**

## Dependency rules

```
App                  →  Core + Features
HomeFeature          →  AppCore, CommonUI, CoreNavigation
ProfileFeature       →  AppCore, CommonUI, CoreNavigation
CommonUI             →  AppCore
CoreNavigation       →  AppCore
AppCore              →  ∅
```

Features **never** depend on other Features. Core modules **never** depend on Features. This is enforced by SPM — if you try to violate it, the compiler refuses.

## Try this first (3 exercises)

### Exercise 1: Add an item count to the Home title

1. In `Modules/Features/HomeFeature/Sources/HomeView.swift`, change:
   ```swift
   .navigationTitle("Home")
   ```
   to:
   ```swift
   .navigationTitle("Home (\(viewModel.items.count))")
   ```
2. `Cmd+R`. Title now says "Home (5)".

### Exercise 2: Add a "logout" button to Profile

1. In `Modules/Features/ProfileFeature/Sources/ProfileViewModel.swift`, add:
   ```swift
   public func logout() {
     displayName = "Guest"
   }
   ```
2. In `ProfileView.swift`, add a button to the form:
   ```swift
   Section {
     Button("Log out", role: .destructive) {
       viewModel.logout()
     }
   }
   ```

### Exercise 3: Add a third feature module

1. Create `Modules/Features/SettingsFeature/{Sources,Tests}/`
2. In `Modules/Package.swift`, add:
   ```swift
   .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
   ```
   and
   ```swift
   .target(
     name: "SettingsFeature",
     dependencies: ["AppCore", "CommonUI", "CoreNavigation"],
     path: "Features/SettingsFeature/Sources"
   ),
   ```
3. Add `SettingsViewModel.swift` and `SettingsView.swift` under `Modules/Features/SettingsFeature/Sources/` (copy the shape from ProfileFeature)
4. In `project.yml`, add `- package: Modules` + `product: SettingsFeature` under the app target's dependencies
5. In `App/Sources/RootView.swift`, add a new `.tabItem` for Settings
6. `./setup.sh` to regenerate, then `Cmd+R`

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

## Adding more platforms

The SPM package already declares iOS / macOS / visionOS / watchOS. To enable a platform in the app, edit `project.yml`:

```yaml
targets.__APP_NAME__.supportedDestinations:
  - iOS
  - iPadOS
  - macOS
  - visionOS
```

Then `./setup.sh`. For separate Watch / Widget targets, see the **Tuist / Modular MVVM** template — Tuist handles multi-target apps more cleanly.

## When to upgrade to Clean Architecture

When your features start needing **multiple data sources** (network + cache + keychain) or you need to **swap implementations** for tests/previews. The Repository pattern in Clean Architecture is the answer to those problems.

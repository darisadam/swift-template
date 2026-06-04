# Tuist · Clean Architecture + MVVM + Repository

The full enchilada: **Tuist workspace** with per-module Xcode projects, and **per-feature Domain/Data/Presentation** layered subfolders. Same architecture as the XcodeGen Clean+MVVM+Repository template, but each module is its own real `.xcodeproj` (via Tuist), not an SPM library.

Pick this for medium-to-large iOS apps with strict architectural requirements.

> 💡 New to Clean Architecture? Read `docs/architecture-decisions.md` (section #3-clean-architecture--mvvm--repository) in the swift-template repo first.

> 🎨 **SwiftUI only** — every template in this repo uses SwiftUI views, `@Observable` view models, and `async/await`. UIKit, Storyboards, and XIBs are not supported.

## What you see when you run it

`Cmd+R`. Two tabs:

- **Home** — list of 5 items from a stubbed `HomeRepository`. Shape is real; swap the stub for an actual HTTP call.
- **Profile** — display name persisted to the iOS Keychain via a real `KeychainService`. Kill the app, relaunch — name persists.

Same flow as the XcodeGen Clean template. The difference is *structural*: each module is a full Xcode project.

## Difference vs the XcodeGen Clean template

| | XcodeGen / Clean | Tuist / Clean (this) |
|---|---|---|
| Modules | One SPM `Package.swift` with many targets | One `.xcodeproj` per module, all in a Tuist workspace |
| Domain/Data/Presentation | **Separate SPM targets** per layer | **Folders inside one module** (less compile-time enforcement) |
| Build speed | Single SPM build | Per-module caching via `tuist cache` |
| Xcode navigation | All targets show in one project | Each module is its own project (cleaner sidebar) |

The Tuist version sacrifices some compile-time enforcement of the Domain/Data split (they're folders inside one framework, not separate frameworks). The Discipline becomes a convention rather than a hard wall. In practice this is fine for most teams — the folder structure carries the meaning.

## Guided tour (the 10 places)

```
Tuist.swift / Workspace.swift / Project.swift
Tuist/ProjectDescriptionHelpers/{Module,Project+Templates}.swift  # ← Tuist plumbing
Modules/
├── Core/
│   ├── AppCore/{Project.swift,Sources,Tests}        # ← Logger, AppError
│   ├── CommonUI/                                    # ← Spacing, LoadingView, ErrorView
│   ├── CoreNavigation/                              # ← AppRouter, AppRoute
│   ├── CoreNetwork/                                 # ← HTTPClient (actor)
│   └── CoreKeychain/                                # ← KeychainService (actor)
└── Features/
    ├── HomeFeature/
    │   ├── Project.swift
    │   ├── Sources/
    │   │   ├── Domain/        # entities, repo protocols, use cases   ◄── layer 1
    │   │   ├── Data/          # DTOs, repo impls                       ◄── layer 2
    │   │   └── Presentation/  # ViewModel, View                        ◄── layer 3
    │   └── Tests/
    └── ProfileFeature/                              # same shape
App/
├── Sources/__APP_NAME__App.swift                    # @main
├── Sources/AppComposer.swift                        # ← THE COMPOSITION ROOT
├── Sources/RootView.swift                           # TabView
└── ...
```

Read `App/Sources/AppComposer.swift` carefully — it's the single place that knows about every layer. Everything else stays mockable.

## Try this first (3 exercises)

### Exercise 1: Swap the real Keychain for an in-memory store

1. In `Modules/Features/ProfileFeature/Sources/Data/`, add a new file `InMemoryKeychainService.swift`:
   ```swift
   import AppCore
   import CoreKeychain

   public actor InMemoryKeychainService: KeychainServiceProtocol {
     private var store: [String: String] = [:]
     public init() {}
     public func set(_ value: String, for key: String) throws { store[key] = value }
     public func get(_ key: String) throws -> String? { store[key] }
     public func delete(_ key: String) throws { store.removeValue(forKey: key) }
   }
   ```
2. In `App/Sources/AppComposer.swift`, replace `keychain = KeychainService()` with `keychain = InMemoryKeychainService()`
3. `Cmd+R`. Profile still works, but data is lost on app restart — because it's now backed by an in-memory dict instead of Keychain. **Same Presentation code, different implementation.**

### Exercise 2: Add a fake repo for previews

In `Modules/Features/HomeFeature/Sources/Presentation/HomeView.swift`, add at the bottom:

```swift
#Preview {
  final class StubRepo: HomeRepositoryProtocol {
    func fetchItems() async throws -> [HomeItem] {
      (1...3).map { HomeItem(id: "\($0)", title: "Preview \($0)", createdAt: .now) }
    }
    func item(id: String) async throws -> HomeItem { fatalError() }
  }
  return NavigationStack {
    HomeView(viewModel: HomeViewModel(fetchItems: FetchHomeItemsUseCase(repository: StubRepo())))
  }
  .environment(AppRouter())
}
```

Click "Resume" in Xcode's canvas — the preview shows three "Preview N" items, no network involved.

### Exercise 3: Add a Settings feature module

1. Add to `Tuist/ProjectDescriptionHelpers/Module.swift`: `case settings = "SettingsFeature"`
2. Create `Modules/Features/SettingsFeature/{Project.swift, Sources/{Domain,Data,Presentation}, Tests}/`
3. In its `Project.swift`:
   ```swift
   import ProjectDescription
   import ProjectDescriptionHelpers

   let project = Project.module(
     .settings,
     dependencies: [
       .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
       .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)),
       .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path))
     ]
   )
   ```
4. Add Domain entities, a repo, a ViewModel, a View (copy the Profile shape)
5. Add to `Workspace.swift` and root `Project.swift`
6. Register `makeSettingsViewModel()` in `AppComposer`
7. Wire into `RootView` as a third tab
8. `./setup.sh` to regenerate

## How to run

```bash
./setup.sh
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

## Adding more platforms

Edit `Project.swift` → `destinations` and `deploymentTargets`. Same Module enum works across all platforms — Tuist propagates destinations to every framework module automatically.

For Watch / Widget extensions, add new `.target(...)` entries in the root `Project.swift` — see `docs/adding-platforms.md` in the swift-template repo and the parrotalk-ios production project for examples.

## Testing rules

| Layer | What to mock |
|-------|--------------|
| ViewModel | Mock the use case protocol — fastest |
| Use case | Mock the repository protocol |
| Repository | Mock CoreNetwork / CoreKeychain |
| Domain entity | Nothing — pure value-type tests |

The only thing that ever sees a *real* HTTPClient is `AppComposer`.

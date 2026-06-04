# Tuist · Modular MVVM

Tuist workspace with **one `.xcodeproj` per module**, glued together by `Workspace.swift`. Same architecture and example as the XcodeGen Modular MVVM template, but each module is a full Xcode project (not an SPM library).

This is the recommended template for serious iOS apps. Modeled on the **parrotalk-ios** reference project (see swift-template repo) — a real production app shipping to iPhone/iPad/Watch/Mac/Vision Pro.

> 💡 New to Tuist or modular architecture? Read `docs/concepts.md` in the swift-template repo and `docs/architecture-decisions.md` in the swift-template repo first.

## What you see when you run it

`Cmd+R`. The Simulator shows a **tab bar** with:

- **Home** — a list of 5 items, tappable for a detail screen
- **Profile** — a form to edit a display name

The same flow as XcodeGen Modular MVVM. The difference is structural: each module compiles as its own framework, and Xcode shows you separate Xcode projects in the workspace's left sidebar.

## Guided tour (the 9 key places)

```
Tuist.swift                                          # ← 1. Toolchain pin
Workspace.swift                                      # ← 2. The workspace = root project + module projects
Project.swift                                        # ← 3. The app target only
Tuist/
└── ProjectDescriptionHelpers/
    ├── Module.swift                                 # ← 4. Enum of every module (single source of truth)
    └── Project+Templates.swift                      # ← 5. Project.app() + Project.module() factories
Modules/
├── Core/
│   ├── AppCore/{Project.swift,Sources,Tests}        # ← 6. Each module has its own Project.swift
│   ├── CommonUI/...
│   └── CoreNavigation/...
└── Features/
    ├── HomeFeature/...                              # ← 7. Feature with VM, View, Tests
    └── ProfileFeature/...
App/
├── Sources/__APP_NAME__App.swift                    # ← 8. @main + AppRouter injection
├── Sources/RootView.swift                           # ← 9. TabView wiring the two features
└── ...
```

1. **`Tuist.swift`** pins the Swift version for manifest generation.
2. **`Workspace.swift`** lists every project in the workspace. When you add a new module, you add it here too.
3. **`Project.swift`** is the **app** target only. The factories in `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` make it small.
4. **`Module.swift`** is **the** registry of module names, paths, and bundle IDs. Renaming a module starts here.
5. **`Project+Templates.swift`** defines `Project.app(...)` and `Project.module(...)` — reusable shapes so every module file is < 15 lines.
6. **Each Core module** has its own `Project.swift` calling `Project.module(.appCore)`. Tuist generates a real `.xcodeproj` for each, embedded in the workspace.
7. **Each Feature module** is the same pattern.
8. **App entry** creates `AppRouter()` and injects via `.environment(router)`.
9. **`RootView`** is the `TabView` and the *only* place that imports both features.

## Why per-module Xcode projects?

- Faster incremental builds — editing `HomeFeature` only recompiles `HomeFeature`
- `tuist focus HomeFeature` opens just that module's project (no need to load the full workspace)
- Easier signing — each module has its own bundle ID and provisioning
- Real Xcode project files mean you can `Cmd+Click` a symbol and Xcode navigates correctly across modules

## Dependency rules

```
App                  →  Core + Features
Feature*             →  AppCore, CommonUI, CoreNavigation
CommonUI             →  AppCore
CoreNavigation       →  AppCore
AppCore              →  ∅
```

Tuist will refuse to generate the project if you violate this — try having `HomeFeature` depend on `ProfileFeature` and see what happens.

## Try this first (3 exercises)

### Exercise 1: Rename a module

1. In `Tuist/ProjectDescriptionHelpers/Module.swift`, change the `home` case's raw value:
   ```swift
   case home = "FeedFeature"   // was "HomeFeature"
   ```
2. Rename `Modules/Features/HomeFeature/` to `Modules/Features/FeedFeature/`
3. Update imports: `find Modules App -name "*.swift" | xargs sed -i '' 's/HomeFeature/FeedFeature/g'`
4. `./setup.sh` to regenerate. **You just renamed a module with no `project.pbxproj` edits.**

### Exercise 2: Add a third feature module (Settings)

1. Add a case to `Module.swift`: `case settings = "SettingsFeature"`
2. Create `Modules/Features/SettingsFeature/{Project.swift,Sources,Tests}/`
3. The `Project.swift` is one line: `let project = Project.module(.settings, dependencies: [.project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)), .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path)), .project(target: Module.coreNavigation.targetName, path: .relativeToRoot(Module.coreNavigation.path))])`
4. Add `SettingsView.swift` with a simple Form
5. In `Workspace.swift`, add `"Modules/Features/SettingsFeature"` to `projects`
6. In root `Project.swift`, add the new module to the app's `dependencies`
7. In `App/Sources/RootView.swift`, add a `.tabItem` for Settings
8. `./setup.sh` and `Cmd+R`

### Exercise 3: Add an external dependency (Alamofire)

1. Create `Tuist/Package.swift`:
   ```swift
   // swift-tools-version: 6.0
   import PackageDescription

   let package = Package(
     name: "PackageName",
     dependencies: [
       .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0")
     ]
   )
   ```
2. In whatever module needs Alamofire (e.g., a future `CoreNetwork`), add `.external(name: "Alamofire")` to its `Project.swift` dependencies
3. `tuist install` (or just re-run `./setup.sh`)

## How to run

```bash
./setup.sh                            # installs Tuist, runs `tuist install` + `tuist generate`
open __APP_NAME__.xcworkspace
# then Cmd+R
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

Edit `Project.swift`:
```swift
destinations: [.iPhone, .iPad, .mac, .appleVision, .appleWatch]
deploymentTargets: .multiplatform(iOS: "17.0", macOS: "14.0", watchOS: "10.0", visionOS: "1.0")
```

For separate Watch / Widget extensions, add new `.target(...)` entries in `Project.swift` — see `docs/adding-platforms.md` in the swift-template repo for the full pattern (and look at parrotalk-ios for a production example).

## When to upgrade to Clean Architecture

When features need multiple data sources or rigorous swappable implementations. The Clean + MVVM + Repository template keeps the same module shell but adds Domain/Data/Presentation subfolders per feature.

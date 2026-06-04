# XcodeGen · Simple MVVM

A single-target SwiftUI app with `@Observable` view models. The smallest, easiest-to-read template. Pick this if you're learning iOS, building a prototype, or shipping something with < 5 screens.

> 💡 Don't know what XcodeGen, MVVM, or `@Observable` mean? Read `docs/concepts.md` in the swift-template repo first.

> 🎨 **SwiftUI only** — every template in this repo uses SwiftUI views, `@Observable` view models, and `async/await`. UIKit, Storyboards, and XIBs are not supported.

## What you see when you run it

Hit `Cmd+R` in Xcode. The iOS Simulator opens and you see:

- A big **`0`** in the middle of the screen
- Three buttons beneath: `−` (minus), `Reset`, `+` (plus)
- The title bar says your app name

Tap the buttons — the number goes up, down, or resets. That's it. **This is the simplest possible MVVM example.** Use it as a starting point to build out your own screens.

## Guided tour (5 files in 30 seconds)

1. **`App/Sources/App/__APP_NAME__App.swift`** — the `@main` entry point. Just creates a `RootView()`. Don't touch unless you need to wire in app-level state.

2. **`App/Sources/App/RootView.swift`** — the first screen the user sees. Currently just shows the `CounterView` wrapped in a `NavigationStack`. **This is where you'd swap in your own first screen.**

3. **`App/Sources/Features/Counter/ViewModels/CounterViewModel.swift`** — the *Model* and *ViewModel* in MVVM. Holds `count`, exposes `increment()`/`decrement()`/`reset()`. `@Observable` means SwiftUI auto-updates when `count` changes.

4. **`App/Sources/Features/Counter/Views/CounterView.swift`** — the SwiftUI view. Owns the `CounterViewModel` via `@State` and renders the buttons.

5. **`App/Tests/CounterViewModelTests.swift`** — unit tests for the ViewModel. Shows the Given/When/Then test pattern.

## Try this first (3 beginner exercises)

### Exercise 1: Add a "double" action

1. In `CounterViewModel.swift`, add a new method:
   ```swift
   func double() { count *= 2 }
   ```
2. In `CounterView.swift`, add a button (anywhere inside the `HStack`):
   ```swift
   Button("×2") { viewModel.double() }
     .buttonStyle(.bordered)
   ```
3. `Cmd+R`. Tap your new button. The count doubles.

### Exercise 2: Add a max value

Make the counter refuse to go above 10.

1. In `CounterViewModel.swift`, modify `increment()`:
   ```swift
   func increment() {
     guard count < 10 else { return }
     count += 1
   }
   ```
2. Add a test in `App/Tests/CounterViewModelTests.swift`:
   ```swift
   func testIncrement_atMax_doesNotGoAbove() {
     for _ in 1...20 { sut.increment() }
     XCTAssertEqual(sut.count, 10)
   }
   ```
3. Run tests: `Cmd+U` in Xcode. The new test should pass.

### Exercise 3: Add a second screen

1. Create `App/Sources/Features/Greeting/Views/GreetingView.swift`:
   ```swift
   import SwiftUI

   struct GreetingView: View {
     var body: some View {
       VStack { Text("Hello!").font(.largeTitle) }
         .navigationTitle("Greeting")
     }
   }
   ```
2. In `RootView.swift`, add a navigation link:
   ```swift
   NavigationLink("Say hello") { GreetingView() }
   ```
3. `Cmd+R`. Tap "Say hello" — you navigate to the new screen.

## Layout

```
App/
├── Sources/
│   ├── App/                  # App entry point + RootView
│   ├── Features/
│   │   └── Counter/
│   │       ├── Models/
│   │       ├── ViewModels/   # @Observable view models
│   │       └── Views/        # SwiftUI views
│   ├── Common/
│   │   ├── Logger/           # AppLogger (os.log)
│   │   └── Extensions/
│   └── Resources/
├── Tests/                    # XCTest unit tests
└── UITests/                  # XCUITest
project.yml                   # XcodeGen configuration
```

## How to run

```bash
./setup.sh                              # first time, or after pulling project.yml changes
open __APP_NAME__.xcodeproj
# then Cmd+R in Xcode
```

## Verification (what to run before committing)

```bash
swiftlint lint --fix --config .swiftlint.yml    # auto-fix style violations
swiftlint lint --config .swiftlint.yml          # should print 0 violations

xcodebuild test \
  -project __APP_NAME__.xcodeproj \
  -scheme __APP_NAME__ \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -skip-testing:__APP_NAME__UITests
```

## Adding a new feature

1. Create `App/Sources/Features/<Name>/{Models,ViewModels,Views}/`
2. Add `<Name>ViewModel` (`@Observable @MainActor`) and `<Name>View`
3. Wire it into `RootView` (or whatever your navigation parent is)
4. Add `<Name>ViewModelTests.swift` to `App/Tests/`
5. You **don't** need to re-run `./setup.sh` — sources are auto-discovered. Only re-run if you change `project.yml`.

## Adding more platforms

```bash
ios-template add-platform --in . --platform visionos
```

Or edit `project.yml` → `targets.__APP_NAME__.supportedDestinations` manually:

```yaml
supportedDestinations:
  - iOS
  - iPadOS
  - macOS         # native Mac
  - macCatalyst   # iPad app, Mac chrome
  - visionOS
```

Then `xcodegen generate`.

> For Apple Watch or Widget extensions, you'll want **Modular MVVM** or **Clean Architecture** instead — separate targets get unwieldy in a single-target project.

## When to upgrade to a heavier template

You'll know it's time to move to **Modular MVVM** when:

- `App/Sources/Features/` has more than ~10 folders
- Build times start to feel slow
- Two devs keep stepping on each other's changes to `RootView` or `Info.plist`

Until then, you're fine here.

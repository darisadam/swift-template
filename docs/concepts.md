# Concepts & glossary

This is a plain-language reference for every iOS term that shows up in this repo. **You do not need to know this all at once.** Skim it once, then come back when a word looks unfamiliar.

If you're brand-new to iOS, read [getting-started.md](getting-started.md) first — it walks you through the actual install + first project steps. This file just explains what the words mean.

---

## The tooling

### Xcode

Apple's **IDE** (Integrated Development Environment). Download it free from the Mac App Store. It's what compiles your Swift code, runs your app in a simulator, signs the app for the App Store, and edits storyboards. You install it once and every other iOS tool sits on top of it.

> Without Xcode installed, none of this works. It's macOS-only.

### `.xcodeproj` and `.xcworkspace`

`.xcodeproj` is the file Xcode opens to "see" your project. Internally it's a folder containing a giant text file called `project.pbxproj` that lists every source file, every build setting, and every target. **It's notoriously merge-hostile** — if two developers add a file at the same time and both push, you get conflicts that are painful to resolve.

`.xcworkspace` is a container that holds multiple `.xcodeproj`s (and Swift packages). When your app is split into modules, you usually open a `.xcworkspace` instead of a single `.xcodeproj`.

**Why this matters:** the templates here never want you to edit `project.pbxproj` directly. Instead, you describe your project in a more friendly format and a tool *generates* the `.xcodeproj` for you. That's what XcodeGen and Tuist are.

### Project generator

A tool that reads a small config file you write, and produces an `.xcodeproj`/`.xcworkspace` on demand. You commit the config; you `.gitignore` the generated `.xcodeproj`. No more merge conflicts.

- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** — config in YAML (`project.yml`). Simpler.
- **[Tuist](https://tuist.io)** — config in Swift (`Project.swift`). More powerful, better for big multi-module apps.

See [xcodegen-vs-tuist.md](xcodegen-vs-tuist.md) for the comparison.

### Swift Package Manager (SPM)

Apple's official **dependency manager** — it's how you pull in third-party libraries (like Alamofire, Lottie, the Composable Architecture). It also lets you split your own code into **local packages** (folders with a `Package.swift` manifest) that other code in your app can import.

XcodeGen templates use SPM to organize modules. Tuist usually doesn't need it for that, but you can still use it for external libraries.

### SwiftLint

A **linter**: it reads your Swift code and complains about style violations ("this line is too long," "don't force-unwrap optionals," "sort your imports"). The templates ship with a `.swiftlint.yml` config that enforces a "zero violations" policy.

Run it manually:
```bash
swiftlint lint --config .swiftlint.yml
swiftlint lint --fix --config .swiftlint.yml   # autofix what it can
```

### SwiftFormat

A code formatter (different from SwiftLint!). SwiftLint **complains**; SwiftFormat **rewrites** your code into a canonical layout (indentation, spacing, line wrapping). The templates ship with both.

### Homebrew

The standard macOS package manager. You install most dev tools with `brew install <name>`. The templates' `setup.sh` scripts use it to install SwiftLint and others if they're missing.

### mise

A version manager (like `nvm` for Node, `rbenv` for Ruby). It pins specific versions of dev tools so every developer on a team uses the same version. The templates ship a `mise.toml` that pins SwiftLint, Tuist, SwiftFormat, and `xcbeautify`.

### Xcode Command Line Tools

A subset of Xcode that ships the `xcodebuild` binary. Some workflows (CI, scripts) only need this, not the full Xcode app. Install with `xcode-select --install`.

---

## Building & running

### Target

A buildable thing inside a project. Common types:

- **App target** — the iOS app itself
- **Test target** — unit tests for the app (XCTest)
- **UI test target** — automated UI tests
- **Framework target** — a library (e.g., a `Modules/Features/HomeFeature`)
- **App extension target** — a Widget, Live Activity, iMessage extension, Watch app, etc.

When you read "the app's `Project.swift` declares 3 targets," it means the file describes the app, the unit tests, and the UI tests as 3 buildable units.

### Scheme

A way to run a target. Each target usually has a scheme that says "build with this configuration, then run with these arguments, optionally pre-attach the debugger." In Xcode, the scheme is what you pick in the dropdown at the top-left next to the Run button.

### Bundle ID

Your app's unique identifier across the Apple ecosystem, written in **reverse-DNS** style: `com.yourcompany.yourapp`. It's what the App Store, the user's device, Push Notifications, and code signing all use to know which app is which. You can't change it after launch without confusing users.

### Deployment target

The **minimum iOS version** your app supports. iOS 17.0 means "this app won't run on iOS 16 or older." Lower deployment targets reach more users but block you from newer APIs. iOS 17 / 18 is a reasonable modern default.

### Destinations / supported platforms

Apple platforms your app can run on. Each is a different SDK and (often) a different binary slice:

- **iOS** — iPhone
- **iPadOS** — iPad (mostly shares code with iOS)
- **macOS** — native Mac apps
- **macCatalyst** — iPad apps running on Mac (Mac chrome on iPad-style code)
- **visionOS** — Apple Vision Pro
- **watchOS** — Apple Watch (needs its own target — different runtime)

Templates default to iPhone + iPad. Adding more is one CLI command — see [adding-platforms.md](adding-platforms.md).

### Simulator

A macOS app that pretends to be an iPhone/iPad/Watch/Vision device so you can run your code without a physical device. Comes with Xcode. The `-destination` flag in `xcodebuild` commands picks which simulator to use.

```bash
xcodebuild test ... -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Code signing / provisioning profiles

For a real device (or the App Store), Apple requires every app to be cryptographically signed by an Apple developer account. The templates default to "Automatic" code signing so you don't have to deal with this until you ship.

---

## The Swift language bits

### SwiftUI

Apple's modern UI framework. You write your views as Swift structs (not storyboards). All template UI is SwiftUI.

```swift
struct HomeView: View {
  var body: some View {
    Text("Hello, world!")
  }
}
```

### `@Observable` and `@MainActor`

Swift 6's data-binding macro. You annotate a class with `@Observable` and any property change automatically updates UI that's reading it. `@MainActor` says "this class only runs on the main thread" (which UI code must).

```swift
@Observable
@MainActor
final class CounterViewModel {
  var count = 0   // SwiftUI views auto-update when this changes
  func increment() { count += 1 }
}
```

### `async`/`await` and structured concurrency

Swift's modern way to do asynchronous code (network calls, file I/O). Instead of completion handlers:

```swift
// Old style (don't do this)
fetchUser { user in ... }

// Modern style
let user = try await fetchUser()
```

The templates use `async`/`await` everywhere. **No `DispatchQueue`.**

### Actor

Swift's thread-safe object. You declare `actor MyService { }` and Swift guarantees that calls to its methods are serialized — no data races. Repositories in the Clean Architecture template are actors.

---

## Architecture patterns

These are *patterns for organizing your code*, not libraries you install. The templates pick one per project.

### MVVM (Model-View-ViewModel)

The most common iOS pattern. Three layers:

- **Model** — your domain data (`struct User { let name: String }`)
- **View** — the SwiftUI screen
- **ViewModel** — connects the two. Owns state, handles user actions, asks services to do work.

```swift
@Observable @MainActor
final class HomeViewModel {
  var items: [Item] = []
  func load() async { items = await repository.fetchItems() }
}

struct HomeView: View {
  @State private var vm = HomeViewModel()
  var body: some View {
    List(vm.items) { ... }.task { await vm.load() }
  }
}
```

### Clean Architecture

A way of slicing MVVM into **layers** with strict rules about which layer can talk to which:

```
Presentation  →  Domain  ←  Data
(View+VM)        (Pure)     (Network, DB)
```

- **Domain** has plain Swift types and *protocols* (interfaces). It depends on nothing.
- **Data** implements those protocols (the actual network call, the actual database query).
- **Presentation** (the ViewModel) depends only on Domain protocols, not on Data.

The win: you can swap a real network call for a fake in tests, or for a cache, without changing the ViewModel.

### Repository pattern

A specific Clean Architecture pattern. A **Repository** is a class (often an `actor`) that hides "where the data comes from" — could be the network, could be a local cache, could be both. The Domain layer says `protocol UserRepository { func fetch() async throws -> User }`; the Data layer provides a `class APIUserRepository: UserRepository`.

### TCA (The Composable Architecture)

A different approach, by [Point-Free](https://www.pointfree.co). Instead of ViewModels-with-mutable-state, you write **reducers**: pure functions that take the old state + an action and return the new state. Every state change is a value-type transformation, which makes them trivially testable.

```swift
@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable { var count = 0 }

  enum Action { case increment }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .increment: state.count += 1; return .none
      }
    }
  }
}
```

TCA is great for complex state machines. It has a steeper learning curve than MVVM.

### Module / modular

Splitting your app into multiple buildable units (SPM packages in XcodeGen, separate `.xcodeproj`s in Tuist). Benefits:

- **Faster incremental builds** — changing `HomeFeature` doesn't recompile `ProfileFeature`
- **Enforced boundaries** — `HomeFeature` literally cannot import private types from `ProfileFeature`
- **Parallel work** — different developers can own different modules

Cost: more files, more setup, harder for newcomers to navigate.

### Dependency Injection (DI)

A fancy phrase for "pass dependencies as constructor parameters instead of `MyService.shared`." Makes testing easy because you can pass mocks.

```swift
// ❌ Hard to test — hard-coded to the real network
class HomeViewModel {
  let repo = APIUserRepository()
}

// ✅ Easy to test — pass any repo, including a mock
class HomeViewModel {
  let repo: UserRepository
  init(repo: UserRepository) { self.repo = repo }
}
```

The "Composition Root" in the Clean Architecture templates is where all the real implementations get wired together (`App/Sources/AppComposer.swift`).

---

## CI / CD terms

### CI (Continuous Integration)

A bot that runs your tests on every push. The templates ship a GitHub Actions workflow at `.github/workflows/ci.yml` that does this automatically.

### `xcodebuild`

Apple's command-line build tool. Lives inside Xcode. The templates' test commands look like:

```bash
xcodebuild test \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -skip-testing:MyAppUITests
```

### `xcbeautify`

A tool that takes `xcodebuild`'s ugly verbose output and formats it into readable colored output. The CI workflow uses it.

---

## AI tooling files

### `CLAUDE.md`

A markdown file Claude (the AI from Anthropic) reads automatically when you ask it questions about your project. It tells Claude your conventions, your file structure, what to do, what not to do. Generated projects get a customized one.

### `AGENTS.md`

The same idea as `CLAUDE.md`, but for other AI agents (Codex, Aider, OpenAI Agents). Same content, different filename — a community convention.

### `.cursorrules`

A file the [Cursor](https://cursor.com) editor reads to customize its AI suggestions.

### `.claude/`

A folder Claude Code (Anthropic's CLI) reads for project-specific settings, custom slash commands, etc.

---

## Confused about something not on this list?

Open an issue or just ask. The point of this doc is to demystify the words — if a word in any other doc tripped you up, it belongs here.

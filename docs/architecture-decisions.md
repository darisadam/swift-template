# Picking an architecture

> 💡 New to these terms? Read [concepts.md](concepts.md) for plain-language definitions of MVVM, TCA, Clean Architecture, modules, etc. before diving in here.

## What's "an architecture" and why do I care?

A SwiftUI app needs answers to questions like:

- *Where does the app's state live?* (In the view? Outside the view? In a global thing?)
- *Who fetches data from the network?* (The view? A separate object?)
- *How do screens talk to each other?* (Direct calls? A router? Through state?)
- *What's testable?* (Just the logic, or also the UI?)

You can make these decisions ad-hoc per screen, but past a handful of screens your codebase becomes "spaghetti": every file knows about every other file, tests are impossible to write, and onboarding a new dev takes weeks.

**An architecture is a set of opinionated answers to those questions.** It tells you where each kind of code goes. The templates ship four of them. They're not a "ladder" you climb from beginner to expert — they're four different tools for different jobs.

## Quick chooser

If you don't want to read the whole doc, use this table:

| App size | State complexity | Team size | Pick |
|----------|------------------|-----------|------|
| < 5 screens, prototype | Low | 1–2 | **Simple MVVM** |
| 5–20 screens, multiple features | Low–medium | 1–5 | **Modular MVVM** |
| 10+ screens, multiple data sources | Medium–high | 3–10 | **Clean + MVVM + Repository** |
| Any size, state-driven, deterministic behavior is critical | High | Any | **Modular TCA** |

> Worried about picking wrong? Don't be — migration between architectures is straightforward (see the bottom of this doc).

---

## 1. Simple MVVM

### The big idea

Three layers per screen: **Model** (data), **View** (SwiftUI), **ViewModel** (logic + state). One Xcode target. No modules.

### What it looks like

```swift
// 1. Model — a plain Swift struct
struct Item: Identifiable { let id: String; let title: String }

// 2. ViewModel — holds state, exposes actions
@Observable @MainActor
final class HomeViewModel {
  private(set) var items: [Item] = []
  func load() async {
    items = (1...5).map { Item(id: "\($0)", title: "Item \($0)") }
  }
}

// 3. View — declarative SwiftUI; observes the ViewModel
struct HomeView: View {
  @State private var vm = HomeViewModel()
  var body: some View {
    List(vm.items) { Text($0.title) }
      .task { await vm.load() }
  }
}
```

### What you see in this template

One folder per feature under `App/Sources/Features/<Name>/`, with `Models/`, `ViewModels/`, `Views/` subfolders. The shipped example is a Counter screen.

### Pick when

- The app is a prototype, demo, or has < 5 screens
- You're learning iOS / SwiftUI and want to focus on Swift, not project plumbing
- You expect to throw away the codebase or fully rewrite it

### Cost of picking it

When the app grows past ~10 features, your `Features/` folder becomes hard to navigate, your Xcode build time climbs, and there's nothing stopping `HomeView` from importing `ProfileViewModel` directly (creating tight coupling). Migrating to Modular MVVM later is mechanical but real work.

---

## 2. Modular MVVM

### The big idea

Same MVVM pattern as above, but each feature lives in its **own buildable module** (SPM package or separate Xcode project). Modules can only see what their dependencies expose.

### Why "modules" change anything

When `HomeFeature` and `ProfileFeature` are separate modules, Swift literally won't let `HomeFeature` import a private type from `ProfileFeature`. That sounds annoying but it's a feature: **enforced boundaries** mean a new dev can't accidentally create spaghetti.

Bonus: changing one feature doesn't recompile the others. Big apps build dramatically faster.

### What it looks like (Tuist version)

```
Modules/
├── Core/
│   ├── AppCore/             # Logger, constants
│   ├── CommonUI/            # design tokens, reusable views
│   └── CoreNavigation/      # AppRouter, AppRoute enum
└── Features/
    ├── HomeFeature/         # ViewModels + Views
    └── ProfileFeature/      # ViewModels + Views

App/                         # composition root + RootView
```

Each module has its own `Project.swift` (Tuist) or its own entry in `Modules/Package.swift` (XcodeGen). The dependency direction is enforced:

```
App  →  Core + Features
Features  →  Core
Core  →  (nothing app-specific)
Features  ↛  Features          # forbidden
```

### Pick when

- 5+ features, multiple devs committing in parallel
- You want fast incremental builds
- You want module boundaries to teach new devs the right places to put code

### Cost of picking it

More plumbing per feature. Adding a screen now means: create the module folder, add a `Project.swift`/`Package.swift` entry, wire it into the app's deps. The CLI helps but it's not zero-cost. Navigation across modules requires a `CoreNavigation` module to share route types.

---

## 3. Clean Architecture + MVVM + Repository

### The big idea

Take Modular MVVM, then **slice every feature into three more layers**:

- **Domain** — pure Swift. Entities (`User`, `Item`) and *protocols* (`UserRepositoryProtocol`). Knows nothing about networks, databases, or UI.
- **Data** — implements those protocols. Knows about CoreNetwork, SwiftData, Keychain.
- **Presentation** — the ViewModel + View. Depends only on Domain protocols, never on Data.

### Why this is more than Modular MVVM

The crucial thing: the Presentation layer depends only on Domain *protocols*, not Data *implementations*. Which means:

```swift
// In Presentation, this is all you know:
let vm = HomeViewModel(repository: someUserRepository) // some UserRepositoryProtocol

// Test pass-through real impl in production
let real = APIUserRepository(client: httpClient)

// Pass a mock in unit tests
let mock = MockUserRepository(stubbed: [.fixture])

// Swap in a cached version later — Presentation layer doesn't change
let cached = CachedUserRepository(network: real, cache: db)
```

This is called **Dependency Inversion** — the high-level Presentation layer doesn't depend on the low-level Data layer; both depend on the abstract Domain protocols.

### What you see in this template

```
Modules/Features/HomeFeature/
├── Domain/                                  # Pure Swift, no imports beyond AppCore
│   ├── HomeItem.swift                       # entity
│   ├── HomeRepositoryProtocol.swift         # protocol
│   └── FetchHomeItemsUseCase.swift          # business operation
├── Data/                                    # Implementations
│   ├── HomeItemDTO.swift                    # wire format
│   └── HomeRepository.swift                 # actor, talks to HTTPClient
└── Presentation/                            # ViewModel + View
    ├── HomeViewModel.swift
    └── HomeView.swift
```

Plus core modules: `CoreNetwork`, `CoreKeychain`, `CorePersistence`, `CommonUI`, `CoreNavigation`.

And one place that knows about everything — the **Composition Root** at `App/Sources/AppComposer.swift`:

```swift
@MainActor
final class AppComposer {
  init() {
    httpClient = HTTPClient(baseURL: .default)
    homeRepository = HomeRepository(httpClient: httpClient)
    // …
  }

  func makeHomeViewModel() -> HomeViewModel {
    HomeViewModel(fetchItems: FetchHomeItemsUseCase(repository: homeRepository))
  }
}
```

### Pick when

- App has multiple data sources (network + cache + keychain + local persistence)
- You need to swap implementations (real, mock, fake-for-previews) frequently
- Tests are first-class and fast tests are mandatory
- Team is 3+ people with clear ownership boundaries

### Cost of picking it

A lot more files. Simple CRUD feels like ceremony (3 layers for what could be 1 method). The payoff shows up the moment you need to add caching, retry logic, offline support, or feature flags between the ViewModel and the data source — all of which become contained changes in the Data layer.

---

## 4. Modular TCA

### The big idea

Forget mutable-state ViewModels. Every feature is a **reducer**: a pure function `(State, Action) -> (State, Effect)`. State is a plain Swift value type; you can't mutate it from random places. Effects (network calls, timers) are explicit values.

### Why this is different from MVVM

In MVVM, the ViewModel is a class. It has methods. Methods can do anything to state at any time. That makes some bugs hard to find ("why is `count` 7 when the user only tapped twice?").

In TCA, state can only change inside the reducer, and only in response to a named action. Every state change is replayable, recordable, snapshot-testable.

### What it looks like

```swift
@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable { var count = 0 }

  enum Action: Equatable {
    case incrementTapped
    case decrementTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementTapped: state.count += 1; return .none
      case .decrementTapped: state.count -= 1; return .none
      }
    }
  }
}

// View
struct CounterView: View {
  @Bindable var store: StoreOf<CounterFeature>
  var body: some View {
    VStack {
      Text("\(store.count)")
      Button("+") { store.send(.incrementTapped) }
    }
  }
}
```

And testing is laser-precise:
```swift
let store = TestStore(initialState: CounterFeature.State()) { CounterFeature() }
await store.send(.incrementTapped) { $0.count = 1 }  // ← the test asserts the state transition
```

### What you see in this template

```
Modules/
├── SharedModels/                  # AppTab, cross-feature value types
├── CounterFeature/                # @Reducer + View + tests
├── SettingsFeature/               # ditto, uses @BindableAction
└── AppFeature/                    # root Reducer that composes children via Scope
```

TCA replaces traditional DI with `@Dependency` clients (defined in TCA itself).

### Pick when

- Behavior is state-machine-shaped (wizards, multi-step flows, games, complex forms)
- You need deterministic state replay (event sourcing, time-travel debugging)
- Team has TCA experience, or is excited to invest in it
- Cross-feature composition (parent reducer routes to child) happens often

### Cost of picking it

TCA has its own mental model that takes weeks to fully internalize. Onboarding a junior dev is slower than MVVM. The dependency-client pattern is great but unique to TCA — you can't bolt Factory or your favorite DI library on top.

---

## Anti-patterns the templates avoid

Things you'll *not* see, even though they're common in iOS:

- **God ViewModels**: every ViewModel in the templates is < 80 lines. If yours grows past that, split it.
- **Singletons everywhere**: `Container.shared` (Factory DI) or `AppComposer` are the only sanctioned global state. No `MyService.shared` scattered across files.
- **`fatalError` for "this shouldn't happen"**: never — graceful degradation, log, fallback.
- **Force-unwrap (`!`)**: never — use `guard let` / `if let` / `??`.
- **`DispatchQueue`**: never — `async/await`, actors, structured concurrency only.

These rules are enforced by `.swiftlint.yml` shipped in every template. They aren't suggestions; they're build failures.

## Migrating between architectures

You won't pick wrong forever. Here's roughly how to move:

| From | To | Trigger |
|------|-----|---------|
| Simple MVVM | Modular MVVM | When `Sources/` has > 30 Swift files |
| Modular MVVM | Clean + Repository | When a feature needs to swap data sources (cache vs network) |
| Anything | TCA | When state bugs become the dominant class of bug you fix |

Migration is real work. The point: **don't pre-emptively pick the heaviest architecture "in case you need it"** — pick the smallest that fits, and budget refactor time when you outgrow it. Premature architecture is a real cost; everyone you onboard pays for it.

## Still not sure?

If you're genuinely stuck choosing, generate **two** projects with `--no-setup --no-git` flags, look at the file trees side-by-side, and pick the one whose layout you find more intuitive. You'll know in 5 minutes.

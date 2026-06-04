# XcodeGen · Clean Architecture + MVVM + Repository

The most layered template. Each feature is split into three sub-modules — **Domain**, **Data**, **Presentation** — and the App layer is a **Composition Root** that wires real implementations to protocols. This is the right shape when an app talks to multiple data sources (network + cache + keychain) and you need to be able to swap any of them out (for tests, previews, or future-you).

Pick this when: medium-to-large app, 3+ devs, multiple data sources, tests are a hard requirement.

> 💡 First time seeing "Clean Architecture"? Read `docs/architecture-decisions.md` (section #3-clean-architecture--mvvm--repository) in the swift-template repo first — it explains *why* this layering exists.

> 🎨 **SwiftUI only** — every template in this repo uses SwiftUI views, `@Observable` view models, and `async/await`. UIKit, Storyboards, and XIBs are not supported.

## What you see when you run it

`Cmd+R`. Two tabs at the bottom:

- **Home** — a list of 5 items, fetched via a `HomeRepository`. The fetch is a stub (returns seed data) but the *shape* is real — replace the body of `HomeRepository.fetchItems()` with an actual `httpClient.get(...)` call and you have a real network feature.
- **Profile** — a form whose display name persists in the iOS Keychain via a real `KeychainService`. Edit the name, kill the app, relaunch — it's still there.

Profile demonstrates real persistence; Home demonstrates the network-call pattern. Both follow the same Domain/Data/Presentation slicing.

## Guided tour (the 12 places)

```
Modules/
├── Package.swift                                       # ← 1. All targets in ONE SPM manifest
├── Core/
│   ├── AppCore/Sources/                                # ← 2. Logger, AppError
│   ├── CommonUI/Sources/                               # ← 3. Spacing, LoadingView, ErrorView
│   ├── CoreNavigation/Sources/                         # ← 4. AppRouter, AppRoute, AppTab
│   ├── CoreNetwork/Sources/HTTPClient.swift            # ← 5. Actor; protocol-driven
│   ├── CorePersistence/Sources/                        # ← 6. SwiftData ModelContainer wrapper
│   └── CoreKeychain/Sources/KeychainService.swift      # ← 7. Actor wrapping Security framework
└── Features/
    ├── HomeFeature/
    │   ├── Domain/                                     # ← 8. Pure Swift: HomeItem, HomeRepositoryProtocol, FetchHomeItemsUseCase
    │   ├── Data/                                       # ← 9. HomeItemDTO, HomeRepository
    │   ├── Presentation/                               # ← 10. HomeViewModel (depends on protocols), HomeView
    │   └── Tests/HomeViewModelTests.swift
    └── ProfileFeature/                                 # same shape

App/
├── Sources/
│   ├── __APP_NAME__App.swift                           # ← 11. @main
│   ├── AppComposer.swift                               # ← 12. Composition Root (wires real impls)
│   └── RootView.swift                                  # TabView
└── ...
```

### The Composition Root — the most important file

Open `App/Sources/AppComposer.swift`:

```swift
@MainActor
final class AppComposer {
  private let httpClient: HTTPClientProtocol
  private let keychain: KeychainServiceProtocol
  private let homeRepository: HomeRepositoryProtocol
  private let profileRepository: ProfileRepositoryProtocol

  init() {
    httpClient = HTTPClient(baseURL: Self.defaultBaseURL)
    keychain = KeychainService()
    homeRepository = HomeRepository(httpClient: httpClient)
    profileRepository = ProfileRepository(keychain: keychain)
  }

  func makeHomeViewModel() -> HomeViewModel {
    HomeViewModel(fetchItems: FetchHomeItemsUseCase(repository: homeRepository))
  }
  // ...
}
```

This is the **only place in the entire app** that knows about every concrete implementation. To swap the network repo for a mock in a SwiftUI preview, you'd write a `MockHomeRepository` and have a different `AppComposer` build the ViewModel — the ViewModel itself doesn't change at all.

## Dependency rules

```
HomeFeature (Presentation)  ─►  HomeFeatureDomain (protocols)
                                       ▲
                                       │ implements
                                       │
HomeFeatureData          ──────────────┘
       │
       ▼
CoreNetwork + CorePersistence + CoreKeychain
```

The arrow direction is what matters: **Presentation depends on Domain (abstractions), not on Data (implementations)**. That's the Dependency Inversion Principle. Tests substitute fake Data implementations without changing a single line of Presentation code.

## Try this first (3 exercises)

### Exercise 1: Make the Home stub return real data

Open `Modules/Features/HomeFeature/Data/HomeRepository.swift`. Find `fetchItems()`. Replace the stub:

```swift
public func fetchItems() async throws -> [HomeItem] {
  // OLD: return (1...5).map { ... }
  let dtos = try await httpClient.get("/items", as: [HomeItemDTO].self)
  return dtos.map { $0.toDomain() }
}
```

Then in `App/Sources/AppComposer.swift`, change `defaultBaseURL` to point at a real JSON API that returns items. (For demo purposes, https://jsonplaceholder.typicode.com/posts returns Posts, not Items — you'd need to remap, but the *shape* is the lesson.)

### Exercise 2: Add a mock repo for SwiftUI previews

1. In `Modules/Features/HomeFeature/Presentation/HomeView.swift`, at the bottom:
   ```swift
   #Preview {
     final class MockRepo: HomeRepositoryProtocol {
       func fetchItems() async throws -> [HomeItem] {
         (1...3).map { HomeItem(id: "\($0)", title: "Preview \($0)", createdAt: .now) }
       }
       func item(id: String) async throws -> HomeItem { fatalError() }
     }
     let useCase = FetchHomeItemsUseCase(repository: MockRepo())
     return NavigationStack { HomeView(viewModel: HomeViewModel(fetchItems: useCase)) }
       .environment(AppRouter())
   }
   ```
2. Click the canvas in Xcode — the preview shows three "Preview N" items, no network needed.

This is the **superpower of Clean Architecture**: the same ViewModel works with a real repo (in the app), a mock repo (in previews), or a stub repo (in tests). The ViewModel doesn't care.

### Exercise 3: Add a second use case to a feature

Imagine Home should also "delete an item." The pattern:

1. In `Modules/Features/HomeFeature/Domain/`, add a new file:
   ```swift
   public protocol DeleteHomeItemUseCaseProtocol: Sendable {
     func execute(itemID: String) async throws
   }

   public struct DeleteHomeItemUseCase: DeleteHomeItemUseCaseProtocol {
     private let repository: HomeRepositoryProtocol
     public init(repository: HomeRepositoryProtocol) { self.repository = repository }
     public func execute(itemID: String) async throws {
       // would call repository.delete(id:) but we'd add that to the protocol
     }
   }
   ```
2. Add a `delete(id:)` method to `HomeRepositoryProtocol`, implement it in `HomeRepository`
3. In `HomeViewModel`, accept the new use case as a constructor parameter, expose a `delete(_:)` method
4. In `AppComposer.makeHomeViewModel()`, pass both use cases
5. In `HomeView`, add a swipe-to-delete action

This is *Clean Architecture's signature workflow*: a new feature touches Domain → Data → Presentation → Composer in sequence. The compiler tells you which file to edit next.

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

## Testing rules

| Layer | What to mock |
|-------|--------------|
| ViewModel tests | Mock the use case — fastest, no async wiring |
| Use case tests | Mock the repository |
| Repository tests | Mock CoreNetwork / CoreKeychain |
| Domain entity tests | Nothing to mock — pure value-type tests |

The Composition Root is the only thing that touches every layer; everything else stays mockable.

## How to add a feature

1. `mkdir -p Modules/Features/<Name>Feature/{Domain,Data,Presentation,Tests}`
2. Add 4 targets to `Modules/Package.swift`: `<Name>FeatureDomain`, `<Name>FeatureData`, `<Name>Feature` (presentation umbrella), `<Name>FeatureTests`
3. Define entities + repository protocol in `Domain/`
4. Implement the repository in `Data/`
5. Write the ViewModel (depends on use-case protocol) and View
6. Register the new ViewModel factory in `AppComposer`
7. Wire the view into `RootView` (add an `AppRoute` case if it pushes)
8. `./setup.sh`

## Adding more platforms

The SPM package already declares iOS, macOS, visionOS, and watchOS. Toggle the app target's destinations in `project.yml`. For Watch/Widget extensions, prefer the **Tuist / Clean…** template.

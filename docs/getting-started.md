# Getting started

This walkthrough assumes **you have never built an iOS app before.** By the end you'll have a working iOS project running in the simulator. Should take ~30 minutes including downloads.

> 💡 Stuck on a word? [`concepts.md`](concepts.md) is the glossary.

## What this is and isn't

- **Is**: a **SwiftUI** scaffolding toolkit. Every generated project uses SwiftUI views, `@Observable` view models, and `async/await` concurrency.
- **Isn't**: a UIKit toolkit. You won't find `UIViewController`, Storyboards, or XIBs in any template. If you need UIKit-first scaffolding, start from Xcode's UIKit App template instead — you'll be fighting these templates the whole way otherwise.

(SwiftUI ↔ UIKit interop via `UIViewRepresentable` is fine — you can drop a UIKit view into a SwiftUI screen generated here. The architecture itself is SwiftUI, not your individual views.)

## Step 0: Do you have the prerequisites?

You need a **Mac** (Intel or Apple Silicon, macOS 14+ recommended). iOS dev is macOS-only — you literally can't build iOS apps from Windows or Linux without a Mac somewhere in the loop.

### Install Xcode (this is the big one)

1. Open the **App Store** on your Mac
2. Search for "Xcode"
3. Click **Install** (the download is ~10–15 GB; allow 30+ minutes on a slow connection)
4. After install, open Xcode once. It'll ask to install "additional components" — let it.
5. Open Terminal and run: `xcode-select --install` (installs the command-line tools)

Verify with:
```bash
xcodebuild -version
# Should print: Xcode 16.x or similar
```

### Install Homebrew (the macOS package manager)

If you don't have it yet:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify:
```bash
brew --version
```

That's it for prerequisites. SwiftLint, Tuist, XcodeGen, etc. will install automatically when needed.

## Step 1: Install the `ios-template` CLI

Open Terminal and:

```bash
cd /Users/darisadam/Documents/Projects/Tools/swift-template
./setup.sh
```

What this does:
- Verifies your environment (Xcode, git, Python, etc.)
- Symlinks the `ios-template` script to `~/.local/bin/ios-template` so you can call it from anywhere
- Tidies up any stray `.DS_Store` files

If `~/.local/bin` isn't on your `PATH`, the script will tell you what to add to your shell profile (`~/.zshrc` or `~/.bashrc`). Add it, then `source ~/.zshrc` (or open a new Terminal tab).

Test the install:
```bash
ios-template list
```

You should see a table of 8 templates. ✅

## Step 2: Generate your first project

```bash
ios-template new
```

It'll ask you a series of questions. Sensible answers for a first-timer:

| Question | Answer |
|---------|--------|
| Build system? | **xcodegen** (simpler) |
| Architecture? | **simple-mvvm** (smallest, easiest to read) |
| App name (PascalCase)? | `HelloWorld` |
| Bundle ID? | `com.yourname.helloworld` |
| Organization name? | Your name, or anything |
| Output directory? | `~/Projects/HelloWorld` (press Enter for default) |
| iOS deployment target? | `17.0` (press Enter) |
| Swift version? | `6.0` (press Enter) |
| Proceed? | `yes` |

The CLI will:
1. Copy the template
2. Substitute `__APP_NAME__` etc. throughout the files
3. Initialize a git repo
4. Run the project's `setup.sh` (which installs SwiftLint + XcodeGen + generates `HelloWorld.xcodeproj`)

When it finishes, you'll see:
```
🎉 Done!

Next steps:
  cd ~/Projects/HelloWorld
  open HelloWorld.xcodeproj
```

## Step 3: Run the app

```bash
cd ~/Projects/HelloWorld
open HelloWorld.xcodeproj
```

Xcode opens. In the top-left, you'll see a play button and a dropdown like `HelloWorld > iPhone 16 Pro`. **Press `Cmd + R`** (or click the play button).

The iOS Simulator opens and your app appears: a screen with a big `0` and three buttons (`-`, Reset, `+`). Tap the `+` button — the number goes up. Congratulations, **you just ran an iOS app**.

## Step 4: Look around

Here's what's inside `~/Projects/HelloWorld`:

```
HelloWorld/
├── App/
│   ├── Sources/
│   │   ├── App/
│   │   │   ├── HelloWorldApp.swift     # @main — the app's entry point
│   │   │   └── RootView.swift          # the first screen
│   │   ├── Features/
│   │   │   └── Counter/                # the example feature
│   │   │       ├── ViewModels/CounterViewModel.swift
│   │   │       └── Views/CounterView.swift
│   │   └── Common/Logger/AppLogger.swift
│   ├── Tests/                          # unit tests
│   ├── UITests/                        # UI tests
│   └── Resources/                      # Assets.xcassets, Info.plist
├── project.yml                         # XcodeGen config — describes the project
├── setup.sh                            # run this after `git pull` to regenerate the project
├── .swiftlint.yml                      # code style rules
├── .gitignore
├── CLAUDE.md                           # AI assistant instructions
├── AGENTS.md                           # ditto, for other AI tools
├── .cursorrules                        # ditto, for Cursor
├── .github/workflows/ci.yml            # GitHub Actions — runs tests on push
└── README.md                           # project-specific docs
```

### Open the example feature

In Xcode, expand `App/Sources/Features/Counter/`. Open `CounterViewModel.swift`:

```swift
@Observable @MainActor
final class CounterViewModel {
  private(set) var count: Int = 0
  var isAtZero: Bool { count == 0 }

  func increment() { count += 1 }
  func decrement() {
    guard count > 0 else { return }
    count -= 1
  }
  func reset() { count = 0 }
}
```

That's the entire data model and logic for the counter. Now open `CounterView.swift` — that's the SwiftUI screen that displays the count and the buttons. They're connected by `@State private var viewModel = CounterViewModel()`.

**This is what MVVM looks like.** State + logic lives in the ViewModel, layout lives in the View, they're decoupled.

## Step 5: Make your first change

Try this:

1. In `CounterViewModel.swift`, add a new method:
   ```swift
   func double() { count *= 2 }
   ```

2. In `CounterView.swift`, add a button somewhere inside the `HStack`:
   ```swift
   Button("×2") { viewModel.double() }
     .buttonStyle(.bordered)
   ```

3. Press `Cmd + R`. Tap the new button. Count doubles. 🎉

## Step 6: Run the tests

In Xcode: `Cmd + U`. Tests run; you see green checkmarks.

From the command line:
```bash
xcodebuild test \
  -project HelloWorld.xcodeproj \
  -scheme HelloWorld \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -skip-testing:HelloWorldUITests
```

Look at `App/Tests/CounterViewModelTests.swift` to see how tests are written.

## Step 7: Run the linter

```bash
swiftlint lint --config .swiftlint.yml
```

If the output is empty, you're clean. If you broke a rule (long line, force-unwrap, etc.), it'll tell you what file and line.

To autofix what's autofixable:
```bash
swiftlint lint --fix --config .swiftlint.yml
```

## Where to go next

- **Add a feature** to your counter app: a "history" of past counts? A "settings" screen? Read the [template's own README](../templates/xcodegen/simple-mvvm/README.md) for the file convention.
- **Try a more complex template**: generate another project with `--architecture modular-mvvm` and see how the same idea spreads across multiple module folders.
- **Read [architecture-decisions.md](architecture-decisions.md)** — it walks through the 4 architectures with code sketches so you can decide which one fits your real app.
- **Read [adding-platforms.md](adding-platforms.md)** to make your app run on iPad, Mac, or Vision Pro.
- **Bookmark [concepts.md](concepts.md)** — when you hit a word you don't know, look it up there.

## Common issues

### "command not found: ios-template"

The CLI symlink didn't end up on your `PATH`. Re-run `./setup.sh --install` from this repo, or run the CLI by its full path: `/Users/darisadam/Documents/Projects/Tools/swift-template/bin/ios-template`.

### "xcodebuild: error: Unable to find a destination matching..."

The simulator name in your test command doesn't match what's actually installed. List your simulators:
```bash
xcrun simctl list devices
```
…and pick one that exists (e.g., `iPhone 15 Pro` instead of `iPhone 16 Pro`).

### "SwiftLint complains about my code, but it's only a warning"

The templates use a "zero warnings" policy. Don't ignore warnings — fix them. SwiftLint can usually autofix simple things: `swiftlint lint --fix --config .swiftlint.yml`.

### "The generated project doesn't build — Xcode says module not found"

You probably ran `git pull` and someone changed `project.yml` (XcodeGen) or `Project.swift` (Tuist). Run the project's `./setup.sh` to regenerate.

### "Where is my .xcodeproj? I only see project.yml"

That's the point — XcodeGen generates `.xcodeproj` on demand. Run `./setup.sh` (or `xcodegen generate`) and it'll appear.

---

You're set. The next file to read is [architecture-decisions.md](architecture-decisions.md).

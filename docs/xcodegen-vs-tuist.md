# XcodeGen vs Tuist

## Why do we need either one?

When you open an Xcode project, Xcode reads a file called **`project.pbxproj`** inside the `.xcodeproj` folder. That file lists every source file, every build setting, every target, every linker flag. Two problems with it:

1. **It's enormous and ugly.** Hundreds (or thousands) of lines of UUIDs and serialized records. You're not meant to read it.
2. **Merge conflicts.** When two developers add a file at the same time, both touch `project.pbxproj`, and you get conflicts that are awful to resolve by hand.

The fix: **don't write `project.pbxproj` by hand.** Instead, describe your project in a small, readable file you write once, and let a tool generate `project.pbxproj` from it on demand. That's what XcodeGen and Tuist both do.

This pattern is called a **project generator**, and the workflow looks like:

```
your config file      ──► tool ──► .xcodeproj/   ──► Xcode runs the app
(project.yml /                     (generated;
 Project.swift)                     gitignored)
   ↑
   commit this
```

You commit the small config file. You `.gitignore` the generated `.xcodeproj`. No more conflicts. Project structure changes get reviewed in a 10-line YAML diff, not a 3000-line pbxproj diff.

## So which one?

Both XcodeGen and Tuist solve the same problem. They differ on **how you describe the project** and **how much extra they do for you**.

| Concern | XcodeGen | Tuist |
|---------|----------|-------|
| Manifest format | YAML (`project.yml`) | Swift (`Project.swift`) |
| Install time | 30 seconds (`brew install xcodegen`) | A few minutes (`brew install mise && mise install tuist`) |
| Multi-project workspaces | Possible but manual | First-class, easy |
| Dependency caching for CI | None | `tuist cache` ships a binary cache |
| Manifest is type-checked | No — YAML typos surface at generation time | Yes — manifest is real Swift code Xcode autocompletes |
| External Swift packages | `packages:` block in YAML | `Tuist/Package.swift`, then `.external(name:)` |
| Learning curve | Hours | Days |
| Add-ons / ecosystem | Few | Many (signing, focused projects, graph viz, etc.) |
| Best for | Single-target apps, small teams | Multi-module apps, large teams |

### Concrete example: how do you describe the app target?

**XcodeGen** (`project.yml`):
```yaml
targets:
  MyApp:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    supportedDestinations: [iOS, iPadOS]
    sources:
      - path: App/Sources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.myapp
```

**Tuist** (`Project.swift`):
```swift
import ProjectDescription

let project = Project(
  name: "MyApp",
  targets: [
    .target(
      name: "MyApp",
      destinations: [.iPhone, .iPad],
      product: .app,
      bundleId: "com.example.myapp",
      deploymentTargets: .iOS("17.0"),
      sources: ["App/Sources/**"]
    )
  ]
)
```

Same idea, different surface. The Tuist version is type-checked at edit time — typo `destinations` and your editor underlines it. The XcodeGen version is faster to read but typos blow up at `xcodegen generate` time.

## Pick XcodeGen when

- You want the **simplest setup possible** ("brew install xcodegen, write YAML, you're done")
- The app is one Xcode project (no multi-module workspace)
- The team is small and the YAML is fine
- You already use XcodeGen elsewhere and the team knows it
- You're learning iOS and want fewer moving pieces

**Recommended template:** `xcodegen / simple-mvvm`

## Pick Tuist when

- The app will have **multiple modules** (so multiple `.xcodeproj`s in one workspace) — Tuist's bread and butter
- You want **type-safe manifests** — renaming a module is a Swift refactor, not find-and-replace through YAML
- You want **binary caching on CI** (`tuist cache` significantly speeds up CI for big projects)
- You're going **multi-platform** (iOS + Mac + Watch + Vision Pro) — one place declares all destinations
- You like that `tuist edit` opens your manifests in Xcode with full autocomplete

**Recommended templates:** `tuist / modular-mvvm` or `tuist / clean-mvvm-repository`

## What stays the same regardless

Switching build systems doesn't change:

- The Swift code in `Sources/` — your architecture is independent of the build system
- `.swiftlint.yml` and `.swiftformat`
- `.gitignore`
- The GitHub Actions workflow
- `CLAUDE.md` / `AGENTS.md` / `.cursorrules`

Only the manifest format and the `setup.sh` differ.

## "I picked one. Can I switch later?"

Yes, in either direction. **XcodeGen → Tuist** is the more common move (small project grows up):

1. Generate a Tuist scaffold with the same name + bundle ID:
   ```bash
   ios-template new --build-system tuist --architecture modular-mvvm \
     --name MyApp --bundle-id com.example.myapp --output ./MyAppNew
   ```
2. Copy `Sources/`, `Resources/`, `Tests/`, `UITests/` from the old project into the new one
3. Translate `project.yml` dependencies into the Tuist `dependencies:` arrays
4. Delete the old project, rename `MyAppNew` to `MyApp`

**Tuist → XcodeGen** is rare (it's a step down in capability) but mechanically the same: scaffold an XcodeGen project, copy code, translate the manifest.

## Common questions

**Q: Do I need both XcodeGen and Tuist installed?**
No. Only the one your project uses.

**Q: Can I open a Tuist project in Xcode without Tuist installed?**
You can open the `.xcworkspace` file, but as soon as the workspace gets out of sync (a teammate adds a module), you'll need `tuist generate` to regenerate it. Same with XcodeGen and `xcodegen generate`.

**Q: Does the App Store care which one I used?**
No. Apple sees the resulting `.ipa` (signed bundle); it has no idea how the `.xcodeproj` was generated.

**Q: Which is more popular?**
Hard to say. Tuist has stronger usage at large iOS shops; XcodeGen is more popular in indie/single-target apps. Both are mature and actively maintained.

---

Need to actually choose? Skip the back-and-forth: if your app has < 5 features, pick XcodeGen and move on. You can always switch later if you outgrow it.

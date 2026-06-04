# Adding platforms to a generated project

> 💡 New to this? See [concepts.md](concepts.md) for what "target," "destination," and "bundle ID" mean.

## What "adding a platform" actually means

Every Apple device family has its own SDK:

- **iOS** for iPhone, **iPadOS** for iPad — these are nearly the same, your iPhone app can usually run on iPad with little extra work.
- **macOS** for native Mac apps, **macCatalyst** for iPad apps wearing Mac chrome — different binaries, mostly shared code.
- **visionOS** for the Vision Pro — yet another SDK, mostly shared code with iPad.
- **watchOS** for Apple Watch — a totally different runtime; needs its own target and (usually) its own UI.

There are two flavors of "add a platform" depending on the device:

1. **Just add a destination** to your existing app target (iPad, Mac, Vision Pro, Catalyst). Same code base, just compiles for more screens. *Easy.*
2. **Create a new target** for a companion app or extension (Apple Watch, Widget, Live Activity, iMessage). Different runtime, separate bundle ID, often its own UI. *More involved.*

By default, every template targets **iPhone + iPad** to keep code signing and capabilities simple. Here's how to add the rest.

## iPad-style platforms (no new target)

These are just additional destinations on the existing app target. Code, plist, and entitlements stay shared.

- **macOS** (Catalyst or native)
- **visionOS**
- **macCatalyst**

### Via the CLI

```bash
ios-template add-platform --in ~/Projects/YourApp --platform visionos
ios-template add-platform --in ~/Projects/YourApp --platform macos
ios-template add-platform --in ~/Projects/YourApp --platform maccatalyst
```

For **XcodeGen**, this rewrites `project.yml` in place. For **Tuist**, the CLI tells you exactly what to edit in `Project.swift` (Swift code can't be safely rewritten without re-parsing).

Then run `./setup.sh` to regenerate the Xcode project.

### Manually

**XcodeGen** — edit `project.yml`:

```yaml
targets:
  YourApp:
    supportedDestinations:
      - iOS
      - iPadOS
      - macOS         # native Mac
      - macCatalyst   # iPad app, Mac chrome
      - visionOS
```

**Tuist** — edit `Project.swift`:

```swift
destinations: [.iPhone, .iPad, .mac, .macCatalyst, .appleVision],
deploymentTargets: .multiplatform(
  iOS: "17.0",
  macOS: "14.0",
  visionOS: "1.0"
),
```

## Platforms that need a separate target

These are *companion* apps/extensions. They get their own bundle ID, plist, and source tree.

- **watchOS** companion app
- **Widget** (`WidgetKit` extension)
- **Live Activity**
- **iMessage extension**
- **Action / Share extension**

### watchOS in Tuist (recommended path)

Add to `Project.swift`:

```swift
.target(
  name: "YourAppWatch",
  destinations: [.appleWatch],
  product: .app,
  bundleId: "com.example.yourapp.watchkitapp",
  deploymentTargets: .watchOS("10.0"),
  infoPlist: .extendingDefault(with: [
    "WKApplication": true,
    "WKCompanionAppBundleIdentifier": "com.example.yourapp"
  ]),
  sources: ["YourAppWatch/Sources/**"],
  resources: ["YourAppWatch/Resources/**"],
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path))
  ]
),
```

Then add it to the **app target's** `dependencies` so it gets embedded:

```swift
dependencies: [
  // …existing…
  .target(name: "YourAppWatch"),
]
```

`parrotalk-ios` is the canonical reference for this pattern — see `ParroTalkWatch/` and the watch target in `Project.swift`.

### Widget in Tuist

```swift
.target(
  name: "YourAppWidget",
  destinations: [.iPhone, .iPad],
  product: .appExtension,
  bundleId: "com.example.yourapp.widget",
  deploymentTargets: .iOS("17.0"),
  infoPlist: .extendingDefault(with: [
    "NSExtension": [
      "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
    ]
  ]),
  sources: ["YourAppWidget/Sources/**"],
  dependencies: [
    .project(target: Module.appCore.targetName, path: .relativeToRoot(Module.appCore.path)),
    .project(target: Module.commonUI.targetName, path: .relativeToRoot(Module.commonUI.path))
  ]
),
```

Then embed in the app target's dependencies: `.target(name: "YourAppWidget")`.

### Companions in XcodeGen

XcodeGen handles separate targets in the same `project.yml`:

```yaml
targets:
  YourAppWatch:
    type: application
    platform: watchOS
    deploymentTarget: "10.0"
    sources:
      - path: YourAppWatch/Sources
    info:
      path: YourAppWatch/Info.plist
      properties:
        WKApplication: true
        WKCompanionAppBundleIdentifier: com.example.yourapp
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.yourapp.watchkitapp

  YourApp:
    # …existing app config…
    dependencies:
      - target: YourAppWatch
        embed: true
```

## Sharing code across platforms

Both XcodeGen + SPM and Tuist already declare modules as multi-platform. The shared modules (`AppCore`, `CommonUI`) compile for iOS, watchOS, macOS, and visionOS by default. Your watch / widget targets can import them directly.

For platform-specific code, gate it with `#if os(watchOS)` / `#if os(macOS)` rather than splitting into per-platform modules — that keeps the dependency graph manageable.

## CI considerations

GitHub Actions's `macos-15` runner can build for every Apple platform. The ci.yml that ships with each template only runs iOS tests by default. To add visionOS or watchOS test runs, duplicate the `test` job with a different `-destination` flag, e.g.:

```yaml
- name: visionOS tests
  run: |
    xcodebuild test \
      -workspace YourApp.xcworkspace \
      -scheme YourApp \
      -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Common newcomer questions

**Q: Do I need to write separate SwiftUI views for iPad vs Mac vs Vision Pro?**
Usually no. SwiftUI adapts the same view code automatically — the same `NavigationStack` becomes a sidebar layout on iPad, a window with a toolbar on Mac, and a floating panel on Vision Pro. You'll occasionally use `#if os(macOS)` to tweak specific things (toolbars, keyboard shortcuts), but the bulk of your code stays shared.

**Q: My iPhone app already runs on iPad — why would I "add iPad"?**
The iPhone build *does* run on iPad as-is, but at iPhone resolution in a small window ("Designed for iPhone" mode). Adding iPadOS as a destination makes it a real iPad app — full screen, split view, multitasking, the works.

**Q: Why doesn't Apple Watch get the "just add a destination" treatment?**
Apple Watch apps run on a separate processor with a much smaller screen and very different UI patterns. They need their own bundle ID, their own UI (you wouldn't show an iPad NavigationStack on a watch), and their own app lifecycle. So they need their own target.

**Q: Can I ship to multiple platforms with one App Store submission?**
Yes — most modern Apple apps do. The `.ipa` you upload contains slices for each supported destination. The App Store shows your app under iPhone, iPad, Mac, and Vision Pro separately, with the right binary picked for each device.

**Q: Do I need a Vision Pro to develop for Vision Pro?**
No. Xcode ships a Vision Pro simulator. You can write and test visionOS code with no physical device. (You'll want a real one before shipping, of course.)

**Q: I added a platform — now my code-signing is broken.**
Each platform/extension target needs to be added to your provisioning profile. The first time you build for a real device, Xcode usually prompts you to register the new bundle ID with your Apple Developer account. Follow the prompt.

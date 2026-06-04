# Xcode Cloud setup for __APP_NAME__

Xcode Cloud is Apple's first-party CI. It is configured **in App Store Connect**, not in this repo — no file is added here.

To set it up:

1. Open your project in Xcode → **Product → Xcode Cloud → Create Workflow…**
2. Pick this repo and the `__APP_NAME__` scheme.
3. Add an Action: **Test** with destination "iOS Simulator > Recommended."
4. Add a Start Condition: **On Pull Requests** or **On Branch Changes** for `main` / `develop`.
5. Add an Environment variable if needed.

Notes:

- Xcode Cloud runs `xcodebuild` internally, so the same `swiftlint` + test commands documented in `CLAUDE.md` apply.
- You'll need to **commit the generated `.xcodeproj` / `.xcworkspace`** for Xcode Cloud to find your scheme, **OR** add a Custom Build Script in the Xcode Cloud workflow that runs `__GENERATE_COMMAND__` before build (preferred — keeps your repo clean).

Custom Build Script (`ci_scripts/ci_post_clone.sh` at the repo root):

```bash
#!/bin/zsh
set -e
brew install mise xcodegen tuist
mise install
__GENERATE_COMMAND__
```

Make it executable: `chmod +x ci_scripts/ci_post_clone.sh`. Xcode Cloud runs this automatically before the build phase.

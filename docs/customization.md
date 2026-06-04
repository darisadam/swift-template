# Customization options

`ios-template new` accepts a lot of flags. This doc explains every customization option, what it changes in the generated project, and when to pick what.

> 💡 New to this? Read [getting-started.md](getting-started.md) first.

## Flags at a glance

```bash
ios-template new \
  --build-system tuist|xcodegen \
  --architecture simple-mvvm|modular-mvvm|clean-mvvm-repository|modular-tca \
  --name MyApp \
  --bundle-id com.example.myapp \
  --org "My Org" \
  --output ./MyApp \
  --deployment-target 17.0 \
  --swift-version 6.0 \
  --devices universal \
  --persistence swift-data \
  --test-framework xctest \
  --swiftlint yes \
  --ci github \
  --ai-agents claude,cursor
```

Add `-y` (or `--yes`) to use defaults for any flag you didn't supply, so you can skip the interactive prompts entirely.

## Required choices

### `--build-system tuist | xcodegen`

How the Xcode project gets generated. See [xcodegen-vs-tuist.md](xcodegen-vs-tuist.md) for the comparison.

### `--architecture simple-mvvm | modular-mvvm | clean-mvvm-repository | modular-tca`

How the code is organized inside the project. See [architecture-decisions.md](architecture-decisions.md).

### `--name`, `--bundle-id`, `--org`

Identity. `--name` must be PascalCase. `--bundle-id` should be reverse-DNS (`com.yourco.yourapp`). `--org` is what shows up as `ORGANIZATIONNAME` in the Xcode project metadata.

### `--deployment-target`, `--swift-version`

Default `17.0` and `6.0`. Drop deployment target only if you need to support older iOS — but keep in mind that lower deployment targets lock you out of newer SwiftUI/Foundation APIs.

## Optional customization

### `--devices iphone | universal | all`

| Value | What | Destinations included |
|-------|------|-----------------------|
| `iphone` | iPhone only | `iOS` |
| `universal` *(default)* | iPhone + iPad | `iOS`, `iPadOS` |
| `all` | The full Apple lineup | `iOS`, `iPadOS`, `macOS`, `visionOS`, `macCatalyst` |

Pick `iphone` only if you're certain the app will never want iPad/Mac/Vision. Going from `iphone` to `universal` later is one flag flip; going from `universal` to `all` is the same — see [adding-platforms.md](adding-platforms.md).

> Apple Watch is **not** a destination — it needs its own target. See [adding-platforms.md](adding-platforms.md#platforms-that-need-a-separate-target).

### `--persistence none | swift-data | core-data`

Persistence framework for the `CorePersistence` module.

| Value | What | When to pick |
|-------|------|--------------|
| `none` | No persistence module | Stateless apps, prototypes, or you'll add persistence later |
| `swift-data` *(default for clean-mvvm-repository)* | Apple's modern declarative ORM | Greenfield apps on iOS 17+, less ceremony |
| `core-data` | Classic Core Data + `NSPersistentContainer` | iOS 16 or older, existing Core Data schema, CloudKit interop |

Only meaningful for `--architecture clean-mvvm-repository`. Other architectures default to `none`.

See [persistence-core-data variant docs](../shared/variants/persistence-core-data/README.md).

### `--test-framework xctest | swift-testing`

| Value | What | When to pick |
|-------|------|--------------|
| `xctest` *(default)* | The classic `XCTestCase` framework | Maximum compatibility, every iOS/Xcode/CI supports it |
| `swift-testing` | Apple's modern `@Test` + `#expect` framework | Swift 6, Xcode 16+, value-typed tests, parametrized tests |

Currently the `swift-testing` variant ships for `simple-mvvm` only. Modular/TCA templates default to XCTest; switching them requires more changes than the CLI does today (Swift Testing variants for modular tests will follow).

### `--swiftlint yes | no`

| Value | What |
|-------|------|
| `yes` *(default)* | Adds `.swiftlint.yml` + `.swiftformat`. Generated CI workflow runs `swiftlint --strict`. |
| `no` | No SwiftLint config. No lint job in CI. You manage style yourself. |

Pick `no` only if your team has a different linter setup or wants no linting at all. The zero-violation policy is opinionated — but the rules are reasonable and prevent the common Swift footguns (force-unwrap, `print`, `fatalError`).

### `--ci github | gitlab | bitbucket | circleci | xcode-cloud | none`

Continuous integration provider. The CLI writes the appropriate config file at the right location:

| Value | File created | Where |
|-------|--------------|-------|
| `github` *(default)* | `ci.yml` | `.github/workflows/` |
| `gitlab` | `.gitlab-ci.yml` | repo root |
| `bitbucket` | `bitbucket-pipelines.yml` | repo root |
| `circleci` | `config.yml` | `.circleci/` |
| `xcode-cloud` | `XCODE_CLOUD.md` (instructions, no actual config — Xcode Cloud is configured in App Store Connect) | repo root |
| `none` | Nothing | — |

All non-GitHub macOS-based CI requires a **self-hosted macOS runner with Xcode installed**, since GitLab/Bitbucket/CircleCI don't provide hosted macOS runners on free tiers. GitHub Actions and Xcode Cloud do.

### `--ai-agents <comma-separated>`

Comma-separated list of AI assistant config files to drop in. Each tool reads its own conventional filename:

| Value | What it ships | Tool that reads it |
|-------|---------------|-------------------|
| `claude` *(default)* | `CLAUDE.md`, `.claude/{settings.json, commands/*}` | [Claude Code](https://claude.com/claude-code) |
| `cursor` | `.cursorrules`, `.cursor/rules/main.mdc` | [Cursor](https://cursor.com) (legacy + v2 formats) |
| `codex` | `AGENTS.md` | OpenAI Codex / OpenAI Agents / Aider's secondary file / others using the `AGENTS.md` convention |
| `gemini` | `GEMINI.md` | Google Gemini Code Assist |
| `antigravity` | `ANTIGRAVITY.md` | Google Antigravity |
| `aider` | `CONVENTIONS.md` | [Aider](https://aider.chat) |
| `windsurf` | `.windsurfrules` | [Windsurf](https://codeium.com/windsurf) |

You can list any subset:

```bash
--ai-agents claude,cursor,gemini   # 3 tools
--ai-agents claude                 # just Claude (default)
--ai-agents claude,cursor,codex,gemini,antigravity,aider,windsurf   # everything
```

If two tools read related files (e.g., Cursor reads both `.cursorrules` and `.cursor/rules/`), the CLI ships both — no harm in having compatible duplicates.

All AI agent files contain the same architectural rules (just in each tool's preferred format), so they stay in sync.

## Behavior flags

### `--no-git`

Skip `git init` + initial commit. Useful when scaffolding into an existing repo.

### `--no-setup`

Skip running the project's own `setup.sh` after scaffold. Useful when you want to inspect the output before running `tuist install` / `xcodegen generate`.

### `-y` / `--yes`

Use defaults for any flag not supplied. Combined with all the required flags, this is the non-interactive scripting mode — no prompts at all.

## Putting it together

### "Just give me something to look at" (everything default)

```bash
ios-template new
```

Walks you through the interactive prompts.

### "I'm a TCA-curious solo dev"

```bash
ios-template new --build-system xcodegen --architecture modular-tca \
  --name PlayGround --bundle-id com.me.playground --org "Me" \
  --ai-agents claude,cursor -y
```

### "Production app, full team, all the bells"

```bash
ios-template new --build-system tuist --architecture clean-mvvm-repository \
  --name Aurora --bundle-id com.acmecorp.aurora --org "Acme Corp" \
  --devices all --persistence swift-data --test-framework xctest \
  --swiftlint yes --ci github \
  --ai-agents claude,cursor,gemini,codex \
  --deployment-target 17.0 --swift-version 6.0 \
  --output ~/Projects/Aurora
```

### "Minimal scaffold, no opinions"

```bash
ios-template new --build-system xcodegen --architecture simple-mvvm \
  --name Lean --bundle-id com.me.lean --org "Me" \
  --swiftlint no --ci none --ai-agents claude -y
```

### "I want to try Swift Testing"

```bash
ios-template new --build-system tuist --architecture simple-mvvm \
  --name Modern --bundle-id com.me.modern --org "Me" \
  --test-framework swift-testing -y
```

### "Bitbucket-hosted team, iPad-Mac-Vision only"

```bash
ios-template new --build-system tuist --architecture modular-mvvm \
  --name Cosmos --bundle-id com.cosmos.app --org "Cosmos" \
  --devices all --ci bitbucket -y
```

## What if I picked wrong?

Almost everything is editable after scaffold:

| Option | How to change later |
|--------|---------------------|
| `--devices` | `ios-template add-platform --in . --platform <name>` or edit project.yml / Project.swift |
| `--persistence` | Drop in `CoreDataController.swift` or `PersistenceController.swift` — see [persistence-core-data/README.md](../shared/variants/persistence-core-data/README.md) |
| `--test-framework` | Convert tests one file at a time — they live side-by-side fine |
| `--swiftlint` | `brew install swiftlint`, copy `.swiftlint.yml` from this repo, run `swiftlint lint --fix` |
| `--ci` | Copy a different file from `shared/ci/` |
| `--ai-agents` | Copy more files from `shared/ai/` |
| `--build-system`, `--architecture` | Migration is doable but real work — see [xcodegen-vs-tuist.md](xcodegen-vs-tuist.md) and [architecture-decisions.md](architecture-decisions.md) |

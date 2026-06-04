# swift-template

**Skip the "starting a new iOS app" busywork.** This tool generates a ready-to-run iOS project — with sensible defaults, a working example screen, linting, CI, and AI assistant configuration already wired up — so you can start building your actual app on day one.

Think `create-next-app` or `cargo new`, but for iOS.

## Who is this for?

- **You're starting a new iOS app** and don't want to spend a day setting up Xcode, SwiftLint, GitHub Actions, and your folder structure by hand.
- **You're a junior dev or intern** about to write your first "real" iOS app and you want a project that already follows good practices, so you can copy patterns rather than guess at them.
- **You're a tech lead** who wants every new app in your team to start the same way.
- **You're a hobbyist** who just wants to try a different architecture (MVVM vs TCA) without learning the build-system plumbing first.

If you have no idea what "MVVM" or "Tuist" means yet, that's fine — see [docs/concepts.md](docs/concepts.md) first.

## What does it actually do?

You run one command:

```bash
ios-template new
```

It asks a few questions (app name, bundle ID, which architecture you want) and then **creates a folder you can open in Xcode and run immediately.** That folder contains:

- A real, working SwiftUI app with one example feature (a counter, or a home/profile flow)
- All the build-system setup so the project opens cleanly in Xcode
- `SwiftLint` configured to enforce good Swift style automatically
- `.gitignore` so you don't accidentally commit `.DS_Store` or build artifacts
- A GitHub Actions workflow so your tests run in CI from day one
- `CLAUDE.md`, `AGENTS.md`, `.cursorrules` — config files that tell AI coding assistants how your project is structured
- A `setup.sh` script for teammates who clone your repo later

It's the difference between "I have an empty Xcode project" and "I have a project my whole team could ship from."

## Quickstart (3 minutes)

```bash
# 1. One-time setup — installs the `ios-template` CLI to ~/.local/bin
cd /Users/darisadam/Documents/Projects/Tools/swift-template
./setup.sh

# 2. Every time you want a new app:
ios-template new
```

The interactive prompt will walk you through it. Or, if you already know what you want:

```bash
ios-template new \
  --build-system tuist \
  --architecture clean-mvvm-repository \
  --name Aurora \
  --bundle-id com.example.aurora \
  --org "Example Org" \
  --output ~/Projects/Aurora
```

Then `cd ~/Projects/Aurora` and open the `.xcworkspace` (Tuist) or `.xcodeproj` (XcodeGen) file. **You're done. Hit Cmd+R in Xcode and the app runs.**

> 👶 **First time on iOS?** Read [docs/getting-started.md](docs/getting-started.md) — it explains every prerequisite, what Xcode is, and what each generated file does.

## The 8 templates

You pick two things: a **build system** (how the project gets generated) and an **architecture** (how the code is organized). That gives you 2 × 4 = 8 combinations.

|              | Simple MVVM | Modular MVVM | Clean + MVVM + Repository | Modular TCA |
|--------------|:-----------:|:------------:|:-------------------------:|:-----------:|
| **XcodeGen** |      ✅     |      ✅      |             ✅            |     ✅      |
| **Tuist**    |      ✅     |      ✅      |             ✅            |     ✅      |

**Not sure which to pick?**

- Just learning, or building a small app? → **XcodeGen** (or **Tuist**) **/ Simple MVVM**
- Real production app, multiple features, team of 2-5? → **Tuist / Modular MVVM**
- Big team, multiple data sources, strict test coverage? → **Tuist / Clean + MVVM + Repository**
- You want every state change to be testable and replayable? → **Tuist / Modular TCA**

Full guidance: [docs/architecture-decisions.md](docs/architecture-decisions.md). Build-system tradeoffs: [docs/xcodegen-vs-tuist.md](docs/xcodegen-vs-tuist.md).

## Frequently asked

<details>
<summary><b>What's wrong with Xcode's "File → New Project"?</b></summary>

Nothing — for a toy. But Xcode's default new project has zero linting, no CI, no `.gitignore`, no example architecture, and stores the project layout in a binary-ish `project.pbxproj` file that's notoriously merge-hostile when two teammates edit it. This tool fixes all of that.
</details>

<details>
<summary><b>Why two build systems? Which should I pick?</b></summary>

**XcodeGen** is the simpler choice: you write a YAML file, it spits out an `.xcodeproj`. **Tuist** is more powerful: you write Swift code, it generates a multi-project workspace with proper module separation, caching, and other goodies. If you don't know which to pick, start with XcodeGen; you can migrate later. See [docs/xcodegen-vs-tuist.md](docs/xcodegen-vs-tuist.md).
</details>

<details>
<summary><b>What's MVVM? What's TCA? What's "Clean Architecture"?</b></summary>

They're patterns for organizing your code so it doesn't turn into spaghetti as the app grows. [docs/architecture-decisions.md](docs/architecture-decisions.md) explains each one with examples.
</details>

<details>
<summary><b>I generated a project — now what?</b></summary>

Open the generated folder in Xcode (`.xcworkspace` for Tuist, `.xcodeproj` for XcodeGen), hit Cmd+R, and the example screen runs in the iOS Simulator. Then start editing `Sources/` (single-target templates) or the appropriate `Modules/Features/<Name>/` folder (modular templates). The generated project's own `README.md` has a "what to edit first" section.
</details>

<details>
<summary><b>Can I add more features later? More platforms (Mac, Watch, Vision Pro)?</b></summary>

Yes. Each template's README documents how to add a feature. To add platforms:
```bash
ios-template add-platform --in ~/Projects/MyApp --platform visionos
```
Full guide: [docs/adding-platforms.md](docs/adding-platforms.md).
</details>

<details>
<summary><b>Do I need to know AI / Claude Code / Cursor to use this?</b></summary>

No. The `CLAUDE.md` and `.cursorrules` files are *optional* — if you use AI assistants, they'll be much better informed about your project. If you don't, ignore them; they're just markdown.
</details>

<details>
<summary><b>Is this only for iOS, or also Mac / Watch / Vision Pro?</b></summary>

The templates default to iPhone + iPad to keep code signing simple. macOS, visionOS, and macCatalyst are one CLI command away (`ios-template add-platform`). Apple Watch needs its own target — see [docs/adding-platforms.md](docs/adding-platforms.md).
</details>

<details>
<summary><b>I'm not on macOS. Can I use this?</b></summary>

iOS development requires macOS and Xcode (Apple's IDE). The CLI is portable Bash, but the generated projects need `xcodebuild`, `xcodegen`, or `tuist` to compile — all of which are macOS-only.
</details>

## Documentation map

| File | What's in it |
|------|--------------|
| [docs/getting-started.md](docs/getting-started.md) | **Start here if iOS is new to you.** Installs, first project, what each file does. |
| [docs/concepts.md](docs/concepts.md) | Plain-language glossary: Xcode, Tuist, MVVM, modules, all the jargon. |
| [docs/architecture-decisions.md](docs/architecture-decisions.md) | The 4 architectures explained with code sketches + when to pick each. |
| [docs/xcodegen-vs-tuist.md](docs/xcodegen-vs-tuist.md) | XcodeGen vs Tuist tradeoffs and a migration guide. |
| [docs/adding-platforms.md](docs/adding-platforms.md) | How to ship to Mac, Vision Pro, Apple Watch, widgets. |
| `templates/<bs>/<arch>/README.md` | Per-template tour — what's in it, what to edit first. |
| `CLAUDE.md` (this repo) | AI-assistant instructions for working on the *templates themselves*. |

## What the CLI does, under the hood

`ios-template new` performs these steps:

1. Copies the chosen template tree to `--output`
2. Adds **shared assets** from `shared/` — SwiftLint config, `.gitignore`, AI agent files, GitHub Actions, mise pin
3. Picks the right `setup.sh` for the build system (XcodeGen vs Tuist)
4. Substitutes placeholders (`__APP_NAME__` → your app name, etc.) throughout every file
5. Renames `__APP_NAME__App.swift` etc. to use the real app name
6. (Optional) `git init` + first commit
7. (Optional) Runs `./setup.sh` inside the generated project (generates the Xcode project)

## Repo layout

```
.
├── README.md                              # you are here
├── setup.sh                               # one-time installer for this tool
├── bin/ios-template                       # the CLI itself (pure Bash)
├── templates/                             # the 8 templates (the source of what gets copied)
│   ├── xcodegen/{simple-mvvm, modular-mvvm, clean-mvvm-repository, modular-tca}/
│   └── tuist/   {simple-mvvm, modular-mvvm, clean-mvvm-repository, modular-tca}/
├── shared/                                # files added to *every* generated project
│   ├── ai/                                # CLAUDE.md, AGENTS.md, .cursorrules, .claude/
│   ├── linting/                           # .swiftlint.yml, .swiftformat
│   ├── git/.gitignore
│   ├── github/workflows/ci.yml
│   ├── setup-xcodegen.sh.template
│   ├── setup-tuist.sh.template
│   └── mise.toml.template, .editorconfig
└── docs/                                  # the guides linked above
```

## Reference projects

The templates are modeled on real production iOS apps:

- [**parrotalk-ios**](../../iOS/parrotalk-ios) — Tuist, modular Clean Architecture + MVVM. Ships to iPhone, iPad, Apple Watch, Mac, and Vision Pro from one codebase.
- [**Lunavo**](../../../Works/Djavaweb/Lunavo) — XcodeGen, single-target. Simpler real-world example.

The shapes in `templates/tuist/modular-mvvm/Tuist/ProjectDescriptionHelpers/` and `templates/xcodegen/simple-mvvm/project.yml` come directly from those projects.

## Contributing

Want to add a 9th template (e.g., MVI, or Redux-Swift)?

1. Copy an existing template directory under `templates/<build-system>/<architecture-key>/`
2. Update `template.json` (the metadata the CLI reads)
3. Add a per-template `README.md`
4. Smoke-test:
   ```bash
   ./bin/ios-template new \
     --build-system <bs> --architecture <key> \
     --name SmokeTest --bundle-id com.example.smoke --org "Test" \
     --output /tmp/smoke-test-$$ --no-setup --no-git -y
   ```

## License

These templates are scaffolding only. When you generate a real project, pick your own license.

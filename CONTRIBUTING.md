# Contributing to swift-template

Thanks for working on this repo. This doc covers how we develop, branch, commit, and ship.

## Branching: trunk-based development

We use **trunk-based development**, not GitFlow.

```
                v2.0.0          v2.1.0         v2.2.0      ← release tags (annotated)
                  │               │              │
  ────●─────●─────●────●─────●────●─────●────●───●───────► main  (the trunk)
            │          │          │          │
            └ feature/  └ feature/ └ feature/ └ feature/  (short-lived, merge fast)
              ai-codex    ipados     cd-script   localize
```

The rules:

1. **One long-lived branch: `main`.** No `develop`, no `release/*`, no `hotfix/*`.
2. **Short-lived feature branches** for non-trivial work. Branch name: `feature/<short-slug>` (or `fix/`, `docs/`, `chore/`). **Merge within ≤ 1–2 days.**
3. **Trivial commits go straight to `main`.** Typos, doc nits, formatting — no branch needed.
4. **Squash on merge** (or fast-forward for clean linear history). No merge commits for feature branches.
5. **Tags mark releases.** Annotated tags (`git tag -a v2.1.0 -m "…"`). No `release/*` branches.
6. **Never force-push to `main`.** Force-pushing your own feature branch is fine before merging.

### Day-in-the-life

**Tiny change** (typo, single-line tweak):
```bash
git pull --rebase
# edit
git commit -am "docs(readme): fix typo in quickstart"
git push
```

**Non-trivial change** (new template, new CLI flag, new variant):
```bash
git switch -c feature/add-mvi-template
# work, test, commit (any number of WIP commits)
./bin/ios-template new --build-system tuist --architecture mvi \
  --name SmokeTest --output /tmp/smoke-$$ --no-git --no-setup -y
# squash + merge to main
git switch main
git pull --rebase
git merge --squash feature/add-mvi-template
git commit -m "feat(templates): add MVI architecture"
git push
git branch -D feature/add-mvi-template
```

## Commit messages

We follow **conventional commits**. The format:

```
<type>(<scope>): <short summary in imperative mood>

<optional body explaining WHY, not WHAT — the diff already shows what>

<optional footer for breaking changes, refs, co-authors>
```

### Types

| Type | When |
|------|------|
| `feat` | New user-facing capability (a flag, a template, a variant) |
| `fix` | Bug fix |
| `refactor` | Code reshape that doesn't change behavior |
| `docs` | Documentation only |
| `chore` | Tooling, config, gitignore, dependency bumps |
| `test` | Tests only |
| `perf` | Performance improvement |

### Scopes (this repo)

| Scope | What it touches |
|-------|-----------------|
| `cli` | `bin/ios-template` |
| `templates` | `templates/<bs>/<arch>/` |
| `templates/<arch>` | A specific template, e.g. `feat(templates/modular-tca): …` |
| `shared` | `shared/` (any) |
| `shared/ai` | AI agent files |
| `shared/ci` | CI provider files |
| `shared/variants` | Optional variants |
| `docs` | `docs/` or top-level README |
| `setup` | Repo-level `setup.sh` |

### Good examples

```
feat(cli): add --analytics flag for Sentry/Crashlytics scaffolding
fix(cli): rename_app_name_paths no longer breaks on nested __APP_NAME__ dirs
refactor(templates/clean-mvvm-repository): collapse use-case + repo seams
docs(getting-started): clarify how to install Xcode CLI tools
chore(gitignore): also ignore /Pods/ (carthage legacy)
```

### Bad examples

```
update stuff                         # too vague
fixed bug                            # which bug? in what file?
WIP                                  # don't merge WIP — squash it first
[skip ci] feat: new thing            # skip-ci tags belong in PR descriptions
```

## Pull request flow

For solo work, you can self-merge after a smoke test. For multi-dev:

1. Open a PR against `main`
2. CI runs (see `.github/workflows/`)
3. At least one reviewer must approve
4. Squash-merge (preserves the conventional-commit subject)
5. Delete the feature branch

## What to smoke-test before merging

Mandatory:

```bash
./bin/ios-template list                          # sanity
./bin/ios-template doctor                        # env check

# Spot-check at least one scaffold per change category
SMOKE=/tmp/smoke-$$
./bin/ios-template new \
  --build-system tuist --architecture clean-mvvm-repository \
  --name Smoke --bundle-id com.example.smoke --org "Test" \
  --output "$SMOKE" --no-git --no-setup -y

# Verify zero leftover placeholders
grep -rIl '__[A-Z_]\+__' "$SMOKE" && echo "FAIL: placeholders" || echo "OK"
```

If you changed templates: scaffold and visually inspect the file tree. If you changed the CLI: try multiple flag combos.

## Tags & releases

We bump versions using **semver**:

- `vMAJOR.MINOR.PATCH`
- Major: breaking change to the CLI flags or scaffolded project shape
- Minor: new optional flag, new template, new variant — all backwards-compatible
- Patch: bug fix, doc improvement, internal refactor

Tagging:

```bash
git tag -a v2.1.0 -m "v2.1.0 — add MVI template"
git push --tags
```

Tags live forever; branches don't. To "go back" to a release, `git checkout v2.0.0`.

## Things we don't do

- **No GitFlow.** No `develop`, no `release/*` branch, no `hotfix/*`. We don't ship enough to need them.
- **No squashed-and-rebased master with a fake linear history that loses context.** Either keep the small commits or write a clear squash summary; don't both.
- **No long-lived feature branches.** If you can't merge inside 2 days, you're integrating too late.
- **No force-pushing `main`.** Ever. Even if you broke it. Add a revert commit.
- **No skipping conventional commits.** They show up in changelogs, releases, and `git log`.

## Workflow vs the projects we generate

A reminder: this repo (`swift-template`) is the *tool that scaffolds iOS apps*. The trunk-based rules above apply to **this repo**. The iOS apps we generate are free to follow their own branching model — that's up to whoever owns the generated app.

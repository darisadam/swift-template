#!/usr/bin/env bash
#
# setup.sh — repo-level setup for the iOS Templates monorepo.
#
# - Verifies (and optionally installs) the toolchain
# - Installs the `ios-template` CLI to a directory on your PATH
# - Tidies the repo (removes generated artifacts, dead files)
#
# Usage:
#   ./setup.sh                # interactive: prompts where to symlink the CLI
#   ./setup.sh --install      # install CLI to ~/.local/bin without prompting
#   ./setup.sh --tidy         # only clean up generated/temp files
#   ./setup.sh --uninstall    # remove the CLI symlink
#   ./setup.sh --doctor       # only run environment checks
#

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
  YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
  RED=''; GREEN=''; BLUE=''; YELLOW=''; CYAN=''; BOLD=''; DIM=''; NC=''
fi

log_info()    { printf "${CYAN}▸${NC} %s\n" "$*"; }
log_success() { printf "${GREEN}✓${NC} %s\n" "$*"; }
log_warn()    { printf "${YELLOW}⚠${NC}  %s\n" "$*"; }
log_error()   { printf "${RED}✗${NC} %s\n" "$*" >&2; }
log_step()    { printf "\n${BOLD}${BLUE}━━ %s ━━${NC}\n" "$*"; }

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CLI_PATH="$REPO_ROOT/bin/ios-template"

usage() {
  cat <<EOF
${BOLD}iOS Templates setup${NC}

Usage:
  ./setup.sh                 Interactive setup (install + verify + tidy)
  ./setup.sh --install       Install the ios-template CLI to ~/.local/bin
  ./setup.sh --tidy          Remove generated/temp files in this repo
  ./setup.sh --uninstall     Remove the ios-template CLI symlink
  ./setup.sh --doctor        Only run environment checks
  ./setup.sh --help          Show this message
EOF
}

# ── Doctor ───────────────────────────────────────────────────────────────────
doctor() {
  log_step "Environment check"

  local missing_required=0
  local missing_optional=0

  if command -v xcodebuild >/dev/null 2>&1; then
    log_success "Xcode: $(xcodebuild -version | head -1)"
  else
    log_error "Xcode Command Line Tools not found. Run: xcode-select --install"
    missing_required=1
  fi

  if command -v git >/dev/null 2>&1; then
    log_success "git: $(git --version)"
  else
    log_error "git not found"
    missing_required=1
  fi

  if command -v python3 >/dev/null 2>&1; then
    log_success "python3: $(python3 --version)"
  else
    log_warn "python3 not found — needed for 'ios-template add-platform' (XcodeGen)"
    missing_optional=1
  fi

  if command -v swiftlint >/dev/null 2>&1; then
    log_success "SwiftLint: $(swiftlint version)"
  else
    log_warn "SwiftLint not installed (the per-project setup.sh will install it)"
    missing_optional=1
  fi

  if command -v tuist >/dev/null 2>&1; then
    log_success "Tuist: $(tuist version 2>/dev/null || echo unknown)"
  else
    log_warn "Tuist not installed (only required for Tuist-based templates)"
    missing_optional=1
  fi

  if command -v xcodegen >/dev/null 2>&1; then
    log_success "XcodeGen: $(xcodegen --version 2>/dev/null | head -1 || echo unknown)"
  else
    log_warn "XcodeGen not installed (only required for XcodeGen-based templates)"
    missing_optional=1
  fi

  if command -v mise >/dev/null 2>&1; then
    log_success "mise: $(mise --version)"
  else
    log_warn "mise not installed (recommended for Tuist version pinning)"
    missing_optional=1
  fi

  echo
  if (( missing_required != 0 )); then
    log_error "Some required tools are missing. Install them and re-run."
    return 1
  fi
  if (( missing_optional != 0 )); then
    log_warn "Some optional tools are missing — that's fine; per-project setup.sh will install on demand."
  else
    log_success "All tools present."
  fi
  return 0
}

# ── Install CLI ──────────────────────────────────────────────────────────────
install_cli() {
  log_step "Install ios-template CLI"

  if [[ ! -x "$CLI_PATH" ]]; then
    chmod +x "$CLI_PATH"
    log_info "Marked $CLI_PATH executable"
  fi

  local target_dir="${1:-}"
  if [[ -z "$target_dir" ]]; then
    # Prefer ~/.local/bin if it exists on PATH; fall back to /usr/local/bin.
    if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || [[ -d "$HOME/.local/bin" ]]; then
      target_dir="$HOME/.local/bin"
    elif [[ -w /usr/local/bin ]]; then
      target_dir="/usr/local/bin"
    else
      target_dir="$HOME/.local/bin"
    fi
  fi

  mkdir -p "$target_dir"
  local link="$target_dir/ios-template"
  if [[ -L "$link" || -e "$link" ]]; then
    log_info "Replacing existing $link"
    rm -f "$link"
  fi
  ln -s "$CLI_PATH" "$link"
  log_success "Symlinked $link → $CLI_PATH"

  if [[ ":$PATH:" != *":$target_dir:"* ]]; then
    log_warn "$target_dir is not on your PATH."
    echo
    echo "  Add this to your shell profile (~/.zshrc or ~/.bashrc):"
    printf "    ${BOLD}export PATH=\"%s:\$PATH\"${NC}\n" "$target_dir"
    echo
  fi

  echo
  log_success "Installed! Try: ${BOLD}ios-template list${NC}"
}

uninstall_cli() {
  log_step "Uninstall ios-template CLI"
  local found=0
  for dir in "$HOME/.local/bin" "/usr/local/bin" "/opt/homebrew/bin"; do
    local link="$dir/ios-template"
    if [[ -L "$link" ]]; then
      local target
      target="$(readlink "$link" 2>/dev/null || true)"
      if [[ "$target" == "$CLI_PATH" || "$target" == *"/Templates/bin/ios-template" ]]; then
        rm -f "$link"
        log_success "Removed $link"
        found=1
      else
        log_warn "Found $link but it doesn't point to this repo ($target). Skipping."
      fi
    fi
  done
  if (( found == 0 )); then
    log_warn "No ios-template symlinks found pointing at this repo."
  fi
}

# ── Tidy ─────────────────────────────────────────────────────────────────────
tidy_repo() {
  log_step "Tidy"

  local cleaned=0

  # macOS metadata
  find "$REPO_ROOT" -name ".DS_Store" -type f 2>/dev/null | while read -r f; do
    rm -f "$f"
    cleaned=$((cleaned+1))
  done
  log_info "Removed .DS_Store files"

  # sed backup files (.bak) left by older runs
  find "$REPO_ROOT" -name "*.bak" -type f 2>/dev/null | while read -r f; do
    rm -f "$f"
  done
  log_info "Removed *.bak files"

  # Vim/Emacs swap files
  find "$REPO_ROOT" -name "*.swp" -o -name "*.swo" -o -name "*~" 2>/dev/null | while read -r f; do
    rm -f "$f"
  done
  log_info "Removed editor swap files"

  # Verify directory shapes are intact
  for d in templates/xcodegen templates/tuist shared bin docs; do
    if [[ ! -d "$REPO_ROOT/$d" ]]; then
      log_error "Expected directory missing: $d"
    fi
  done

  log_success "Tidy complete"
}

# ── Argument dispatch ────────────────────────────────────────────────────────
ACTION="interactive"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --install)    ACTION="install"; shift ;;
    --tidy)       ACTION="tidy"; shift ;;
    --uninstall)  ACTION="uninstall"; shift ;;
    --doctor)     ACTION="doctor"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) log_error "Unknown flag: $1"; usage; exit 1 ;;
  esac
done

case "$ACTION" in
  install)   install_cli ;;
  tidy)      tidy_repo ;;
  uninstall) uninstall_cli ;;
  doctor)    doctor ;;
  interactive)
    printf "\n${BOLD}${BLUE}🦅 iOS Templates — setup${NC}\n"
    if ! doctor; then
      log_error "Resolve the issues above before continuing."
      exit 1
    fi
    install_cli
    tidy_repo
    echo
    printf "${GREEN}${BOLD}All set!${NC}\n"
    printf "Try ${BOLD}ios-template list${NC} or ${BOLD}ios-template new${NC} to scaffold an app.\n\n"
    ;;
esac

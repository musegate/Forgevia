#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifests/codex.json"
ASSETS_DIR="$ROOT_DIR/assets/codex"
OPENSPEC_ASSETS_DIR="$ROOT_DIR/assets/openspec"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
SUPERPOWERS_INSTALL_URL="https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md"
OPENSPEC_ROOT="${OPENSPEC_ROOT:-}"

usage() {
  cat <<EOF
Install Forgevia Codex assets.

Usage:
  $(basename "$0") [--help] [--install-openspec]

Manifest:
  $MANIFEST_PATH

Behavior:
  - verifies the Codex root at $CODEX_ROOT
  - optionally installs openspec if missing
  - overlays Forgevia-managed openspec customization
  - requires upstream superpowers to already exist
  - directly overlays Forgevia-managed assets into ~/.codex
EOF
}

log_info() {
  echo "ℹ️  $1"
}

log_step() {
  echo "🧱 $1"
}

log_success() {
  echo "✅ $1"
}

log_backup() {
  echo "💾 $1"
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "missing required command: $command_name" >&2
    exit 1
  fi
}

copy_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"
  rm -rf "$target_path"
  cp -R "$source_path" "$target_path"
}

backup_target_if_present() {
  local target_path="$1"
  local backup_path="${target_path}.forgevia.bak"

  if [[ ! -e "$target_path" ]]; then
    return
  fi

  rm -rf "$backup_path"
  cp -R "$target_path" "$backup_path"
  log_backup "Backed up $target_path -> $backup_path"
}

sync_path() {
  local source_path="$1"
  local target_path="$2"

  backup_target_if_present "$target_path"
  copy_path "$source_path" "$target_path"
}

install_openspec_if_missing() {
  if command -v openspec >/dev/null 2>&1; then
    log_info "openspec already installed: $(command -v openspec)"
    return
  fi

  log_step "openspec not found; installing with npm"
  npm install -g @fission-ai/openspec@latest
  log_success "Installed openspec from npm"
}

resolve_openspec_root() {
  if [[ -n "$OPENSPEC_ROOT" ]]; then
    echo "$OPENSPEC_ROOT"
    return
  fi

  local npm_global_root
  npm_global_root="$(npm root -g)"
  echo "$npm_global_root/@fission-ai/openspec"
}

verify_superpowers_present() {
  if [[ -d "$CODEX_ROOT/superpowers" ]]; then
    return
  fi

  cat >&2 <<EOF
superpowers is not installed under $CODEX_ROOT/superpowers

Install it first with:
Fetch and follow instructions from $SUPERPOWERS_INSTALL_URL
EOF
  exit 1
}

overlay_assets() {
  log_step "Overlaying Forgevia-managed assets into $CODEX_ROOT"

  sync_path "$ASSETS_DIR/skills/forgevia" "$CODEX_ROOT/skills/forgevia"
  sync_path "$ASSETS_DIR/skills/forgevia-init" "$CODEX_ROOT/skills/forgevia-init"
  sync_path "$ASSETS_DIR/skills/forgevia-doctor" "$CODEX_ROOT/skills/forgevia-doctor"
  sync_path "$ASSETS_DIR/skills/forgevia-repair" "$CODEX_ROOT/skills/forgevia-repair"
  sync_path "$ASSETS_DIR/skills/forgevia-implement" "$CODEX_ROOT/skills/forgevia-implement"
  sync_path "$ASSETS_DIR/skills/forgevia-archive" "$CODEX_ROOT/skills/forgevia-archive"
  sync_path "$ASSETS_DIR/skills/forgevia-tasks" "$CODEX_ROOT/skills/forgevia-tasks"
  sync_path "$ASSETS_DIR/skills/forgevia-check-task" "$CODEX_ROOT/skills/forgevia-check-task"
  sync_path "$ASSETS_DIR/skills/forgevia-review" "$CODEX_ROOT/skills/forgevia-review"
  sync_path "$ASSETS_DIR/skills/forgevia-verify-web" "$CODEX_ROOT/skills/forgevia-verify-web"
  sync_path "$ASSETS_DIR/skills/forgevia-draw" "$CODEX_ROOT/skills/forgevia-draw"
  sync_path "$ASSETS_DIR/skills/mermaid-diagram-specialist" "$CODEX_ROOT/skills/mermaid-diagram-specialist"
  sync_path "$ASSETS_DIR/skills/playwright-interactive" "$CODEX_ROOT/skills/playwright-interactive"
  sync_path "$ASSETS_DIR/superpowers/skills/brainstorming/SKILL.md" "$CODEX_ROOT/superpowers/skills/brainstorming/SKILL.md"
  sync_path "$ASSETS_DIR/superpowers/skills/writing-plans/SKILL.md" "$CODEX_ROOT/superpowers/skills/writing-plans/SKILL.md"
  sync_path "$ASSETS_DIR/superpowers/skills/executing-plans/SKILL.md" "$CODEX_ROOT/superpowers/skills/executing-plans/SKILL.md"
  sync_path "$ASSETS_DIR/superpowers/skills/subagent-driven-development" "$CODEX_ROOT/superpowers/skills/subagent-driven-development"
  sync_path "$ASSETS_DIR/superpowers/skills/requesting-code-review" "$CODEX_ROOT/superpowers/skills/requesting-code-review"
  log_success "Applied Forgevia-managed Codex assets"
}

overlay_openspec_assets() {
  local openspec_root
  openspec_root="$(resolve_openspec_root)"

  if [[ ! -d "$openspec_root" ]]; then
    echo "openspec install root not found: $openspec_root" >&2
    exit 1
  fi

  sync_path "$OPENSPEC_ASSETS_DIR/dist/core/config-prompts.js" "$openspec_root/dist/core/config-prompts.js"
  log_success "Applied openspec override: $openspec_root/dist/core/config-prompts.js"
}

main() {
  local should_install_openspec="false"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --install-openspec)
        should_install_openspec="true"
        shift
        ;;
      *)
        echo "unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  log_step "Forgevia Codex installer"
  require_command cp
  require_command rm
  require_command mkdir

  if [[ "$should_install_openspec" == "true" ]]; then
    require_command npm
    install_openspec_if_missing
  fi

  if command -v openspec >/dev/null 2>&1 || [[ -n "$OPENSPEC_ROOT" ]]; then
    overlay_openspec_assets
  fi

  mkdir -p "$CODEX_ROOT/skills"
  verify_superpowers_present
  log_success "Detected upstream superpowers at $CODEX_ROOT/superpowers"
  overlay_assets

  echo "🎉 Forgevia Codex install complete"
}

main "$@"

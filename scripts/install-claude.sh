#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifests/claude.json"
ASSETS_DIR="$ROOT_DIR/.claude"
CLAUDE_SUPERPOWERS_ASSETS_DIR="$ROOT_DIR/assets/claude/superpowers"
CLAUDE_ROOT="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE_SUPERPOWERS_ROOT="${CLAUDE_SUPERPOWERS_ROOT:-}"

usage() {
  cat <<EOF
Install Forgevia Claude assets.

Usage:
  $(basename "$0") [--help]

Manifest:
  $MANIFEST_PATH

Behavior:
  - verifies the Claude root at $CLAUDE_ROOT
  - installs Forgevia-managed Claude skills into ~/.claude
  - overlays selected Forgevia-managed superpowers skill overrides into the installed Claude superpowers plugin
EOF
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

resolve_superpowers_root() {
  if [[ -n "$CLAUDE_SUPERPOWERS_ROOT" ]]; then
    echo "$CLAUDE_SUPERPOWERS_ROOT"
    return
  fi

  local installed_plugins_path="$CLAUDE_ROOT/plugins/installed_plugins.json"
  if [[ ! -f "$installed_plugins_path" ]]; then
    echo ""
    return
  fi

  node -e '
    const fs = require("fs");
    const path = process.argv[1];
    const data = JSON.parse(fs.readFileSync(path, "utf8"));
    const entries = data.plugins?.["superpowers@superpowers-marketplace"];
    if (Array.isArray(entries)) {
      const userEntry = entries.find((entry) => entry.scope === "user" && entry.installPath);
      const anyEntry = entries.find((entry) => entry.installPath);
      const selected = userEntry || anyEntry;
      if (selected?.installPath) process.stdout.write(selected.installPath);
    }
  ' "$installed_plugins_path"
}

verify_superpowers_present() {
  local superpowers_root="$1"

  if [[ -n "$superpowers_root" && -d "$superpowers_root/skills" ]]; then
    return
  fi

  cat >&2 <<EOF
Claude superpowers plugin is not installed or could not be located.

Expected an installed plugin path from:
  $CLAUDE_ROOT/plugins/installed_plugins.json

Install the Claude superpowers plugin first, or set CLAUDE_SUPERPOWERS_ROOT manually.
EOF
  exit 1
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

remove_stale_backup() {
  local target_path="$1"
  local backup_path="${target_path}.forgevia.bak"

  rm -rf "$backup_path"
}

sync_path() {
  local source_path="$1"
  local target_path="$2"

  backup_target_if_present "$target_path"
  copy_path "$source_path" "$target_path"
  remove_stale_backup "$target_path"
}

overlay_assets() {
  log_step "Overlaying Forgevia-managed assets into $CLAUDE_ROOT"

  sync_path "$ASSETS_DIR/skills/forgevia-think" "$CLAUDE_ROOT/skills/forgevia-think"
  log_success "Applied Forgevia-managed Claude assets"
}

overlay_superpowers_assets() {
  local superpowers_root="$1"

  log_step "Overlaying Forgevia-managed superpowers overrides into $superpowers_root"

  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/brainstorming/SKILL.md" "$superpowers_root/skills/brainstorming/SKILL.md"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/writing-plans/SKILL.md" "$superpowers_root/skills/writing-plans/SKILL.md"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/subagent-driven-development" "$superpowers_root/skills/subagent-driven-development"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/requesting-code-review" "$superpowers_root/skills/requesting-code-review"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/executing-plans/SKILL.md" "$superpowers_root/skills/executing-plans/SKILL.md"
  log_success "Applied Forgevia-managed Claude superpowers overrides"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      *)
        echo "unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  log_step "Forgevia Claude installer"
  require_command cp
  require_command rm
  require_command mkdir
  require_command node

  mkdir -p "$CLAUDE_ROOT/skills"
  overlay_assets
  local superpowers_root
  superpowers_root="$(resolve_superpowers_root)"
  verify_superpowers_present "$superpowers_root"
  log_success "Detected Claude superpowers plugin at $superpowers_root"
  overlay_superpowers_assets "$superpowers_root"

  echo "🎉 Forgevia Claude install complete"
}

main "$@"

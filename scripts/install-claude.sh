#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifests/claude.json"
ASSETS_DIR="$ROOT_DIR/.claude"
CLAUDE_SUPERPOWERS_ASSETS_DIR="$ROOT_DIR/assets/claude/superpowers"
OPENSPEC_ASSETS_DIR="$ROOT_DIR/assets/openspec"
CLAUDE_ROOT="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE_SUPERPOWERS_ROOT="${CLAUDE_SUPERPOWERS_ROOT:-}"
OPENSPEC_ROOT="${OPENSPEC_ROOT:-}"

usage() {
  cat <<EOF
Install Forgevia Claude assets.

Usage:
  $(basename "$0") [--help] [--install-openspec]

Manifest:
  $MANIFEST_PATH

Behavior:
  - verifies the Claude root at $CLAUDE_ROOT
  - optionally installs openspec if missing
  - overlays Forgevia-managed openspec customization
  - installs Forgevia-managed Claude skills and commands into ~/.claude
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

log_info() {
  echo "ℹ️  $1"
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

In Claude Code, register the marketplace first:
  /plugin marketplace add obra/superpowers-marketplace

Then install the plugin from this marketplace:
  /plugin install superpowers@superpowers-marketplace

When Claude Code asks for the install scope, choose:
  user

If the plugin is already installed but stored elsewhere, set CLAUDE_SUPERPOWERS_ROOT manually.
EOF
  exit 1
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

install_openspec_if_missing() {
  if command -v openspec >/dev/null 2>&1; then
    log_info "openspec already installed: $(command -v openspec)"
    return
  fi

  log_step "openspec not found; installing with npm"
  npm install -g @fission-ai/openspec@latest
  log_success "Installed openspec from npm"
}

verify_openspec_present() {
  if command -v openspec >/dev/null 2>&1 || [[ -n "$OPENSPEC_ROOT" ]]; then
    return 0
  fi

  return 1
}

sync_path() {
  local source_path="$1"
  local target_path="$2"

  backup_target_if_present "$target_path"
  copy_path "$source_path" "$target_path"
  remove_stale_backup "$target_path"
}

managed_skill_paths() {
  find "$ASSETS_DIR/skills" -mindepth 1 -maxdepth 1 -type d | sort
}

managed_command_paths() {
  if [[ ! -d "$ASSETS_DIR/commands" ]]; then
    return
  fi

  find "$ASSETS_DIR/commands" -mindepth 1 -maxdepth 1 -type d | sort
}

overlay_assets() {
  log_step "Overlaying Forgevia-managed assets into $CLAUDE_ROOT"

  mkdir -p "$CLAUDE_ROOT/skills" "$CLAUDE_ROOT/commands"

  local source_path
  local target_name

  while IFS= read -r source_path; do
    target_name="$(basename "$source_path")"
    sync_path "$source_path" "$CLAUDE_ROOT/skills/$target_name"
  done < <(managed_skill_paths)

  while IFS= read -r source_path; do
    target_name="$(basename "$source_path")"
    sync_path "$source_path" "$CLAUDE_ROOT/commands/$target_name"
  done < <(managed_command_paths)

  log_success "Applied Forgevia-managed Claude assets"
}

overlay_openspec_assets() {
  local openspec_root
  openspec_root="$(resolve_openspec_root)"

  if [[ ! -d "$openspec_root" ]]; then
    echo "openspec install root not found: $openspec_root" >&2
    exit 1
  fi

  sync_path "$OPENSPEC_ASSETS_DIR/dist/core/config-prompts.js" "$openspec_root/dist/core/config-prompts.js"
  sync_path "$OPENSPEC_ASSETS_DIR/dist/core/templates/workflows/propose.js" "$openspec_root/dist/core/templates/workflows/propose.js"
  log_success "Applied openspec override: $openspec_root/dist/core/config-prompts.js"
  log_success "Applied openspec override: $openspec_root/dist/core/templates/workflows/propose.js"
}

overlay_superpowers_assets() {
  local superpowers_root="$1"

  log_step "Overlaying Forgevia-managed superpowers overrides into $superpowers_root"

  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/brainstorming/SKILL.md" "$superpowers_root/skills/brainstorming/SKILL.md"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/writing-plans/SKILL.md" "$superpowers_root/skills/writing-plans/SKILL.md"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/subagent-driven-development" "$superpowers_root/skills/subagent-driven-development"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/requesting-code-review" "$superpowers_root/skills/requesting-code-review"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/test-driven-development/SKILL.md" "$superpowers_root/skills/test-driven-development/SKILL.md"
  sync_path "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/executing-plans/SKILL.md" "$superpowers_root/skills/executing-plans/SKILL.md"
  log_success "Applied Forgevia-managed Claude superpowers overrides"
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

  log_step "Forgevia Claude installer"
  require_command cp
  require_command find
  require_command rm
  require_command mkdir
  require_command node
  require_command npm

  if [[ "$should_install_openspec" == "true" ]]; then
    install_openspec_if_missing
  fi

  if verify_openspec_present; then
    overlay_openspec_assets
  else
    log_info "openspec not found; skipping Forgevia-managed openspec overrides"
  fi

  overlay_assets
  local superpowers_root
  superpowers_root="$(resolve_superpowers_root)"
  verify_superpowers_present "$superpowers_root"
  log_success "Detected Claude superpowers plugin at $superpowers_root"
  overlay_superpowers_assets "$superpowers_root"

  echo "🎉 Forgevia Claude install complete"
}

main "$@"

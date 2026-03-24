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
Check Forgevia Claude managed assets.

Usage:
  $(basename "$0") [--help] [--repair]

Manifest:
  $MANIFEST_PATH

Checks:
  - ~/.claude/skills/forgevia-think
  - Forgevia-managed Claude superpowers overrides
  - content drift against Forgevia-owned copies
EOF
}

log_info() {
  echo "ℹ️  $1"
}

log_success() {
  echo "✅ $1"
}

log_backup() {
  echo "💾 $1"
}

print_status() {
  local status="$1"
  local path="$2"

  case "$status" in
    OK)
      echo "✅ OK    $path"
      ;;
    MISS)
      echo "⚠️  MISS  $path"
      ;;
    DRIFT)
      echo "❌ DRIFT $path"
      ;;
  esac
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

compare_path() {
  local source_path="$1"
  local target_path="$2"

  if [[ ! -e "$target_path" ]]; then
    print_status "MISS" "$target_path"
    return 1
  fi

  if [[ -d "$source_path" ]]; then
    if diff -qr "$source_path" "$target_path" >/dev/null 2>&1; then
      print_status "OK" "$target_path"
      return 0
    fi

    print_status "DRIFT" "$target_path"
    return 1
  fi

  if cmp -s "$source_path" "$target_path"; then
    print_status "OK" "$target_path"
    return 0
  fi

  print_status "DRIFT" "$target_path"
  return 1
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

repair_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"
  backup_target_if_present "$target_path"
  rm -rf "$target_path"
  cp -R "$source_path" "$target_path"
  remove_stale_backup "$target_path"
  log_success "Repaired $target_path"
}

main() {
  local repair_requested="false"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --repair)
        repair_requested="true"
        shift
        ;;
      *)
        echo "unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  local unhealthy=0
  local healthy=0
  local repaired=0
  local superpowers_root
  local managed_pairs=()

  echo "🔎 Forgevia Claude doctor"
  if [[ "$repair_requested" == "true" ]]; then
    echo "🛠️ Repairing drifted or missing assets"
  fi

  superpowers_root="$(resolve_superpowers_root)"
  if [[ -z "$superpowers_root" ]]; then
    print_status "MISS" "$CLAUDE_ROOT/plugins/installed_plugins.json"
    log_info "Claude superpowers plugin could not be resolved. Install the plugin first or set CLAUDE_SUPERPOWERS_ROOT."
    unhealthy=1
  else
    managed_pairs+=(
      "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/brainstorming/SKILL.md::$superpowers_root/skills/brainstorming/SKILL.md"
      "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/writing-plans/SKILL.md::$superpowers_root/skills/writing-plans/SKILL.md"
      "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/executing-plans/SKILL.md::$superpowers_root/skills/executing-plans/SKILL.md"
      "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/subagent-driven-development::$superpowers_root/skills/subagent-driven-development"
      "$CLAUDE_SUPERPOWERS_ASSETS_DIR/skills/requesting-code-review::$superpowers_root/skills/requesting-code-review"
    )
  fi

  managed_pairs+=(
    "$ASSETS_DIR/skills/forgevia-think::$CLAUDE_ROOT/skills/forgevia-think"
  )

  for pair in "${managed_pairs[@]}"
  do
    local source_path="${pair%%::*}"
    local target_path="${pair#*::}"

    if compare_path "$source_path" "$target_path"; then
      ((healthy+=1))
      continue
    fi

    if [[ "$repair_requested" == "true" ]]; then
      repair_path "$source_path" "$target_path"
      ((repaired+=1))
      continue
    fi

    unhealthy=1
  done

  echo "📋 Summary"
  echo "💚 Healthy assets: $healthy"
  echo "🛠️ Repaired assets: $repaired"
  if [[ "$unhealthy" -ne 0 ]]; then
    echo "💥 Unhealthy assets detected"
  else
    echo "✨ No drift detected"
  fi

  if [[ "$repair_requested" == "true" ]]; then
    echo "Forgevia Claude doctor repair complete"
    exit 0
  fi

  if [[ "$unhealthy" -ne 0 ]]; then
    echo "Forgevia Claude doctor found missing or drifted managed assets" >&2
    exit 1
  fi

  echo "Forgevia Claude doctor passed"
}

main "$@"

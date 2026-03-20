#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifests/codex.json"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
ASSETS_DIR="$ROOT_DIR/assets/codex"
OPENSPEC_ASSETS_DIR="$ROOT_DIR/assets/openspec"
OPENSPEC_ROOT="${OPENSPEC_ROOT:-}"

usage() {
  cat <<EOF
Check Forgevia Codex managed assets.

Usage:
  $(basename "$0") [--help] [--repair]

Manifest:
  $MANIFEST_PATH

Checks:
  - openspec config override
  - ~/.codex/skills/forgevia
  - ~/.codex/skills/playwright-interactive
  - Forgevia-managed superpowers overrides
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

resolve_openspec_root() {
  if [[ -n "$OPENSPEC_ROOT" ]]; then
    echo "$OPENSPEC_ROOT"
    return
  fi

  local npm_global_root
  npm_global_root="$(npm root -g)"
  echo "$npm_global_root/@fission-ai/openspec"
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

repair_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"
  backup_target_if_present "$target_path"
  rm -rf "$target_path"
  cp -R "$source_path" "$target_path"
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
  local openspec_root

  echo "🔎 Forgevia Codex doctor"
  if [[ "$repair_requested" == "true" ]]; then
    echo "🛠️ Repairing drifted or missing assets"
  fi
  openspec_root="$(resolve_openspec_root)"

  for pair in \
    "$OPENSPEC_ASSETS_DIR/dist/core/config-prompts.js::$openspec_root/dist/core/config-prompts.js" \
    "$ASSETS_DIR/skills/forgevia::$CODEX_ROOT/skills/forgevia" \
    "$ASSETS_DIR/skills/mermaid-diagram-specialist::$CODEX_ROOT/skills/mermaid-diagram-specialist" \
    "$ASSETS_DIR/skills/playwright-interactive::$CODEX_ROOT/skills/playwright-interactive" \
    "$ASSETS_DIR/superpowers/skills/brainstorming/SKILL.md::$CODEX_ROOT/superpowers/skills/brainstorming/SKILL.md" \
    "$ASSETS_DIR/superpowers/skills/writing-plans/SKILL.md::$CODEX_ROOT/superpowers/skills/writing-plans/SKILL.md" \
    "$ASSETS_DIR/superpowers/skills/executing-plans/SKILL.md::$CODEX_ROOT/superpowers/skills/executing-plans/SKILL.md" \
    "$ASSETS_DIR/superpowers/skills/subagent-driven-development::$CODEX_ROOT/superpowers/skills/subagent-driven-development" \
    "$ASSETS_DIR/superpowers/skills/requesting-code-review::$CODEX_ROOT/superpowers/skills/requesting-code-review"
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
    echo "Forgevia Codex doctor repair complete"
    exit 0
  fi

  if [[ "$unhealthy" -ne 0 ]]; then
    echo "Forgevia Codex doctor found missing or drifted managed assets" >&2
    exit 1
  fi

  echo "Forgevia Codex doctor passed"
}

main "$@"

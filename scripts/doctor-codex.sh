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
  $(basename "$0") [--help]

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
    echo "MISS $target_path"
    return 1
  fi

  if [[ -d "$source_path" ]]; then
    if diff -qr "$source_path" "$target_path" >/dev/null 2>&1; then
      echo "OK   $target_path"
      return 0
    fi

    echo "DRIFT $target_path"
    return 1
  fi

  if cmp -s "$source_path" "$target_path"; then
    echo "OK   $target_path"
    return 0
  fi

  echo "DRIFT $target_path"
  return 1
}

main() {
  case "${1:-}" in
    --help|-h)
      usage
      exit 0
      ;;
    "")
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac

  local unhealthy=0
  local openspec_root

  openspec_root="$(resolve_openspec_root)"

  compare_path "$OPENSPEC_ASSETS_DIR/dist/core/config-prompts.js" "$openspec_root/dist/core/config-prompts.js" || unhealthy=1
  compare_path "$ASSETS_DIR/skills/forgevia" "$CODEX_ROOT/skills/forgevia" || unhealthy=1
  compare_path "$ASSETS_DIR/skills/playwright-interactive" "$CODEX_ROOT/skills/playwright-interactive" || unhealthy=1
  compare_path "$ASSETS_DIR/superpowers/skills/brainstorming/SKILL.md" "$CODEX_ROOT/superpowers/skills/brainstorming/SKILL.md" || unhealthy=1
  compare_path "$ASSETS_DIR/superpowers/skills/writing-plans/SKILL.md" "$CODEX_ROOT/superpowers/skills/writing-plans/SKILL.md" || unhealthy=1
  compare_path "$ASSETS_DIR/superpowers/skills/executing-plans/SKILL.md" "$CODEX_ROOT/superpowers/skills/executing-plans/SKILL.md" || unhealthy=1
  compare_path "$ASSETS_DIR/superpowers/skills/subagent-driven-development" "$CODEX_ROOT/superpowers/skills/subagent-driven-development" || unhealthy=1
  compare_path "$ASSETS_DIR/superpowers/skills/requesting-code-review" "$CODEX_ROOT/superpowers/skills/requesting-code-review" || unhealthy=1

  if [[ "$unhealthy" -ne 0 ]]; then
    echo "Forgevia Codex doctor found missing or drifted managed assets" >&2
    exit 1
  fi

  echo "Forgevia Codex doctor passed"
}

main "$@"

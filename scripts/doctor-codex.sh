#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifests/codex.json"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"

usage() {
  cat <<EOF
Check Forgevia Codex managed assets.

Usage:
  $(basename "$0") [--help]

Manifest:
  $MANIFEST_PATH

Checks:
  - ~/.codex/skills/forgevia
  - ~/.codex/skills/playwright-interactive
  - Forgevia-managed superpowers overrides
EOF
}

check_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "OK   $path"
    return 0
  fi

  echo "MISS $path"
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

  local missing=0

  check_path "$CODEX_ROOT/skills/forgevia" || missing=1
  check_path "$CODEX_ROOT/skills/playwright-interactive" || missing=1
  check_path "$CODEX_ROOT/superpowers/skills/brainstorming/SKILL.md" || missing=1
  check_path "$CODEX_ROOT/superpowers/skills/writing-plans/SKILL.md" || missing=1
  check_path "$CODEX_ROOT/superpowers/skills/executing-plans/SKILL.md" || missing=1
  check_path "$CODEX_ROOT/superpowers/skills/subagent-driven-development/SKILL.md" || missing=1
  check_path "$CODEX_ROOT/superpowers/skills/requesting-code-review/SKILL.md" || missing=1

  if [[ "$missing" -ne 0 ]]; then
    echo "Forgevia Codex doctor found missing managed assets" >&2
    exit 1
  fi

  echo "Forgevia Codex doctor passed"
}

main "$@"

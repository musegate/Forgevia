#!/usr/bin/env bash

set -euo pipefail

DEFAULT_TOOLS="codex,claude"

usage() {
  cat <<EOF
Bootstrap OpenSpec in the current project.

Usage:
  $(basename "$0") [--help] [--tools codex|claude|codex,claude] [project_dir]

Behavior:
  - checks whether OpenSpec is already initialized in the target directory
  - runs openspec init only when initialization is missing
  - does not modify project source files beyond OpenSpec's own initialization
EOF
}

normalize_tools() {
  local tools="$1"

  case "$tools" in
    codex|claude|codex,claude)
      echo "$tools"
      ;;
    claude,codex)
      echo "codex,claude"
      ;;
    *)
      echo "unsupported --tools value: $tools" >&2
      echo "expected one of: codex, claude, codex,claude" >&2
      exit 1
      ;;
  esac
}

main() {
  local tools="$DEFAULT_TOOLS"
  local project_dir="."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --tools)
        if [[ $# -lt 2 ]]; then
          echo "--tools requires a value" >&2
          exit 1
        fi
        tools="$(normalize_tools "$2")"
        shift 2
        ;;
      *)
        project_dir="$1"
        shift
        ;;
    esac
  done

  if ! command -v openspec >/dev/null 2>&1; then
    echo "openspec is not installed or not on PATH" >&2
    exit 1
  fi

  if [[ -d "$project_dir/openspec" ]]; then
    echo "OpenSpec already initialized in $project_dir"
    exit 0
  fi

  echo "Running openspec init --tools $tools $project_dir"
  openspec init --tools "$tools" "$project_dir"
  echo "Project bootstrap complete"
}

main "$@"

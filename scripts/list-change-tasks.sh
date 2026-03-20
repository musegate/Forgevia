#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<EOF
List unfinished tasks for active OpenSpec changes.

Usage:
  $(basename "$0") [--help] [project_dir]

Behavior:
  - scans openspec/changes under the target project
  - ignores archived changes
  - sorts active changes by change creation time ascending
  - prints only unfinished checklist items from tasks.md
EOF
}

project_dir="${1:-.}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

changes_root="$project_dir/openspec/changes"

if [[ ! -d "$changes_root" ]]; then
  echo "openspec/changes not found under $project_dir" >&2
  exit 1
fi

echo "📋 Active change tasks"

tmp_list="$(mktemp)"
trap 'rm -f "$tmp_list"' EXIT

find "$changes_root" -mindepth 1 -maxdepth 1 -type d ! -name archive | while read -r change_dir; do
  if [[ ! -f "$change_dir/.openspec.yaml" ]]; then
    continue
  fi

  timestamp="$(stat -f '%m' "$change_dir/.openspec.yaml")"
  printf '%s\t%s\n' "$timestamp" "$change_dir" >> "$tmp_list"
done

printed=0

while IFS=$'\t' read -r _timestamp change_dir; do
  tasks_file="$change_dir/tasks.md"
  if [[ ! -f "$tasks_file" ]]; then
    continue
  fi

  unfinished="$(rg '^- \[ \] ' "$tasks_file" || true)"
  if [[ -z "$unfinished" ]]; then
    continue
  fi

  change_name="$(basename "$change_dir")"
  echo
  echo "🗂️ $change_name"
  echo "📄 $tasks_file"
  printf '%s\n' "$unfinished"
  printed=1
done < <(sort -n "$tmp_list")

if [[ "$printed" -eq 0 ]]; then
  echo
  echo "✨ No unfinished tasks in active changes"
fi

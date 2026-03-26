#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert_file_contains() {
  local path="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$path"; then
    echo "expected $path to contain: $needle" >&2
    exit 1
  fi
}

for path in \
  "$ROOT_DIR/.claude/skills/mermaid-diagram-specialist/SKILL.md" \
  "$ROOT_DIR/assets/codex/skills/mermaid-diagram-specialist/SKILL.md"
do
  assert_file_contains "$path" "Write notes in Chinese so readers can understand each key"
  assert_file_contains "$path" "What to annotate**: key business actions, critical intermediate steps,"
  assert_file_contains "$path" "Keep the diagram readable: annotate enough to explain the"
  assert_file_contains "$path" "flow, but do not attach a note to every arrow."
  assert_file_contains "$path" "Key methods and critical steps annotated with concise Chinese \`Note\`"
  assert_file_contains "$path" "without making the diagram bloated"
done

for path in \
  "$ROOT_DIR/.claude/skills/forgevia-draw/SKILL.md" \
  "$ROOT_DIR/assets/codex/skills/forgevia-draw/SKILL.md"
do
  assert_file_contains "$path" "Request concise Chinese notes for key methods and critical intermediate steps."
  assert_file_contains "$path" "Optimize for fast understanding, not maximum annotation density."
done

echo "draw skill docs test passed"

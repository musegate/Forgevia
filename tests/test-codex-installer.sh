#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-codex.sh"
DOCTOR="$ROOT_DIR/scripts/doctor-codex.sh"
MANIFEST="$ROOT_DIR/manifests/codex.json"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "expected output to contain: $needle" >&2
    exit 1
  fi
}

test_file_exists() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "expected file to exist: $path" >&2
    exit 1
  fi
}

assert_exit_code() {
  local actual="$1"
  local expected="$2"
  if [[ "$actual" != "$expected" ]]; then
    echo "expected exit code $expected but got $actual" >&2
    exit 1
  fi
}

test_file_exists "$MANIFEST"
test_file_exists "$INSTALLER"
test_file_exists "$DOCTOR"

installer_help="$("$INSTALLER" --help)"
doctor_help="$("$DOCTOR" --help)"

assert_contains "$installer_help" "Install Forgevia Codex assets"
assert_contains "$installer_help" "$MANIFEST"
assert_contains "$doctor_help" "Check Forgevia Codex managed assets"
assert_contains "$doctor_help" "$MANIFEST"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export CODEX_HOME="$tmp_dir/.codex"
export OPENSPEC_ROOT="$tmp_dir/openspec"
mkdir -p "$CODEX_HOME/superpowers/skills/brainstorming"
mkdir -p "$CODEX_HOME/superpowers/skills/writing-plans"
mkdir -p "$CODEX_HOME/superpowers/skills/executing-plans"
mkdir -p "$CODEX_HOME/superpowers/skills/subagent-driven-development"
mkdir -p "$CODEX_HOME/superpowers/skills/requesting-code-review"
mkdir -p "$OPENSPEC_ROOT/dist/core"
printf 'export function serializeConfig() { return \"wrong\"; }\n' > "$OPENSPEC_ROOT/dist/core/config-prompts.js"

installer_output="$("$INSTALLER")"
assert_contains "$installer_output" "🧱 Forgevia Codex installer"
assert_contains "$installer_output" "✅ Applied openspec override"
assert_contains "$installer_output" "✅ Applied Forgevia-managed Codex assets"
assert_contains "$installer_output" "🎉 Forgevia Codex install complete"

doctor_output="$("$DOCTOR")"
assert_contains "$doctor_output" "🔎 Forgevia Codex doctor"
assert_contains "$doctor_output" "✅ OK"
assert_contains "$doctor_output" "📋 Summary"
assert_contains "$doctor_output" "Forgevia Codex doctor passed"
assert_contains "$doctor_output" "$OPENSPEC_ROOT/dist/core/config-prompts.js"

expected_openspec_config="$(cat "$ROOT_DIR/assets/openspec/dist/core/config-prompts.js")"
actual_openspec_config="$(cat "$OPENSPEC_ROOT/dist/core/config-prompts.js")"
assert_contains "$actual_openspec_config" "$expected_openspec_config"

echo "drift" >> "$CODEX_HOME/superpowers/skills/brainstorming/SKILL.md"

set +e
drift_output="$("$DOCTOR" 2>&1)"
drift_status=$?
set -e

assert_exit_code "$drift_status" "1"
assert_contains "$drift_output" "❌ DRIFT"
assert_contains "$drift_output" "📋 Summary"

echo "codex installer smoke test passed"

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

test_file_exists "$MANIFEST"
test_file_exists "$INSTALLER"
test_file_exists "$DOCTOR"

installer_help="$("$INSTALLER" --help)"
doctor_help="$("$DOCTOR" --help)"

assert_contains "$installer_help" "Install Forgevia Codex assets"
assert_contains "$installer_help" "$MANIFEST"
assert_contains "$doctor_help" "Check Forgevia Codex managed assets"
assert_contains "$doctor_help" "$MANIFEST"

echo "codex installer smoke test passed"

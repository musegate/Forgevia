#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-claude.sh"
DOCTOR="$ROOT_DIR/scripts/doctor-claude.sh"
MANIFEST="$ROOT_DIR/manifests/claude.json"

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

test_path_not_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "expected path to not exist: $path" >&2
    exit 1
  fi
}

test_file_exists "$MANIFEST"
test_file_exists "$INSTALLER"
test_file_exists "$DOCTOR"

installer_help="$("$INSTALLER" --help)"
doctor_help="$("$DOCTOR" --help)"
assert_contains "$installer_help" "Install Forgevia Claude assets"
assert_contains "$installer_help" "$MANIFEST"
assert_contains "$doctor_help" "Check Forgevia Claude managed assets"
assert_contains "$doctor_help" "$MANIFEST"
assert_contains "$doctor_help" "--repair"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export CLAUDE_HOME="$tmp_dir/.claude"
superpowers_root="$tmp_dir/plugin-cache/superpowers/5.0.5"
mkdir -p "$CLAUDE_HOME/skills/forgevia-think"
mkdir -p "$CLAUDE_HOME/plugins"
mkdir -p "$superpowers_root/skills/brainstorming"
mkdir -p "$superpowers_root/skills/writing-plans"
mkdir -p "$superpowers_root/skills/subagent-driven-development"
mkdir -p "$superpowers_root/skills/requesting-code-review"
mkdir -p "$superpowers_root/skills/executing-plans"
printf 'user local claude think\n' > "$CLAUDE_HOME/skills/forgevia-think/SKILL.md"
printf 'user local claude brainstorming\n' > "$superpowers_root/skills/brainstorming/SKILL.md"
printf 'user local claude review\n' > "$superpowers_root/skills/requesting-code-review/SKILL.md"
cat > "$CLAUDE_HOME/plugins/installed_plugins.json" <<EOF
{
  "version": 2,
  "plugins": {
    "superpowers@superpowers-marketplace": [
      {
        "scope": "user",
        "installPath": "$superpowers_root",
        "version": "5.0.5"
      }
    ]
  }
}
EOF

installer_output="$("$INSTALLER")"
assert_contains "$installer_output" "🧱 Forgevia Claude installer"
assert_contains "$installer_output" "✅ Applied Forgevia-managed Claude assets"
assert_contains "$installer_output" "✅ Detected Claude superpowers plugin at $superpowers_root"
assert_contains "$installer_output" "✅ Applied Forgevia-managed Claude superpowers overrides"
assert_contains "$installer_output" "💾 Backed up"
assert_contains "$installer_output" "🎉 Forgevia Claude install complete"

test_path_not_exists "$CLAUDE_HOME/skills/forgevia-think.forgevia.bak"
test_path_not_exists "$superpowers_root/skills/brainstorming/SKILL.md.forgevia.bak"
test_path_not_exists "$superpowers_root/skills/requesting-code-review/SKILL.md.forgevia.bak"
test_file_exists "$CLAUDE_HOME/skills/forgevia-think/SKILL.md"
test_file_exists "$superpowers_root/skills/brainstorming/SKILL.md"
test_file_exists "$superpowers_root/skills/writing-plans/SKILL.md"
test_file_exists "$superpowers_root/skills/subagent-driven-development/SKILL.md"
test_file_exists "$superpowers_root/skills/requesting-code-review/SKILL.md"
test_file_exists "$superpowers_root/skills/requesting-code-review/code-reviewer.md"
test_file_exists "$superpowers_root/skills/executing-plans/SKILL.md"

expected_skill="$(cat "$ROOT_DIR/.claude/skills/forgevia-think/SKILL.md")"
actual_skill="$(cat "$CLAUDE_HOME/skills/forgevia-think/SKILL.md")"
assert_contains "$actual_skill" "$expected_skill"
expected_brainstorming="$(cat "$ROOT_DIR/assets/claude/superpowers/skills/brainstorming/SKILL.md")"
actual_brainstorming="$(cat "$superpowers_root/skills/brainstorming/SKILL.md")"
assert_contains "$actual_brainstorming" "$expected_brainstorming"
expected_review_template="$(cat "$ROOT_DIR/assets/claude/superpowers/skills/requesting-code-review/code-reviewer.md")"
actual_review_template="$(cat "$superpowers_root/skills/requesting-code-review/code-reviewer.md")"
assert_contains "$actual_review_template" "$expected_review_template"

doctor_output="$("$DOCTOR")"
assert_contains "$doctor_output" "🔎 Forgevia Claude doctor"
assert_contains "$doctor_output" "✅ OK"
assert_contains "$doctor_output" "📋 Summary"
assert_contains "$doctor_output" "Forgevia Claude doctor passed"
assert_contains "$doctor_output" "$CLAUDE_HOME/skills/forgevia-think"
assert_contains "$doctor_output" "$superpowers_root/skills/requesting-code-review"

echo "drift" >> "$superpowers_root/skills/brainstorming/SKILL.md"

set +e
drift_output="$("$DOCTOR" 2>&1)"
drift_status=$?
set -e

if [[ "$drift_status" != "1" ]]; then
  echo "expected exit code 1 but got $drift_status" >&2
  exit 1
fi
assert_contains "$drift_output" "❌ DRIFT"
assert_contains "$drift_output" "📋 Summary"

repair_output="$("$DOCTOR" --repair)"
assert_contains "$repair_output" "🛠️ Repairing drifted or missing assets"
assert_contains "$repair_output" "💾 Backed up"
assert_contains "$repair_output" "✅ Repaired"
test_path_not_exists "$superpowers_root/skills/brainstorming/SKILL.md.forgevia.bak"

post_repair_output="$("$DOCTOR")"
assert_contains "$post_repair_output" "✨ No drift detected"
assert_contains "$post_repair_output" "Forgevia Claude doctor passed"

echo "claude installer smoke test passed"

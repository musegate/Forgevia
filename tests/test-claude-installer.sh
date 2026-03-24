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
assert_contains "$installer_help" "--install-openspec"
assert_contains "$doctor_help" "Check Forgevia Claude managed assets"
assert_contains "$doctor_help" "$MANIFEST"
assert_contains "$doctor_help" "--repair"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

export CLAUDE_HOME="$tmp_dir/.claude"
bin_dir="$tmp_dir/bin"
superpowers_root="$tmp_dir/plugin-cache/superpowers/5.0.5"
export OPENSPEC_ROOT="$tmp_dir/openspec"
mkdir -p "$CLAUDE_HOME/skills/forgevia-think" "$bin_dir"
mkdir -p "$CLAUDE_HOME/plugins"
mkdir -p "$superpowers_root/skills/brainstorming"
mkdir -p "$superpowers_root/skills/writing-plans"
mkdir -p "$superpowers_root/skills/test-driven-development"
mkdir -p "$superpowers_root/skills/subagent-driven-development"
mkdir -p "$superpowers_root/skills/requesting-code-review"
mkdir -p "$superpowers_root/skills/executing-plans"
mkdir -p "$OPENSPEC_ROOT/dist/core/templates/workflows"
printf 'user local claude think\n' > "$CLAUDE_HOME/skills/forgevia-think/SKILL.md"
printf 'user local claude brainstorming\n' > "$superpowers_root/skills/brainstorming/SKILL.md"
printf 'user local claude tdd\n' > "$superpowers_root/skills/test-driven-development/SKILL.md"
printf 'user local claude review\n' > "$superpowers_root/skills/requesting-code-review/SKILL.md"
printf 'export function serializeConfig() { return "wrong"; }\n' > "$OPENSPEC_ROOT/dist/core/config-prompts.js"
printf 'export const propose = "wrong";\n' > "$OPENSPEC_ROOT/dist/core/templates/workflows/propose.js"
cat > "$bin_dir/openspec" <<EOF
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$bin_dir/openspec"
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

installer_output="$(PATH="$bin_dir:$PATH" "$INSTALLER")"
assert_contains "$installer_output" "🧱 Forgevia Claude installer"
assert_contains "$installer_output" "✅ Applied openspec override"
assert_contains "$installer_output" "✅ Applied Forgevia-managed Claude assets"
assert_contains "$installer_output" "✅ Detected Claude superpowers plugin at $superpowers_root"
assert_contains "$installer_output" "✅ Applied Forgevia-managed Claude superpowers overrides"
assert_contains "$installer_output" "💾 Backed up"
assert_contains "$installer_output" "🎉 Forgevia Claude install complete"

test_path_not_exists "$CLAUDE_HOME/skills/forgevia-think.forgevia.bak"
test_path_not_exists "$superpowers_root/skills/brainstorming/SKILL.md.forgevia.bak"
test_path_not_exists "$superpowers_root/skills/test-driven-development/SKILL.md.forgevia.bak"
test_path_not_exists "$superpowers_root/skills/requesting-code-review/SKILL.md.forgevia.bak"
test_path_not_exists "$OPENSPEC_ROOT/dist/core/config-prompts.js.forgevia.bak"
test_path_not_exists "$OPENSPEC_ROOT/dist/core/templates/workflows/propose.js.forgevia.bak"
test_file_exists "$CLAUDE_HOME/skills/forgevia-think/SKILL.md"
test_file_exists "$CLAUDE_HOME/skills/forgevia/SKILL.md"
test_file_exists "$CLAUDE_HOME/skills/openspec-propose/SKILL.md"
test_file_exists "$CLAUDE_HOME/skills/mermaid-diagram-specialist/SKILL.md"
test_file_exists "$CLAUDE_HOME/skills/playwright-interactive/SKILL.md"
test_file_exists "$CLAUDE_HOME/commands/opsx/propose.md"
test_file_exists "$superpowers_root/skills/brainstorming/SKILL.md"
test_file_exists "$superpowers_root/skills/writing-plans/SKILL.md"
test_file_exists "$superpowers_root/skills/test-driven-development/SKILL.md"
test_file_exists "$superpowers_root/skills/subagent-driven-development/SKILL.md"
test_file_exists "$superpowers_root/skills/requesting-code-review/SKILL.md"
test_file_exists "$superpowers_root/skills/requesting-code-review/code-reviewer.md"
test_file_exists "$superpowers_root/skills/executing-plans/SKILL.md"

expected_skill="$(cat "$ROOT_DIR/.claude/skills/forgevia-think/SKILL.md")"
actual_skill="$(cat "$CLAUDE_HOME/skills/forgevia-think/SKILL.md")"
assert_contains "$actual_skill" "$expected_skill"
expected_router="$(cat "$ROOT_DIR/.claude/skills/forgevia/SKILL.md")"
actual_router="$(cat "$CLAUDE_HOME/skills/forgevia/SKILL.md")"
assert_contains "$actual_router" "$expected_router"
expected_brainstorming="$(cat "$ROOT_DIR/assets/claude/superpowers/skills/brainstorming/SKILL.md")"
actual_brainstorming="$(cat "$superpowers_root/skills/brainstorming/SKILL.md")"
assert_contains "$actual_brainstorming" "$expected_brainstorming"
expected_tdd="$(cat "$ROOT_DIR/assets/claude/superpowers/skills/test-driven-development/SKILL.md")"
actual_tdd="$(cat "$superpowers_root/skills/test-driven-development/SKILL.md")"
assert_contains "$actual_tdd" "$expected_tdd"
expected_review_template="$(cat "$ROOT_DIR/assets/claude/superpowers/skills/requesting-code-review/code-reviewer.md")"
actual_review_template="$(cat "$superpowers_root/skills/requesting-code-review/code-reviewer.md")"
assert_contains "$actual_review_template" "$expected_review_template"
expected_command="$(cat "$ROOT_DIR/.claude/commands/opsx/propose.md")"
actual_command="$(cat "$CLAUDE_HOME/commands/opsx/propose.md")"
assert_contains "$actual_command" "$expected_command"
expected_openspec_config="$(cat "$ROOT_DIR/assets/openspec/dist/core/config-prompts.js")"
actual_openspec_config="$(cat "$OPENSPEC_ROOT/dist/core/config-prompts.js")"
assert_contains "$actual_openspec_config" "$expected_openspec_config"
expected_openspec_propose="$(cat "$ROOT_DIR/assets/openspec/dist/core/templates/workflows/propose.js")"
actual_openspec_propose="$(cat "$OPENSPEC_ROOT/dist/core/templates/workflows/propose.js")"
assert_contains "$actual_openspec_propose" "$expected_openspec_propose"

doctor_output="$(PATH="$bin_dir:$PATH" "$DOCTOR")"
assert_contains "$doctor_output" "🔎 Forgevia Claude doctor"
assert_contains "$doctor_output" "✅ OK"
assert_contains "$doctor_output" "📋 Summary"
assert_contains "$doctor_output" "Forgevia Claude doctor passed"
assert_contains "$doctor_output" "$OPENSPEC_ROOT/dist/core/config-prompts.js"
assert_contains "$doctor_output" "$OPENSPEC_ROOT/dist/core/templates/workflows/propose.js"
assert_contains "$doctor_output" "$CLAUDE_HOME/skills/forgevia-think"
assert_contains "$doctor_output" "$CLAUDE_HOME/skills/forgevia"
assert_contains "$doctor_output" "$CLAUDE_HOME/commands/opsx"
assert_contains "$doctor_output" "$superpowers_root/skills/requesting-code-review"

echo "drift" >> "$superpowers_root/skills/brainstorming/SKILL.md"

set +e
drift_output="$(PATH="$bin_dir:$PATH" "$DOCTOR" 2>&1)"
drift_status=$?
set -e

if [[ "$drift_status" != "1" ]]; then
  echo "expected exit code 1 but got $drift_status" >&2
  exit 1
fi
assert_contains "$drift_output" "❌ DRIFT"
assert_contains "$drift_output" "📋 Summary"

repair_output="$(PATH="$bin_dir:$PATH" "$DOCTOR" --repair)"
assert_contains "$repair_output" "🛠️ Repairing drifted or missing assets"
assert_contains "$repair_output" "💾 Backed up"
assert_contains "$repair_output" "✅ Repaired"
test_path_not_exists "$superpowers_root/skills/brainstorming/SKILL.md.forgevia.bak"

post_repair_output="$(PATH="$bin_dir:$PATH" "$DOCTOR")"
assert_contains "$post_repair_output" "✨ No drift detected"
assert_contains "$post_repair_output" "Forgevia Claude doctor passed"

missing_openspec_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir" "$missing_openspec_dir"' EXIT
export CLAUDE_HOME="$missing_openspec_dir/.claude"
node_dir="$(dirname "$(command -v node)")"
npm_dir="$(dirname "$(command -v npm)")"
unset OPENSPEC_ROOT
mkdir -p "$CLAUDE_HOME/plugins"
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

set +e
missing_openspec_output="$(PATH="$node_dir:$npm_dir:/usr/bin:/bin" "$INSTALLER" 2>&1)"
missing_openspec_status=$?
set -e

if [[ "$missing_openspec_status" != "1" ]]; then
  echo "expected missing openspec exit code 1 but got $missing_openspec_status" >&2
  exit 1
fi
assert_contains "$missing_openspec_output" "openspec is not installed or not on PATH"
assert_contains "$missing_openspec_output" "--install-openspec"

echo "claude installer smoke test passed"

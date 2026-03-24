#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap-project.sh"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "expected output to contain: $needle" >&2
    exit 1
  fi
}

assert_file_exists() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "expected path to exist: $path" >&2
    exit 1
  fi
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

project_dir="$tmp_dir/project"
bin_dir="$tmp_dir/bin"
mkdir -p "$project_dir" "$bin_dir"

fake_log="$tmp_dir/openspec.log"
cat > "$bin_dir/openspec" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "\$*" >> "$fake_log"
target_dir="\${@: -1}"
mkdir -p "\$target_dir/openspec" "\$target_dir/.codex"
EOF
chmod +x "$bin_dir/openspec"

help_output="$("$BOOTSTRAP" --help)"
assert_contains "$help_output" "Bootstrap OpenSpec in the current project"

default_output="$(PATH="$bin_dir:$PATH" "$BOOTSTRAP" "$project_dir")"
assert_contains "$default_output" "Running openspec init --tools codex,claude"
assert_file_exists "$project_dir/openspec"
assert_file_exists "$fake_log"
assert_contains "$(cat "$fake_log")" "init --tools codex,claude $project_dir"

line_count="$(wc -l < "$fake_log" | tr -d ' ')"
if [[ "$line_count" != "1" ]]; then
  echo "expected default openspec init to run exactly once" >&2
  exit 1
fi

second_output="$(PATH="$bin_dir:$PATH" "$BOOTSTRAP" --tools codex,claude "$project_dir")"
assert_contains "$second_output" "OpenSpec already initialized"

second_project="$tmp_dir/project-explicit"
mkdir -p "$second_project"

bootstrap_output="$(PATH="$bin_dir:$PATH" "$BOOTSTRAP" --tools codex,claude "$second_project")"
assert_contains "$bootstrap_output" "Running openspec init --tools codex,claude"
assert_contains "$(cat "$fake_log")" "init --tools codex,claude $second_project"

second_project_dir="$tmp_dir/project-claude"
mkdir -p "$second_project_dir"

claude_output="$(PATH="$bin_dir:$PATH" "$BOOTSTRAP" --tools claude "$second_project_dir")"
assert_contains "$claude_output" "Running openspec init --tools claude"
assert_contains "$(cat "$fake_log")" "init --tools claude $second_project_dir"

third_project_dir="$tmp_dir/project-normalized"
mkdir -p "$third_project_dir"

normalized_output="$(PATH="$bin_dir:$PATH" "$BOOTSTRAP" --tools claude,codex "$third_project_dir")"
assert_contains "$normalized_output" "Running openspec init --tools codex,claude"
assert_contains "$(cat "$fake_log")" "init --tools codex,claude $third_project_dir"

echo "bootstrap project test passed"

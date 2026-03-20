#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/forgevia-draw.sh"

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
  if [[ ! -f "$path" ]]; then
    echo "expected file to exist: $path" >&2
    exit 1
  fi
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

bin_dir="$tmp_dir/bin"
mkdir -p "$bin_dir"

cat > "$bin_dir/mmdc" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
input=""
output=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i)
      input="$2"
      shift 2
      ;;
    -o)
      output="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
printf '<svg data-source="%s"></svg>\n' "$input" > "$output"
EOF
chmod +x "$bin_dir/mmdc"

help_output="$("$SCRIPT" --help)"
assert_contains "$help_output" "Generate timestamped Mermaid sequence diagram outputs"

draw_output="$(printf 'sequenceDiagram\nA->>B: Login\n' | MMDC_BIN="$bin_dir/mmdc" FORGEVIA_DRAW_TIMESTAMP="20260320-120101" "$SCRIPT" "login-flow" "$tmp_dir/out")"

expected_base="$tmp_dir/out/20260320-120101-login-flow"
mdd_path="${expected_base}.mdd"
svg_path="${expected_base}.svg"

assert_contains "$draw_output" "$mdd_path"
assert_contains "$draw_output" "$svg_path"
assert_file_exists "$mdd_path"
assert_file_exists "$svg_path"
assert_contains "$(cat "$mdd_path")" "sequenceDiagram"
assert_contains "$(cat "$svg_path")" "data-source=\"$mdd_path\""

echo "draw helper test passed"

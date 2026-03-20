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

assert_file_contains() {
  local path="$1"
  local needle="$2"
  assert_contains "$(cat "$path")" "$needle"
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

bin_dir="$tmp_dir/bin"
mkdir -p "$bin_dir"

fake_chrome="$bin_dir/google-chrome"
printf '#!/usr/bin/env bash\nexit 0\n' > "$fake_chrome"
chmod +x "$fake_chrome"

args_log="$tmp_dir/mmdc-args.log"
config_log="$tmp_dir/mmdc-config.log"

cat > "$bin_dir/mmdc" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
input=""
output=""
config=""
args_log="${ARGS_LOG:?}"
config_log="${CONFIG_LOG:?}"
printf '%s\n' "$*" > "$args_log"
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
    -p|--puppeteerConfigFile)
      config="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
if [[ -n "$config" ]]; then
  cp "$config" "$config_log"
fi
printf '<svg data-source="%s"></svg>\n' "$input" > "$output"
EOF
chmod +x "$bin_dir/mmdc"

help_output="$("$SCRIPT" --help)"
assert_contains "$help_output" "Generate timestamped Mermaid sequence diagram outputs"

draw_output="$(printf 'sequenceDiagram\nA->>B: Login\n' | PATH="$bin_dir:$PATH" ARGS_LOG="$args_log" CONFIG_LOG="$config_log" MMDC_BIN="$bin_dir/mmdc" FORGEVIA_DRAW_CHROME_PATH="$fake_chrome" FORGEVIA_DRAW_TIMESTAMP="20260320-120101" "$SCRIPT" "login-flow" "$tmp_dir/out")"

expected_base="$tmp_dir/out/20260320-120101-login-flow"
mmd_path="${expected_base}.mmd"
svg_path="${expected_base}.svg"

assert_contains "$draw_output" "$mmd_path"
assert_contains "$draw_output" "$svg_path"
assert_file_exists "$mmd_path"
assert_file_exists "$svg_path"
assert_file_exists "$config_log"
assert_file_contains "$mmd_path" "sequenceDiagram"
assert_file_contains "$svg_path" "data-source=\"$mmd_path\""
assert_file_contains "$args_log" "-p"
assert_file_contains "$config_log" "\"executablePath\": \"$fake_chrome\""

echo "draw helper test passed"

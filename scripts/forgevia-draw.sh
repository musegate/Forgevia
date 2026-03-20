#!/usr/bin/env bash

set -euo pipefail

MMDC_BIN="${MMDC_BIN:-mmdc}"
DEFAULT_OUTPUT_DIR="./forgevia-drawings"

usage() {
  cat <<EOF
Generate timestamped Mermaid sequence diagram outputs.

Usage:
  $(basename "$0") [--help] <feature-name> [output_dir]

Behavior:
  - reads Mermaid content from stdin
  - writes a timestamped .mmd file
  - renders a matching .svg with mmdc
  - prefers a local Chrome/Chromium executable when available
  - names outputs as <date-time>-<feature>
EOF
}

timestamp() {
  if [[ -n "${FORGEVIA_DRAW_TIMESTAMP:-}" ]]; then
    printf '%s\n' "$FORGEVIA_DRAW_TIMESTAMP"
    return
  fi

  date '+%Y%m%d-%H%M%S'
}

sanitize_feature_name() {
  printf '%s' "$1" | tr '/[:space:]' '--' | tr -s '-'
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

detect_chrome_path() {
  local candidate

  for candidate in \
    "${FORGEVIA_DRAW_CHROME_PATH:-}" \
    "${PUPPETEER_EXECUTABLE_PATH:-}" \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
  do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  for candidate in google-chrome chrome chromium chromium-browser; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done

  return 1
}

write_puppeteer_config() {
  local chrome_path="$1"
  local config_path="$2"

  cat > "$config_path" <<EOF
{
  "executablePath": "$(json_escape "$chrome_path")"
}
EOF
}

main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
  fi

  if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
  fi

  local feature_name="$1"
  local output_dir="${2:-$DEFAULT_OUTPUT_DIR}"
  local ts
  local safe_feature
  local base_name
  local mmd_path
  local svg_path
  local chrome_path=""
  local puppeteer_config=""
  local -a mmdc_cmd

  ts="$(timestamp)"
  safe_feature="$(sanitize_feature_name "$feature_name")"
  base_name="${ts}-${safe_feature}"

  mkdir -p "$output_dir"

  mmd_path="$output_dir/${base_name}.mmd"
  svg_path="$output_dir/${base_name}.svg"

  cat > "$mmd_path"

  mmdc_cmd=("$MMDC_BIN" -i "$mmd_path" -o "$svg_path")

  if chrome_path="$(detect_chrome_path)"; then
    puppeteer_config="$(mktemp "${TMPDIR:-/tmp}/forgevia-draw-puppeteer.XXXXXX")"
    trap 'rm -f "${puppeteer_config:-}"' EXIT
    write_puppeteer_config "$chrome_path" "$puppeteer_config"
    mmdc_cmd+=(-p "$puppeteer_config")
  fi

  "${mmdc_cmd[@]}"

  echo "🖊️  Wrote Mermaid source: $mmd_path"
  echo "🖼️  Rendered SVG: $svg_path"
}

main "$@"

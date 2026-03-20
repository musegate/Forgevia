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
  - writes a timestamped .mdd file
  - renders a matching .svg with mmdc
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
  local mdd_path
  local svg_path

  ts="$(timestamp)"
  safe_feature="$(sanitize_feature_name "$feature_name")"
  base_name="${ts}-${safe_feature}"

  mkdir -p "$output_dir"

  mdd_path="$output_dir/${base_name}.mdd"
  svg_path="$output_dir/${base_name}.svg"

  cat > "$mdd_path"
  "$MMDC_BIN" -i "$mdd_path" -o "$svg_path"

  echo "🖊️  Wrote Mermaid source: $mdd_path"
  echo "🖼️  Rendered SVG: $svg_path"
}

main "$@"

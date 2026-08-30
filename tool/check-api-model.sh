#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_root="$repository_root/tool/dart_apitool"
baseline_path="$repository_root/tool/api/current.json"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/awesome-button-flutter-api.XXXXXX")"
generated_path="$temporary_root/flutter-awesome-button-api.json"

cleanup() {
  rm -rf "$temporary_root"
}
trap cleanup EXIT

if [[ ! -s "$baseline_path" ]]; then
  echo "Reviewed API model is missing or empty: $baseline_path" >&2
  exit 1
fi

(
  cd "$tool_root"
  dart run dart_apitool:main extract \
    --input "$repository_root" \
    --output "$generated_path" \
    --set-exit-on-missing-export \
    --force-use-flutter
)

dart run "$repository_root/tool/normalize_api_model.dart" "$generated_path"

if ! diff -u "$baseline_path" "$generated_path"; then
  echo "Public API differs from tool/api/current.json." >&2
  echo "Review compatibility, update the changelog/report, then run dart run tool/update_api.dart intentionally." >&2
  exit 1
fi

echo "Public API matches tool/api/current.json."

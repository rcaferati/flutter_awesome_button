#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/awesome-button-dartdoc.XXXXXX")"
documentation_log="$temporary_root/dartdoc.log"

cleanup() {
  rm -rf "$temporary_root"
}
trap cleanup EXIT

cd "$repository_root"
dart doc --output "$temporary_root/doc" --validate-links . 2>&1 | tee "$documentation_log"

if grep -Eiq '(^|[[:space:]])warning:|Found [1-9][0-9]* warnings' "$documentation_log"; then
  echo "Dartdoc emitted a warning; documentation warnings are fatal." >&2
  exit 1
fi

if [[ ! -s "$temporary_root/doc/index.html" ]]; then
  echo "Dartdoc did not produce a non-empty index." >&2
  exit 1
fi

echo "Dartdoc completed with link validation in temporary storage."

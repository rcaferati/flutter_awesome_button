#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

flutter pub get --enforce-lockfile
dart pub get --directory tool/dart_apitool --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
tool/check-docs.sh
tool/check-api-model.sh
dart pub publish --dry-run

echo "Flutter Awesome Button release preflight passed."

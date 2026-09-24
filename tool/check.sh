#!/usr/bin/env bash
# Milestone gate (CLAUDE.md): format, analyze, test. Pass --integration to also
# run integration_test (required from M3; needs a device or desktop target).
set -euo pipefail
cd "$(dirname "$0")/.."

flutter gen-l10n
dart format --set-exit-if-changed .
flutter analyze
flutter test

if [[ "${1:-}" == "--integration" ]]; then
  flutter test integration_test
fi

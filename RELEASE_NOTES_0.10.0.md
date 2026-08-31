# flutter_awesome_button 0.10.0

flutter_awesome_button 0.10.0 makes gesture, progress, sizing, and text-transition behavior more
predictable while extending the package's accessibility and motion controls across its supported
Flutter hosts.

## Highlights

- Keeps callbacks current across widget updates while preserving transition-scoped release and
  progress completion behavior.
- Strengthens lifecycle cancellation, long-press replacement, one-shot progress completion, Reduced
  Motion, large-text, RTL, and numeric validation behavior.
- Stabilizes auto-width growth and shrink choreography so labels settle without stale frames,
  reversal, or overshoot.
- Adds compatible animation, accessibility, and canonical `x` configuration while retaining
  `twitter` as a deprecated alias.
- Adds deterministic API, Dartdoc, coverage, package-shape, portability, and regression gates.

## Compatibility

- The package-owned semantic comparison reports no breaking declarations from 0.9.1 to 0.10.0.
- New options are additive, and existing call sites remain supported.
- Android, iOS, web, macOS, Linux, and Windows remain declared package targets.

## Verification

- `tool/release-preflight.sh` — passed.
- 118 package tests — passed.
- Formatting, analyzer, Dartdoc, API-model comparison, coverage generation, and pub dry run — passed
  with zero warnings.

## Installation

```yaml
dependencies:
  rcaferati_flutter_awesome_button: ^0.10.0
```

## Full Changelog

See the [0.10.0 changelog](https://github.com/rcaferati/flutter_awesome_button/blob/v0.10.0/CHANGELOG.md#0100---2026-08-31) and the checked-in 0.9.1 to 0.10.0 semantic comparison.

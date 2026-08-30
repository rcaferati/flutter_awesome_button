# Changelog

## Unreleased

- Hardened callback freshness, terminal cancellation, progress completion, accessibility, Reduced Motion, large-text, RTL, validation, and theme resolution without selecting a release version.
- Added package-owned regressions and deterministic API, documentation, coverage, package-shape, and CI gates.
- Preserved explicitly requested flat visual styling while disabled; disabled state still blocks activation.
- Adopted the cross-platform text-transition contract with grapheme-aware
  scrambling, measured frame publication, coordinated width timing, one-line
  constrained fallback, stable target semantics, and Reduced Motion settlement.
- Prevented non-scrambled auto-width growth from publishing a longer label
  before the face can fit it; shrink still swaps before contracting.
- Hardened final label settlement with conservative physical-pixel fit and a
  generation-matched post-layout proof before stable wrapping resumes.
- Recorded the one-time `0.9.1` semantic comparison in
  `tool/api/0.9.1-to-current.md`: it reports no breaking declarations and
  classifies the new motion, accessibility, and canonical `x` fields as
  additive changes, with `twitter` retained as a deprecated alias.

## 0.9.1

- Added API documentation across the public widget, theme, style, and helper
  surface to improve pub.dev package discoverability and developer guidance.
- Enabled `public_member_api_docs` and cleaned up the exported API docs so the
  package keeps passing the pub.dev documentation threshold.
- Refreshed the release metadata so the standalone GitHub repository is the
  canonical package source for pub.dev verification.

## 0.9.0

- Completed the base `AwesomeButton` parity pass for Flutter with the layered
  3D shell, spring release, immediate press feedback, progress lifecycle, and
  visible loading bar behavior.
- Added the RN-style themed layer with built-in themes, variants, sizes,
  transparent mode, and `ThemedButton` palette transitions.
- Added text transition, empty placeholder support, and the full RN-style
  example app structure with themed, progress, and social tabs.
- Added release-facing package metadata, screenshots, and a pub.dev-ready
  README aligned with the React Native package structure.

## 0.1.0

- Initial architecture for `rcaferati_flutter_awesome_button`.
- Added `AwesomeButton`, `AwesomeButtonStyle`, and `AwesomeButtonThemeData`.
- Added a gallery-style example app scaffold.
- Added initial widget tests covering press, disabled, layout, style, and semantics.

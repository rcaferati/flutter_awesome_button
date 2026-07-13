# Width Change Architecture

Flutter Awesome Button animates size changes by default through
`animateSize: true`. Fixed `width` and `height` changes animate, measured
auto-width string label changes animate, and `animateSize: false` keeps both
paths instant. Bridge changes between fixed, auto, and stretch width remain
instant for this release.

## Runtime Split

`lib/src/awesome_button.dart` owns the size state machine. It tracks resolved
width and height, animated dimension values, displayed string text, text/width
choreography, stale-run guards, and cleanup for interrupted animations.

`ThemedButton` resolves theme sizes and passes fixed or auto width through to
`AwesomeButton`. When `autoWidth: true` is used without an explicit `width`, the
base button owns target measurement and choreography.

## Choreography Rules

Initial auto-width measurement snaps into place so first paint does not animate
from an artificial zero width.

When the next string is wider and `textTransition` is enabled, width animation
and text animation start together. When the next string is narrower,
`textTransition` starts first and width animation starts `50ms` later.

Without `textTransition`, wider strings grow width first and then swap text;
narrower strings swap text first and then shrink width. If the measured width is
unchanged, the size phase is skipped and only the text phase runs.

## In-Tree Measurement

Auto-width choreography is intentionally limited to plain non-empty string
children with no `before`, `after`, or `extra` content. Other auto-width content
falls back to Flutter's visible intrinsic layout because there is no safe target
string to premeasure.

Target strings are measured by an in-tree hidden probe rendered as a sibling of
the visible shell, outside the width-controlled shell subtree. The probe uses
`Offstage`, `IgnorePointer`, `ExcludeSemantics`, `TickerMode(enabled: false)`,
and `OverflowBox` so surrounding row constraints cannot cap the intrinsic
target width.

The probe measures the full hidden padded and bordered label container, not raw
text width. This keeps measured widths aligned with the visible button box and
avoids duplicating width reconstruction logic.

## Implementation Constraints

Dimension animation uses `AnimationController` with `125ms` and
`Cubic(0.3, 0.05, 0.2, 1)`. Width and height are layout properties in Flutter,
so they are driven by normal framework layout ticks rather than a detached
native animation layer.

The visible label remains single-line with clipped overflow during transition
frames. This keeps scramble frames from wrapping while the button is growing or
shrinking.

The size controller gates asynchronous measurements and animation completions
with run tokens so stale work cannot publish after a newer label or size target
takes ownership.

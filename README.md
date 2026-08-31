# Flutter Awesome Button

`rcaferati_flutter_awesome_button` brings the Awesome Button interaction,
progress, sizing, and theme system to Flutter with native widget lifecycle,
semantics, focus, and animation behavior.

The library exports:

- `AwesomeButton`
- `ThemedButton`
- `getTheme`
- typed Dart models such as `AwesomeButtonStyle`, `AwesomeButtonThemeData`,
  `ThemeName`, `ButtonVariant`, `ButtonSize`, `ThemeButtonStyle`,
  `ThemeSizeStyle`, `ThemeDefinition`, and `RegisteredThemeDefinition`

<table>
  <tr>
    <td width="33%">
      <img
        alt="Blue Awesome Button theme demo"
        src="https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-blue-new.gif"
      />
    </td>
    <td width="33%">
      <img
        alt="Cartman Awesome Button theme demo"
        src="https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-cartman.gif"
      />
    </td>
    <td width="33%">
      <img
        alt="Rick Awesome Button theme demo"
        src="https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-rick.gif"
      />
    </td>
  </tr>
</table>

## Figma File

Explore the shared Awesome Button visual system in the [Figma design file](https://www.figma.com/file/Ug8sNPzmevU3ZQus9Klu5aHq/react-awesome-button-theme-blue). The Figma file is a visual design reference; this package's documentation defines its behavior, accessibility, and public API contract.

[<img alt="Awesome Button components in the shared Figma design file" src="https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/figma.png" width="800" />](https://www.figma.com/file/Ug8sNPzmevU3ZQus9Klu5aHq/react-awesome-button-theme-blue)

## Installation

```yaml
dependencies:
  rcaferati_flutter_awesome_button: ^0.10.0
```

Then install dependencies:

```bash
flutter pub get
```

Current Flutter support:

- `flutter >= 3.24.0`
- `dart >= 3.5.0 < 4.0.0`

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AwesomeButton(
      child: 'Save',
    );
  }
}
```

`AwesomeButton` supports both plain string labels and arbitrary Flutter
widgets.

## Features

### Size Changes

`animateSize` is enabled by default.

- fixed `width` / `height` changes animate with `175ms cubic-bezier(0.3, 0.05, 0.2, 1)`
- `ThemedButton` size preset changes animate because they resolve to fixed
  width and height updates
- auto-width string labels grow and shrink when their measured target width
  changes
- `textTransition` operates on Unicode grapheme clusters, using a `7ms` logical
  slot stagger and a `10ms` post-randomization hold
- with `textTransition` plus auto width, growth starts width immediately and
  starts text at `30%` of the text timeline; shrink starts text immediately and
  starts width at `30%`; width animation lasts for the full text timeline
- every transient frame is measured with the resolved typography and published
  only when it fits the currently available auto width
- transient labels are always a single clipped line. Fixed, stretch, and
  externally constrained layouts use clipping as a safety fallback; stable
  labels regain normal wrapping and accessibility scaling after settlement
- when `textTransition` is disabled, wider labels keep the fitting source until
  the target fits; the target stays clipped to one line until a matching
  post-layout proof confirms physical-pixel fit, while narrower labels swap
  before width shrinks
- `animateSize: false` keeps size changes instant
- fixed-to-auto and auto-to-fixed changes remain instant

Flutter measures labels with the same resolved text style, scaling, locale, and
direction used for rendering. Leading and trailing slot widths are reported by
the rendered content row, so consumer widgets are never composed a second time;
`extra` remains an overlay and does not affect intrinsic width.

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class SizeExample extends StatelessWidget {
  const SizeExample({
    required this.isLong,
    super.key,
  });

  final bool isLong;

  @override
  Widget build(BuildContext context) {
    final label = isLong ? 'Open analytics dashboard' : 'Open';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemedButton(
          name: ThemeName.basic,
          autoWidth: true,
          textTransition: true,
          child: label,
        ),
        const SizedBox(height: 12),
        ThemedButton(
          name: ThemeName.basic,
          autoWidth: true,
          animateSize: false,
          child: label,
        ),
      ],
    );
  }
}
```

### Progress Buttons

When `progress` is enabled, `onPress` receives a `next` callback. Call it when
your work is done to complete the progress animation and release the button.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AwesomeButton(
      progress: true,
      onPress: (next) {
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            next?.call();
          }),
        );
      },
      child: 'Submit',
    );
  }
}
```

Progress uses the typed completion contract:

```dart
typedef AwesomeButtonNext = void Function([VoidCallback? callback]);
typedef AwesomeButtonPressCallback = void Function([AwesomeButtonNext? next]);
```

### Themed Buttons

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class ThemeExample extends StatelessWidget {
  const ThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemedButton(
          name: ThemeName.rick,
          type: ButtonVariant.primary,
          child: 'Rick Primary',
        ),
        SizedBox(height: 12),
        ThemedButton(
          name: ThemeName.rick,
          type: ButtonVariant.secondary,
          child: 'Rick Secondary',
        ),
      ],
    );
  }
}
```

If you need the full registered theme object, use `getTheme`.

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class ThemeConfigExample extends StatelessWidget {
  const ThemeConfigExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = getTheme(index: 0);

    return ThemedButton(
      config: theme,
      type: ButtonVariant.anchor,
      child: theme.title,
    );
  }
}
```

`getTheme()` safely falls back to the default `basic` theme if the provided
index or name is invalid.

### Before / After / Extra Content

Use `before` and `after` for inline content that should animate with the label,
and `extra` for content rendered behind the button body.

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class ButtonContentExample extends StatelessWidget {
  const ButtonContentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AwesomeButton(
      before: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      after: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
      extra: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4C63D2),
              Color(0xFFBC3081),
              Color(0xFFF47133),
              Color(0xFFFED576),
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
```

### Transparent Buttons

`transparent` is supported on `ThemedButton`. It removes the visible shell
layers while preserving the content, hit target, and active/progress feedback.

```dart
import 'package:flutter/material.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

class TransparentExample extends StatelessWidget {
  const TransparentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemedButton(
      name: ThemeName.bruce,
      type: ButtonVariant.anchor,
      transparent: true,
      child: 'Transparent',
    );
  }
}
```

## Built-in Theme Contract

### Theme Names

- `basic`
- `bojack`
- `cartman`
- `mysterion`
- `c137`
- `rick`
- `summer`
- `bruce`

### Variants

- `primary`
- `secondary`
- `anchor`
- `danger`
- `disabled`
- `flat`
- `x` (canonical alias)
- `twitter` (deprecated compatibility enum value)
- `messenger`
- `facebook`
- `github`
- `linkedin`
- `whatsapp`
- `reddit`
- `pinterest`
- `youtube`

Use `ButtonVariant.x` in new code. `ButtonVariant.twitter` remains a deprecated
compatibility enum value with the same runtime identity, so existing exhaustive
switches and serialized values retain their order and meaning.

Unknown variants fall back safely at runtime instead of crashing.

### Sizes

- `icon`
- `small`
- `medium`
- `large`

## API Reference

The tables below cover the primary consumer-facing parameters. The exported
Dart declarations and checked-in
[API model](https://github.com/rcaferati/flutter_awesome_button/blob/main/tool/api/current.json)
define the complete public surface.

### AwesomeButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Object?` | `null` | Button label or custom content. Plain string labels also support `textTransition`. |
| `onPress` | `AwesomeButtonPressCallback?` | `null` | Main press callback. In `progress` mode it receives the completion handler. |
| `onLongPress` | `VoidCallback?` | `null` | Optional long-press callback. |
| `disabled` | `bool` | `false` | Disables interactions and semantics. |
| `width` | `double?` | `null` | Fixed width, or leave null for auto width. Pair with `stretch` for full width. |
| `height` | `double` | `52` | Face height before the raise layer is added. |
| `paddingHorizontal` | `double?` | `16` resolved | Horizontal content padding. |
| `paddingTop` | `double?` | `0` resolved | Additional top content padding. |
| `paddingBottom` | `double?` | `0` resolved | Additional bottom content padding. |
| `before` | `Widget?` | `null` | Content rendered before the main label inside the button face. |
| `after` | `Widget?` | `null` | Content rendered after the main label inside the button face. |
| `extra` | `Widget?` | `null` | Content rendered behind the active/content layers, useful for gradients and custom backgrounds. |
| `stretch` | `bool` | `false` | Makes the button fill the available horizontal space. |
| `style` | `AwesomeButtonStyle?` | `null` | Immutable visual override surface for colors, border, raise, animation, and typography. Its `animationDuration` owns direct resolved-style changes. |
| `pressInAnimationDuration` | `Duration?` | `null` | Optional press-down override. When absent, `style.animationDuration` and then the 140 ms package fallback apply. |
| `focusNode` | `FocusNode?` | `null` | Optional focus node for keyboard/focus control. |
| `autofocus` | `bool` | `false` | Requests initial focus when the widget tree is built. |
| `activeOpacity` | `double` | `1` | Opacity applied while the non-progress button is pressed. |
| `debouncedPressTime` | `Duration` | `Duration.zero` | Debounces `onPress` dispatch. |
| `progress` | `bool` | `false` | Enables the progress-button flow. `onPress` receives a `next` callback in this mode. |
| `showProgressBar` | `bool` | `true` | Renders the loading bar during progress. When `false`, progress keeps the spinner and lifecycle but hides the bar. |
| `progressLoadingTime` | `Duration` | `3000ms` | Duration of the loading bar travel in progress mode. |
| `animateSize` | `bool` | `true` | Animates fixed-size geometry changes and auto-width string-label changes. |
| `textTransition` | `bool` | `false` | Enables the Unicode-aware, measured scramble/reveal animation when a non-empty plain string label changes after mount. Transient frames remain single-line and semantics expose the stable target. |
| `animatedPlaceholder` | `bool` | `true` | Enables the shimmer loop when the button has no `child`. |
| `accessibilityLabel` | `String?` | `null` | Spoken identity override; string content is inferred when absent. |
| `accessibilityHint` | `String?` | `null` | Optional explanation for ordinary semantic activation. |
| `accessibilityLongPressLabel` | `String?` | `null` | Optional name for semantic long activation. |
| `onPressIn` | `VoidCallback?` | `null` | Observer callback fired when press-in begins. |
| `onPressOut` | `VoidCallback?` | `null` | Observer callback fired when press-out begins. |
| `onPressedIn` | `VoidCallback?` | `null` | Fires when the internal pressed state is armed. |
| `onPressedOut` | `VoidCallback?` | `null` | Fires after the internal release animation completes. |
| `onProgressStart` | `VoidCallback?` | `null` | Fires when progress mode transitions into loading. |
| `onProgressEnd` | `VoidCallback?` | `null` | Fires when progress mode finishes and the button releases. |

### ThemedButton

`ThemedButton` accepts the `AwesomeButton` parameters plus these
theme-resolution parameters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `config` | `ThemeDefinition?` | `null` | Explicit theme object. When provided, it takes precedence over `name` and `index`. |
| `index` | `int?` | `null` | Theme index used by `getTheme(index: ...)` when `config` and `name` are not provided. |
| `name` | `ThemeName?` | `null` | Named built-in theme selector. Falls back safely to `basic` if invalid. |
| `type` | `ButtonVariant` | `ButtonVariant.primary` | Built-in variant to resolve from the selected theme. |
| `size` | `ButtonSize` | `ButtonSize.medium` | Built-in theme size preset: `icon`, `small`, `medium`, or `large`. |
| `flat` | `bool` | `false` | Requests the `flat` theme variant when available, including while disabled. |
| `transparent` | `bool` | `false` | Makes the visible shell layers transparent while keeping content, press, and progress feedback active. |
| `autoWidth` | `bool` | `false` | Requests in-tree measured auto width instead of the size preset width. String labels can animate width changes. |

## Interaction and Lifecycle

Physical input uses one gesture owner. Callback replacements committed during
a hold are live, removing a long handler disarms that gesture, and adding one
takes effect on the next gesture. Atomic semantic and keyboard activation uses
the same debounce and one-shot progress owner without fabricating a held
press-in/press-out lifecycle, including during progress completion and rollback.
`showProgressBar: false` removes only the face
progress layer; the spinner, busy state, callback order, and completion handle
remain active.

Direct resolved-style changes use `style.animationDuration`. Same-theme
variant changes are owned by the themed wrapper for 200 ms and are forwarded
as already-interpolated frames, so the inner button does not animate them a
second time. Theme-source and transparency changes snap.

## Accessibility, Reduced Motion, and Numeric Validation

The widget exposes one button semantics node. Disabled, busy, and placeholder
states remove activation actions. Plain strings are inferred as the label;
custom primary content should supply `accessibilityLabel`. Text scales and
wraps, logical before/after order follows text direction, and the requested
interaction footprint is at least 48 logical pixels on Android and 44 on
Apple, web, and desktop hosts when parent constraints allow it.

The active platform's Reduce Motion setting snaps press, release, direct-style,
themed-style, size, text, placeholder, progress-swap, and progress-travel
presentation. It does not alter debounce windows, long-press thresholds,
callback ordering, or progress-handle ownership. A visible progress layer is
static and full-face in this mode.

Numeric inputs are normalized before layout: non-finite optional values act as
absent, non-finite required values use their declared defaults, negative
geometry and durations clamp to zero, and opacity clamps to `[0, 1]`. A fixed
width of zero stays an explicit constraint.

## Supported Platforms

The package continues to declare Android, iOS, web, macOS, Linux, and Windows.
Package widget tests run on the host; TalkBack,
Switch Access, VoiceOver, Switch Control, browser assistive technology, macOS
VoiceOver, Windows Narrator, Linux Orca, keyboard, RTL, large-text, and Reduce
Motion checks remain manual runtime evidence rather than demo UI tests.

## Development

Primary package quality gates:

```bash
tool/release-preflight.sh
```

The aggregate performs immutable dependency resolution, formatting, fatal
analysis, package-owned tests with informational LCOV coverage, temporary
Dartdoc link validation, the reviewed API-model comparison, and a pub dry run.
It does not publish. See
[`CONTRIBUTING.md`](https://github.com/rcaferati/flutter_awesome_button/blob/main/CONTRIBUTING.md),
[`tool/api/README.md`](https://github.com/rcaferati/flutter_awesome_button/blob/main/tool/api/README.md),
and
[`PERFORMANCE.md`](https://github.com/rcaferati/flutter_awesome_button/blob/main/PERFORMANCE.md)
for the exact review and evidence policies.

Individual iteration commands include:

```bash
flutter analyze --fatal-infos --fatal-warnings
flutter test
tool/check-docs.sh
tool/check-api-model.sh
dart pub publish --dry-run
```

## Demo Application

The `example/` app mirrors the shared four-tab demo structure:

- `Themed` tab with nested theme navigation, character art, and the
  full themed showcase
- `Progress` tab with dedicated progress-button demos
- `Social` tab with the social-button demos
- `Size Changes` tab with width, theme-size, and text-transition examples

Run it from the package root with:

```bash
cd example
flutter run
```

## Awesome Button Family

Awesome Button is maintained as four native packages that share product
semantics while following each platform's implementation model:

- [React Native Awesome Button](https://github.com/rcaferati/react-native-awesome-button)
- [Flutter Awesome Button](https://github.com/rcaferati/flutter_awesome_button)
- [Kotlin Awesome Button](https://github.com/rcaferati/kotlin-awesome-button)
- [Swift Awesome Button](https://github.com/rcaferati/swift-awesome-button)

## Author

Created and maintained by [Rafael Caferati](https://caferati.dev).

- [GitHub](https://github.com/rcaferati)
- [LinkedIn](https://linkedin.com/in/rcaferati)
- [Instagram](https://instagram.com/rcaferati)

## License

MIT. See the repository's
[LICENSE](https://github.com/rcaferati/flutter_awesome_button/blob/main/LICENSE).

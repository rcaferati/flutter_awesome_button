# Flutter Awesome Button

`flutter_awesome_button` is an RN-style 3D button package for Flutter.

The library exports:

- `AwesomeButton`
- `ThemedButton`
- `getTheme`
- typed Dart models such as `AwesomeButtonStyle`, `AwesomeButtonThemeData`,
  `ThemeName`, `ButtonVariant`, `ButtonSize`, `ThemeButtonStyle`,
  `ThemeSizeStyle`, `ThemeDefinition`, and `RegisteredThemeDefinition`

![Blue demo](https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-blue-new.gif)
![Cartman demo](https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-cartman.gif)
![Rick demo](https://raw.githubusercontent.com/rcaferati/flutter_awesome_button/main/screenshots/demo-button-rick.gif)

## Install

```yaml
dependencies:
  flutter_awesome_button: ^0.9.0
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
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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

## Progress Buttons

When `progress` is enabled, `onPress` receives a `next` callback. Call it when
your work is done to complete the progress animation and release the button.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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

## Themed Buttons

```dart
import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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

## Before / After / Extra Content

Use `before` and `after` for inline content that should animate with the label,
and `extra` for content rendered behind the button body.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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

## Transparent Buttons

`transparent` is supported on `ThemedButton`. It removes the visible shell
layers while preserving the content, hit target, and active/progress feedback.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';

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
- `twitter`
- `messenger`
- `facebook`
- `github`
- `linkedin`
- `whatsapp`
- `reddit`
- `pinterest`
- `youtube`

Unknown variants fall back safely at runtime instead of crashing, but only the
variants above are part of the typed built-in API.

### Sizes

- `icon`
- `small`
- `medium`
- `large`

## Selected Props

The public prop surface is typed through `AwesomeButton` and `ThemedButton`.

### AwesomeButton Props

| Attribute | Type | Default | Description |
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
| `style` | `AwesomeButtonStyle?` | `null` | Immutable visual override surface for colors, border, raise, animation, and typography. |
| `focusNode` | `FocusNode?` | `null` | Optional focus node for keyboard/focus control. |
| `autofocus` | `bool` | `false` | Requests initial focus when the widget tree is built. |
| `activeOpacity` | `double` | `1` | Opacity applied while the non-progress button is pressed. |
| `debouncedPressTime` | `Duration` | `Duration.zero` | Debounces `onPress` dispatch. |
| `progress` | `bool` | `false` | Enables the progress-button flow. `onPress` receives a `next` callback in this mode. |
| `showProgressBar` | `bool` | `true` | Renders the loading bar during progress. When `false`, progress keeps the spinner and lifecycle but hides the bar. |
| `progressLoadingTime` | `Duration` | `3000ms` | Duration of the loading bar travel in progress mode. |
| `textTransition` | `bool` | `false` | Enables the built-in scramble/reveal animation when a plain string label changes after mount. |
| `animatedPlaceholder` | `bool` | `true` | Enables the shimmer loop when the button has no `child`. |
| `onPressIn` | `VoidCallback?` | `null` | Observer callback fired when press-in begins. |
| `onPressOut` | `VoidCallback?` | `null` | Observer callback fired when press-out begins. |
| `onPressedIn` | `VoidCallback?` | `null` | Fires when the internal pressed state is armed. |
| `onPressedOut` | `VoidCallback?` | `null` | Fires after the internal release animation completes. |
| `onProgressStart` | `VoidCallback?` | `null` | Fires when progress mode transitions into loading. |
| `onProgressEnd` | `VoidCallback?` | `null` | Fires when progress mode finishes and the button releases. |

### ThemedButton Additional Props

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `config` | `ThemeDefinition?` | `null` | Explicit theme object. When provided, it takes precedence over `name` and `index`. |
| `index` | `int?` | `null` | Theme index used by `getTheme(index: ...)` when `config` and `name` are not provided. |
| `name` | `ThemeName?` | `null` | Named built-in theme selector. Falls back safely to `basic` if invalid. |
| `type` | `ButtonVariant` | `ButtonVariant.primary` | Built-in variant to resolve from the selected theme. |
| `size` | `ButtonSize` | `ButtonSize.medium` | Built-in theme size preset: `icon`, `small`, `medium`, or `large`. |
| `flat` | `bool` | `false` | Requests the `flat` theme variant when available. |
| `transparent` | `bool` | `false` | Makes the visible shell layers transparent while keeping content, press, and progress feedback active. |
| `autoWidth` | `bool` | `false` | Requests RN-style measured auto width instead of the size preset width. |

## Development

Primary package quality gates:

```bash
flutter analyze
flutter test
```

To validate the package page and publication metadata locally:

```bash
dart format --output=none --set-exit-if-changed .
dart pub publish --dry-run
```

## Example App

The `example/` app mirrors the RN demo structure:

- `Themed Buttons` tab with nested theme navigation, character art, and the
  full themed showcase
- `Progress` tab with dedicated progress-button demos
- `Social` tab with the social-button demos

Run it from the package root with:

```bash
cd example
flutter run
```

## License

MIT.

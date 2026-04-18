import 'package:flutter/material.dart';

import '../awesome_button_style.dart';
import '../awesome_button_theme_data.dart';
import 'colors.dart' as themed_colors;
import 'models.dart';

/// Transparent overrides applied when a themed button opts into transparent
/// rendering.
const ThemeButtonStyle transparentStyles = ThemeButtonStyle(
  backgroundColor: Colors.transparent,
  backgroundDarker: Colors.transparent,
  backgroundPlaceholder: Colors.transparent,
  backgroundShadow: Colors.transparent,
  borderColor: Colors.transparent,
);

/// Resolves the effective themed variant, honoring disabled and flat overrides.
ButtonVariant resolveButtonType(
  ThemeDefinition theme,
  bool disabled,
  bool flat,
  ButtonVariant type,
) {
  final requestedType = disabled
      ? ButtonVariant.disabled
      : flat
          ? ButtonVariant.flat
          : type;

  return theme.buttons.containsKey(requestedType)
      ? requestedType
      : ButtonVariant.primary;
}

/// Returns a stable descriptor for the current theme source.
String getThemeSourceDescriptor({
  required int? index,
  required ThemeName? name,
  required ThemeDefinition? config,
}) {
  if (config != null) {
    return 'config';
  }

  if (name != null) {
    return 'name:${name.name}';
  }

  return 'index:${index ?? 'null'}';
}

/// Returns a palette suitable for color interpolation in themed transitions.
ThemeButtonStyle getInterpolatablePalette(ThemeButtonStyle buttonStyle) {
  final fallback = AwesomeButtonThemeData.fallbackStyle;
  final backgroundColor =
      buttonStyle.backgroundColor ?? _fallbackThemePalette.backgroundColor!;
  final pressedOverlayColor = fallback.pressedOverlayColor!;

  return themed_colors.getInterpolatablePalette(
    buttonStyle.copyWith(
      backgroundActive: buttonStyle.backgroundActive ??
          Color.alphaBlend(pressedOverlayColor, backgroundColor),
    ),
    defaults: _fallbackThemePalette,
  );
}

/// Returns true when two themed palettes are equal.
bool areThemeButtonStylesEqual(ThemeButtonStyle left, ThemeButtonStyle right) {
  return themed_colors.areThemeButtonStylesEqual(left, right);
}

final ThemeButtonStyle _fallbackThemePalette = () {
  final fallback = AwesomeButtonThemeData.fallbackStyle;
  final backgroundColor = fallback.backgroundColor!;
  final pressedOverlayColor = fallback.pressedOverlayColor!;

  return ThemeButtonStyle(
    activityColor: fallback.activityColor ?? fallback.foregroundColor,
    backgroundActive: fallback.backgroundActive ??
        Color.alphaBlend(pressedOverlayColor, backgroundColor),
    backgroundColor: backgroundColor,
    backgroundDarker: fallback.depthColor,
    backgroundPlaceholder: fallback.shadowColor,
    backgroundProgress: fallback.backgroundProgress ?? fallback.depthColor,
    backgroundShadow: fallback.shadowColor,
    borderColor: fallback.borderColor,
    textColor: fallback.foregroundColor,
  );
}();

/// Converts a [ThemeButtonStyle] into the base [AwesomeButtonStyle] format.
AwesomeButtonStyle themeButtonStyleToAwesomeButtonStyle(
  ThemeButtonStyle style,
) {
  return AwesomeButtonStyle(
    activityColor: style.activityColor,
    backgroundActive: style.backgroundActive,
    backgroundColor: style.backgroundColor,
    backgroundPlaceholder: style.backgroundPlaceholder,
    backgroundProgress: style.backgroundProgress,
    depthColor: style.backgroundDarker,
    shadowColor: style.backgroundShadow,
    foregroundColor: style.textColor,
    borderRadius: _resolveBorderRadius(style),
    borderWidth: style.borderWidth,
    borderColor: style.borderColor,
    raiseAmount: style.raiseLevel,
    textSize: style.textSize,
    textLineHeight: style.textLineHeight,
    textFontFamily: style.textFontFamily,
  );
}

BorderRadiusGeometry? _resolveBorderRadius(ThemeButtonStyle style) {
  final baseRadius = style.borderRadius;
  final hasDirectionalRadius = style.borderBottomLeftRadius != null ||
      style.borderBottomRightRadius != null ||
      style.borderTopLeftRadius != null ||
      style.borderTopRightRadius != null;

  if (!hasDirectionalRadius) {
    if (baseRadius == null) {
      return null;
    }
    return BorderRadius.all(Radius.circular(baseRadius));
  }

  final resolvedRadius = baseRadius ?? 0;
  return BorderRadius.only(
    topLeft: Radius.circular(style.borderTopLeftRadius ?? resolvedRadius),
    topRight: Radius.circular(style.borderTopRightRadius ?? resolvedRadius),
    bottomLeft: Radius.circular(style.borderBottomLeftRadius ?? resolvedRadius),
    bottomRight:
        Radius.circular(style.borderBottomRightRadius ?? resolvedRadius),
  );
}

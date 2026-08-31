import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Built-in theme names supported by [ThemedButton] and [getTheme].
enum ThemeName {
  /// The default blue theme.
  basic,

  /// The Bojack-inspired theme.
  bojack,

  /// The Cartman-inspired theme.
  cartman,

  /// The Mysterion-inspired theme.
  mysterion,

  /// The C-137-inspired theme.
  c137,

  /// The Rick-inspired theme.
  rick,

  /// The Summer-inspired theme.
  summer,

  /// The Bruce-inspired theme.
  bruce,
}

/// Built-in button variants supported by themed buttons.
enum ButtonVariant {
  /// Primary action variant.
  primary,

  /// Secondary action variant.
  secondary,

  /// Anchor/link-style variant.
  anchor,

  /// Danger/destructive variant.
  danger,

  /// Disabled visual variant.
  disabled,

  /// Flat visual variant.
  flat,

  /// Legacy Twitter spelling. Use [ButtonVariant.x].
  @Deprecated('Use ButtonVariant.x. Runtime enum identity remains twitter.')
  twitter,

  /// Messenger social variant.
  messenger,

  /// Facebook social variant.
  facebook,

  /// GitHub social variant.
  github,

  /// LinkedIn social variant.
  linkedin,

  /// WhatsApp social variant.
  whatsapp,

  /// Reddit social variant.
  reddit,

  /// Pinterest social variant.
  pinterest,

  /// YouTube social variant.
  youtube;

  /// Canonical X spelling, bridged to the legacy runtime enum value.
  static const ButtonVariant x = ButtonVariant.twitter;
}

/// Built-in size presets used by [ThemedButton].
enum ButtonSize {
  /// Square icon-only size preset.
  icon,

  /// Compact preset.
  small,

  /// Default preset.
  medium,

  /// Large preset.
  large,
}

/// Theme-local style values that map into [AwesomeButtonStyle].
@immutable
class ThemeButtonStyle {
  /// Creates a themed button style definition.
  const ThemeButtonStyle({
    this.activityColor,
    this.backgroundActive,
    this.backgroundColor,
    this.backgroundDarker,
    this.backgroundPlaceholder,
    this.backgroundProgress,
    this.backgroundShadow,
    this.borderColor,
    this.borderRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderWidth,
    this.height,
    this.paddingBottom,
    this.paddingHorizontal,
    this.paddingTop,
    this.raiseLevel,
    this.textColor,
    this.textFontFamily,
    this.textLineHeight,
    this.textSize,
    this.width,
  });

  /// Spinner color.
  final Color? activityColor;

  /// Face color used while pressed.
  final Color? backgroundActive;

  /// Face background color.
  final Color? backgroundColor;

  /// Lower shell color.
  final Color? backgroundDarker;

  /// Placeholder block color.
  final Color? backgroundPlaceholder;

  /// Progress bar fill color.
  final Color? backgroundProgress;

  /// Flat shadow-plane color.
  final Color? backgroundShadow;

  /// Border color.
  final Color? borderColor;

  /// Uniform border radius.
  final double? borderRadius;

  /// Bottom-left corner radius override.
  final double? borderBottomLeftRadius;

  /// Bottom-right corner radius override.
  final double? borderBottomRightRadius;

  /// Top-left corner radius override.
  final double? borderTopLeftRadius;

  /// Top-right corner radius override.
  final double? borderTopRightRadius;

  /// Border width.
  final double? borderWidth;

  /// Face height.
  final double? height;

  /// Bottom content padding.
  final double? paddingBottom;

  /// Horizontal content padding.
  final double? paddingHorizontal;

  /// Top content padding.
  final double? paddingTop;

  /// Raise amount between face and lower shell.
  final double? raiseLevel;

  /// Foreground text color.
  final Color? textColor;

  /// Font family for string content.
  final String? textFontFamily;

  /// Line height for string content.
  final double? textLineHeight;

  /// Text size for string content.
  final double? textSize;

  /// Width override for themed size resolution.
  final double? width;

  /// Returns a copy of this theme style with the provided values replaced.
  ThemeButtonStyle copyWith({
    Color? activityColor,
    Color? backgroundActive,
    Color? backgroundColor,
    Color? backgroundDarker,
    Color? backgroundPlaceholder,
    Color? backgroundProgress,
    Color? backgroundShadow,
    Color? borderColor,
    double? borderRadius,
    double? borderBottomLeftRadius,
    double? borderBottomRightRadius,
    double? borderTopLeftRadius,
    double? borderTopRightRadius,
    double? borderWidth,
    double? height,
    double? paddingBottom,
    double? paddingHorizontal,
    double? paddingTop,
    double? raiseLevel,
    Color? textColor,
    String? textFontFamily,
    double? textLineHeight,
    double? textSize,
    double? width,
  }) {
    return ThemeButtonStyle(
      activityColor: activityColor ?? this.activityColor,
      backgroundActive: backgroundActive ?? this.backgroundActive,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundDarker: backgroundDarker ?? this.backgroundDarker,
      backgroundPlaceholder:
          backgroundPlaceholder ?? this.backgroundPlaceholder,
      backgroundProgress: backgroundProgress ?? this.backgroundProgress,
      backgroundShadow: backgroundShadow ?? this.backgroundShadow,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderBottomLeftRadius:
          borderBottomLeftRadius ?? this.borderBottomLeftRadius,
      borderBottomRightRadius:
          borderBottomRightRadius ?? this.borderBottomRightRadius,
      borderTopLeftRadius: borderTopLeftRadius ?? this.borderTopLeftRadius,
      borderTopRightRadius: borderTopRightRadius ?? this.borderTopRightRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      height: height ?? this.height,
      paddingBottom: paddingBottom ?? this.paddingBottom,
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      paddingTop: paddingTop ?? this.paddingTop,
      raiseLevel: raiseLevel ?? this.raiseLevel,
      textColor: textColor ?? this.textColor,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      textLineHeight: textLineHeight ?? this.textLineHeight,
      textSize: textSize ?? this.textSize,
      width: width ?? this.width,
    );
  }

  /// Merges another themed style on top of this style.
  ThemeButtonStyle merge(ThemeButtonStyle? other) {
    if (other == null) {
      return this;
    }

    return copyWith(
      activityColor: other.activityColor,
      backgroundActive: other.backgroundActive,
      backgroundColor: other.backgroundColor,
      backgroundDarker: other.backgroundDarker,
      backgroundPlaceholder: other.backgroundPlaceholder,
      backgroundProgress: other.backgroundProgress,
      backgroundShadow: other.backgroundShadow,
      borderColor: other.borderColor,
      borderRadius: other.borderRadius,
      borderBottomLeftRadius: other.borderBottomLeftRadius,
      borderBottomRightRadius: other.borderBottomRightRadius,
      borderTopLeftRadius: other.borderTopLeftRadius,
      borderTopRightRadius: other.borderTopRightRadius,
      borderWidth: other.borderWidth,
      height: other.height,
      paddingBottom: other.paddingBottom,
      paddingHorizontal: other.paddingHorizontal,
      paddingTop: other.paddingTop,
      raiseLevel: other.raiseLevel,
      textColor: other.textColor,
      textFontFamily: other.textFontFamily,
      textLineHeight: other.textLineHeight,
      textSize: other.textSize,
      width: other.width,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ThemeButtonStyle &&
        other.activityColor == activityColor &&
        other.backgroundActive == backgroundActive &&
        other.backgroundColor == backgroundColor &&
        other.backgroundDarker == backgroundDarker &&
        other.backgroundPlaceholder == backgroundPlaceholder &&
        other.backgroundProgress == backgroundProgress &&
        other.backgroundShadow == backgroundShadow &&
        other.borderColor == borderColor &&
        other.borderRadius == borderRadius &&
        other.borderBottomLeftRadius == borderBottomLeftRadius &&
        other.borderBottomRightRadius == borderBottomRightRadius &&
        other.borderTopLeftRadius == borderTopLeftRadius &&
        other.borderTopRightRadius == borderTopRightRadius &&
        other.borderWidth == borderWidth &&
        other.height == height &&
        other.paddingBottom == paddingBottom &&
        other.paddingHorizontal == paddingHorizontal &&
        other.paddingTop == paddingTop &&
        other.raiseLevel == raiseLevel &&
        other.textColor == textColor &&
        other.textFontFamily == textFontFamily &&
        other.textLineHeight == textLineHeight &&
        other.textSize == textSize &&
        other.width == width;
  }

  @override
  int get hashCode => Object.hashAll([
        activityColor,
        backgroundActive,
        backgroundColor,
        backgroundDarker,
        backgroundPlaceholder,
        backgroundProgress,
        backgroundShadow,
        borderColor,
        borderRadius,
        borderBottomLeftRadius,
        borderBottomRightRadius,
        borderTopLeftRadius,
        borderTopRightRadius,
        borderWidth,
        height,
        paddingBottom,
        paddingHorizontal,
        paddingTop,
        raiseLevel,
        textColor,
        textFontFamily,
        textLineHeight,
        textSize,
        width,
      ]);
}

/// Size preset values used by [ThemeDefinition.size].
@immutable
class ThemeSizeStyle {
  /// Creates a themed size preset.
  const ThemeSizeStyle({
    required this.width,
    required this.height,
    this.textSize,
    this.paddingHorizontal,
  });

  /// Resolved width for the preset.
  final double width;

  /// Resolved height for the preset.
  final double height;

  /// Optional text size override.
  final double? textSize;

  /// Optional horizontal padding override.
  final double? paddingHorizontal;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ThemeSizeStyle &&
        other.width == width &&
        other.height == height &&
        other.textSize == textSize &&
        other.paddingHorizontal == paddingHorizontal;
  }

  @override
  int get hashCode => Object.hash(width, height, textSize, paddingHorizontal);
}

/// Full built-in theme definition consumed by [ThemedButton].
@immutable
class ThemeDefinition {
  /// Creates a theme definition.
  const ThemeDefinition({
    required this.title,
    required this.background,
    required this.color,
    required this.buttons,
    required this.size,
  });

  /// Display title used by the demo app and theme metadata.
  final String title;

  /// Theme background color.
  final Color background;

  /// Foreground color paired with [background].
  final Color color;

  /// Variant style map for the theme.
  final Map<ButtonVariant, ThemeButtonStyle> buttons;

  /// Size preset map for the theme.
  final Map<ButtonSize, ThemeSizeStyle> size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ThemeDefinition &&
        other.title == title &&
        other.background == background &&
        other.color == color &&
        mapEquals(other.buttons, buttons) &&
        mapEquals(other.size, size);
  }

  @override
  int get hashCode => Object.hash(
        title,
        background,
        color,
        Object.hashAll(buttons.entries
            .map((entry) => Object.hash(entry.key, entry.value))),
        Object.hashAll(
            size.entries.map((entry) => Object.hash(entry.key, entry.value))),
      );
}

/// Registered theme definition enriched with navigation metadata.
@immutable
class RegisteredThemeDefinition extends ThemeDefinition {
  /// Creates a registered theme definition.
  const RegisteredThemeDefinition({
    required super.title,
    required super.background,
    required super.color,
    required super.buttons,
    required super.size,
    required this.name,
    required this.next,
    required this.prev,
  });

  /// Stable built-in theme name.
  final ThemeName name;

  /// Whether the next built-in theme exists.
  final bool next;

  /// Whether the previous built-in theme exists.
  final bool prev;
}

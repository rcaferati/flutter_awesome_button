import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ThemeName {
  basic,
  bojack,
  cartman,
  mysterion,
  c137,
  rick,
  summer,
  bruce,
}

enum ButtonVariant {
  primary,
  secondary,
  anchor,
  danger,
  disabled,
  flat,
  twitter,
  messenger,
  facebook,
  github,
  linkedin,
  whatsapp,
  reddit,
  pinterest,
  youtube,
}

enum ButtonSize {
  icon,
  small,
  medium,
  large,
}

@immutable
class ThemeButtonStyle {
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

  final Color? activityColor;
  final Color? backgroundActive;
  final Color? backgroundColor;
  final Color? backgroundDarker;
  final Color? backgroundPlaceholder;
  final Color? backgroundProgress;
  final Color? backgroundShadow;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderBottomLeftRadius;
  final double? borderBottomRightRadius;
  final double? borderTopLeftRadius;
  final double? borderTopRightRadius;
  final double? borderWidth;
  final double? height;
  final double? paddingBottom;
  final double? paddingHorizontal;
  final double? paddingTop;
  final double? raiseLevel;
  final Color? textColor;
  final String? textFontFamily;
  final double? textLineHeight;
  final double? textSize;
  final double? width;

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

@immutable
class ThemeSizeStyle {
  const ThemeSizeStyle({
    required this.width,
    required this.height,
    this.textSize,
    this.paddingHorizontal,
  });

  final double width;
  final double height;
  final double? textSize;
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

@immutable
class ThemeDefinition {
  const ThemeDefinition({
    required this.title,
    required this.background,
    required this.color,
    required this.buttons,
    required this.size,
  });

  final String title;
  final Color background;
  final Color color;
  final Map<ButtonVariant, ThemeButtonStyle> buttons;
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

@immutable
class RegisteredThemeDefinition extends ThemeDefinition {
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

  final ThemeName name;
  final bool next;
  final bool prev;
}

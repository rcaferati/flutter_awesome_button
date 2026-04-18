import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';

Color blendColors(
  double percentage,
  Color startColor, [
  Color? endColor,
  bool linear = false,
]) {
  assert(percentage >= -1 && percentage <= 1);

  final blendTarget = endColor ??
      (percentage < 0 ? const Color(0xFF000000) : const Color(0xFFFFFFFF));
  final ratio = percentage.abs();
  final inverse = 1 - ratio;
  double mix(int startValue, int targetValue) {
    if (linear) {
      return (inverse * startValue) + (ratio * targetValue);
    }

    return math.sqrt(
      (inverse * startValue * startValue) + (ratio * targetValue * targetValue),
    );
  }

  final startAlpha = (startColor.a * 255.0).round().clamp(0, 255);
  final endAlpha = (blendTarget.a * 255.0).round().clamp(0, 255);
  final alpha = startAlpha == 0xFF && endAlpha == 0xFF
      ? 0xFF
      : ((inverse * startAlpha) + (ratio * endAlpha)).round();

  return Color.fromARGB(
    alpha.clamp(0, 255),
    mix(
      (startColor.r * 255.0).round().clamp(0, 255),
      (blendTarget.r * 255.0).round().clamp(0, 255),
    ).round().clamp(0, 255),
    mix(
      (startColor.g * 255.0).round().clamp(0, 255),
      (blendTarget.g * 255.0).round().clamp(0, 255),
    ).round().clamp(0, 255),
    mix(
      (startColor.b * 255.0).round().clamp(0, 255),
      (blendTarget.b * 255.0).round().clamp(0, 255),
    ).round().clamp(0, 255),
  );
}

ThemeButtonStyle interpolateThemeButtonStyle(
  ThemeButtonStyle from,
  ThemeButtonStyle to,
  double progress,
) {
  final safeProgress = progress.clamp(0.0, 1.0);
  return ThemeButtonStyle(
    activityColor:
        Color.lerp(from.activityColor, to.activityColor, safeProgress),
    backgroundActive: Color.lerp(
      from.backgroundActive,
      to.backgroundActive,
      safeProgress,
    ),
    backgroundColor: Color.lerp(
      from.backgroundColor,
      to.backgroundColor,
      safeProgress,
    ),
    backgroundDarker: Color.lerp(
      from.backgroundDarker,
      to.backgroundDarker,
      safeProgress,
    ),
    backgroundPlaceholder: Color.lerp(
      from.backgroundPlaceholder,
      to.backgroundPlaceholder,
      safeProgress,
    ),
    backgroundProgress: Color.lerp(
      from.backgroundProgress,
      to.backgroundProgress,
      safeProgress,
    ),
    backgroundShadow: Color.lerp(
      from.backgroundShadow,
      to.backgroundShadow,
      safeProgress,
    ),
    borderColor: Color.lerp(from.borderColor, to.borderColor, safeProgress),
    borderRadius: to.borderRadius,
    borderBottomLeftRadius: to.borderBottomLeftRadius,
    borderBottomRightRadius: to.borderBottomRightRadius,
    borderTopLeftRadius: to.borderTopLeftRadius,
    borderTopRightRadius: to.borderTopRightRadius,
    borderWidth: to.borderWidth,
    height: to.height,
    paddingBottom: to.paddingBottom,
    paddingHorizontal: to.paddingHorizontal,
    paddingTop: to.paddingTop,
    raiseLevel: to.raiseLevel,
    textColor: Color.lerp(from.textColor, to.textColor, safeProgress),
    textFontFamily: to.textFontFamily,
    textLineHeight: to.textLineHeight,
    textSize: to.textSize,
    width: to.width,
  );
}

bool areThemeButtonStylesEqual(ThemeButtonStyle left, ThemeButtonStyle right) {
  return left == right;
}

ThemeButtonStyle getInterpolatablePalette(
  ThemeButtonStyle buttonStyle, {
  required ThemeButtonStyle defaults,
}) {
  return buttonStyle.copyWith(
    activityColor: buttonStyle.activityColor ?? defaults.activityColor,
    backgroundActive: buttonStyle.backgroundActive ?? defaults.backgroundActive,
    backgroundColor: buttonStyle.backgroundColor ?? defaults.backgroundColor,
    backgroundDarker: buttonStyle.backgroundDarker ?? defaults.backgroundDarker,
    backgroundPlaceholder:
        buttonStyle.backgroundPlaceholder ?? defaults.backgroundPlaceholder,
    backgroundProgress:
        buttonStyle.backgroundProgress ?? defaults.backgroundProgress,
    backgroundShadow: buttonStyle.backgroundShadow ?? defaults.backgroundShadow,
    borderColor: buttonStyle.borderColor ?? defaults.borderColor,
    textColor: buttonStyle.textColor ?? defaults.textColor,
  );
}

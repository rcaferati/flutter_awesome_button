import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

double? _finiteOrNull(double? value) =>
    value != null && value.isFinite ? value : null;

/// Visual configuration for [AwesomeButton].
@immutable
class AwesomeButtonStyle {
  /// Creates a style override for [AwesomeButton].
  const AwesomeButtonStyle({
    this.backgroundColor,
    this.backgroundActive,
    this.backgroundPlaceholder,
    this.backgroundProgress,
    this.depthColor,
    this.shadowColor,
    this.activityColor,
    this.pressedOverlayColor,
    this.foregroundColor,
    this.textSize,
    this.textLineHeight,
    this.textFontFamily,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.raiseAmount,
    this.contentGap,
    this.animationDuration,
    this.pressInAnimationDuration,
    this.animationCurve,
    this.disabledBackgroundColor,
    this.disabledDepthColor,
    this.disabledShadowColor,
    this.disabledForegroundColor,
    this.disabledBorderColor,
  });

  /// Face background color.
  final Color? backgroundColor;

  /// Face background color shown while the button is actively pressed.
  final Color? backgroundActive;

  /// Placeholder block color used when the button has no child.
  final Color? backgroundPlaceholder;

  /// Progress bar fill color shown during loading.
  final Color? backgroundProgress;

  /// Fixed bottom shell color.
  final Color? depthColor;

  /// Flat translucent shadow-plane color.
  final Color? shadowColor;

  /// Activity indicator color.
  final Color? activityColor;

  /// Overlay color blended into the face when no explicit active color exists.
  final Color? pressedOverlayColor;

  /// Main foreground color for text and icon content.
  final Color? foregroundColor;

  /// Text size for string children.
  final double? textSize;

  /// Text line height for string children.
  final double? textLineHeight;

  /// Font family used for string children.
  final String? textFontFamily;

  /// Border radius for the moving face and lower layers.
  final BorderRadiusGeometry? borderRadius;

  /// Border width applied to the face.
  final double? borderWidth;

  /// Border color applied to the face.
  final Color? borderColor;

  /// Distance between the face and the bottom shell at rest.
  final double? raiseAmount;

  /// Gap between `before`, `child`, and `after` content.
  final double? contentGap;

  /// Press-in animation duration.
  final Duration? animationDuration;

  /// Optional press-down timing override.
  final Duration? pressInAnimationDuration;

  /// Press-in animation curve.
  final Curve? animationCurve;

  /// Face background color used when the button is disabled.
  final Color? disabledBackgroundColor;

  /// Bottom shell color used when the button is disabled.
  final Color? disabledDepthColor;

  /// Shadow-plane color used when the button is disabled.
  final Color? disabledShadowColor;

  /// Foreground color used when the button is disabled.
  final Color? disabledForegroundColor;

  /// Border color used when the button is disabled.
  final Color? disabledBorderColor;

  /// Returns a copy of this style with the provided values replaced.
  AwesomeButtonStyle copyWith({
    Color? backgroundColor,
    Color? backgroundActive,
    Color? backgroundPlaceholder,
    Color? backgroundProgress,
    Color? depthColor,
    Color? shadowColor,
    Color? activityColor,
    Color? pressedOverlayColor,
    Color? foregroundColor,
    double? textSize,
    double? textLineHeight,
    String? textFontFamily,
    BorderRadiusGeometry? borderRadius,
    double? borderWidth,
    Color? borderColor,
    double? raiseAmount,
    double? contentGap,
    Duration? animationDuration,
    Duration? pressInAnimationDuration,
    Curve? animationCurve,
    Color? disabledBackgroundColor,
    Color? disabledDepthColor,
    Color? disabledShadowColor,
    Color? disabledForegroundColor,
    Color? disabledBorderColor,
  }) {
    return AwesomeButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundActive: backgroundActive ?? this.backgroundActive,
      backgroundPlaceholder:
          backgroundPlaceholder ?? this.backgroundPlaceholder,
      backgroundProgress: backgroundProgress ?? this.backgroundProgress,
      depthColor: depthColor ?? this.depthColor,
      shadowColor: shadowColor ?? this.shadowColor,
      activityColor: activityColor ?? this.activityColor,
      pressedOverlayColor: pressedOverlayColor ?? this.pressedOverlayColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      textSize: textSize ?? this.textSize,
      textLineHeight: textLineHeight ?? this.textLineHeight,
      textFontFamily: textFontFamily ?? this.textFontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      raiseAmount: raiseAmount ?? this.raiseAmount,
      contentGap: contentGap ?? this.contentGap,
      animationDuration: animationDuration ?? this.animationDuration,
      pressInAnimationDuration:
          pressInAnimationDuration ?? this.pressInAnimationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledDepthColor: disabledDepthColor ?? this.disabledDepthColor,
      disabledShadowColor: disabledShadowColor ?? this.disabledShadowColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
    );
  }

  /// Merges another style on top of this style.
  AwesomeButtonStyle merge(AwesomeButtonStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      backgroundActive: other.backgroundActive,
      backgroundPlaceholder: other.backgroundPlaceholder,
      backgroundProgress: other.backgroundProgress,
      depthColor: other.depthColor,
      shadowColor: other.shadowColor,
      activityColor: other.activityColor,
      pressedOverlayColor: other.pressedOverlayColor,
      foregroundColor: other.foregroundColor,
      textSize: _finiteOrNull(other.textSize),
      textLineHeight: _finiteOrNull(other.textLineHeight),
      textFontFamily: other.textFontFamily,
      borderRadius: other.borderRadius,
      borderWidth: _finiteOrNull(other.borderWidth),
      borderColor: other.borderColor,
      raiseAmount: _finiteOrNull(other.raiseAmount),
      contentGap: _finiteOrNull(other.contentGap),
      animationDuration: other.animationDuration,
      pressInAnimationDuration: other.pressInAnimationDuration,
      animationCurve: other.animationCurve,
      disabledBackgroundColor: other.disabledBackgroundColor,
      disabledDepthColor: other.disabledDepthColor,
      disabledShadowColor: other.disabledShadowColor,
      disabledForegroundColor: other.disabledForegroundColor,
      disabledBorderColor: other.disabledBorderColor,
    );
  }

  /// Interpolates between two button styles.
  static AwesomeButtonStyle lerp(
    AwesomeButtonStyle a,
    AwesomeButtonStyle b,
    double t,
  ) {
    return AwesomeButtonStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      backgroundActive: Color.lerp(
        a.backgroundActive,
        b.backgroundActive,
        t,
      ),
      backgroundPlaceholder: Color.lerp(
        a.backgroundPlaceholder,
        b.backgroundPlaceholder,
        t,
      ),
      backgroundProgress: Color.lerp(
        a.backgroundProgress,
        b.backgroundProgress,
        t,
      ),
      depthColor: Color.lerp(a.depthColor, b.depthColor, t),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      activityColor: Color.lerp(a.activityColor, b.activityColor, t),
      pressedOverlayColor:
          Color.lerp(a.pressedOverlayColor, b.pressedOverlayColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      textSize: lerpDouble(a.textSize, b.textSize, t),
      textLineHeight: lerpDouble(a.textLineHeight, b.textLineHeight, t),
      textFontFamily: t < 0.5 ? a.textFontFamily : b.textFontFamily,
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      raiseAmount: lerpDouble(a.raiseAmount, b.raiseAmount, t),
      contentGap: lerpDouble(a.contentGap, b.contentGap, t),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      pressInAnimationDuration:
          t < 0.5 ? a.pressInAnimationDuration : b.pressInAnimationDuration,
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
      disabledBackgroundColor: Color.lerp(
        a.disabledBackgroundColor,
        b.disabledBackgroundColor,
        t,
      ),
      disabledDepthColor:
          Color.lerp(a.disabledDepthColor, b.disabledDepthColor, t),
      disabledShadowColor:
          Color.lerp(a.disabledShadowColor, b.disabledShadowColor, t),
      disabledForegroundColor: Color.lerp(
        a.disabledForegroundColor,
        b.disabledForegroundColor,
        t,
      ),
      disabledBorderColor:
          Color.lerp(a.disabledBorderColor, b.disabledBorderColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AwesomeButtonStyle &&
        other.backgroundColor == backgroundColor &&
        other.backgroundActive == backgroundActive &&
        other.backgroundPlaceholder == backgroundPlaceholder &&
        other.backgroundProgress == backgroundProgress &&
        other.depthColor == depthColor &&
        other.shadowColor == shadowColor &&
        other.activityColor == activityColor &&
        other.pressedOverlayColor == pressedOverlayColor &&
        other.foregroundColor == foregroundColor &&
        other.textSize == textSize &&
        other.textLineHeight == textLineHeight &&
        other.textFontFamily == textFontFamily &&
        other.borderRadius == borderRadius &&
        other.borderWidth == borderWidth &&
        other.borderColor == borderColor &&
        other.raiseAmount == raiseAmount &&
        other.contentGap == contentGap &&
        other.animationDuration == animationDuration &&
        other.pressInAnimationDuration == pressInAnimationDuration &&
        other.animationCurve == animationCurve &&
        other.disabledBackgroundColor == disabledBackgroundColor &&
        other.disabledDepthColor == disabledDepthColor &&
        other.disabledShadowColor == disabledShadowColor &&
        other.disabledForegroundColor == disabledForegroundColor &&
        other.disabledBorderColor == disabledBorderColor;
  }

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        backgroundActive,
        backgroundPlaceholder,
        backgroundProgress,
        depthColor,
        shadowColor,
        activityColor,
        pressedOverlayColor,
        foregroundColor,
        textSize,
        textLineHeight,
        textFontFamily,
        borderRadius,
        borderWidth,
        borderColor,
        raiseAmount,
        contentGap,
        animationDuration,
        pressInAnimationDuration,
        animationCurve,
        disabledBackgroundColor,
        disabledDepthColor,
        disabledShadowColor,
        disabledForegroundColor,
        disabledBorderColor,
      ]);
}

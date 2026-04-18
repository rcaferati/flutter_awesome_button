import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AwesomeButtonStyle {
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
    this.animationCurve,
    this.disabledBackgroundColor,
    this.disabledDepthColor,
    this.disabledShadowColor,
    this.disabledForegroundColor,
    this.disabledBorderColor,
  });

  final Color? backgroundColor;
  final Color? backgroundActive;
  final Color? backgroundPlaceholder;
  final Color? backgroundProgress;
  final Color? depthColor;
  final Color? shadowColor;
  final Color? activityColor;
  final Color? pressedOverlayColor;
  final Color? foregroundColor;
  final double? textSize;
  final double? textLineHeight;
  final String? textFontFamily;
  final BorderRadiusGeometry? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? raiseAmount;
  final double? contentGap;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final Color? disabledBackgroundColor;
  final Color? disabledDepthColor;
  final Color? disabledShadowColor;
  final Color? disabledForegroundColor;
  final Color? disabledBorderColor;

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
      textSize: other.textSize,
      textLineHeight: other.textLineHeight,
      textFontFamily: other.textFontFamily,
      borderRadius: other.borderRadius,
      borderWidth: other.borderWidth,
      borderColor: other.borderColor,
      raiseAmount: other.raiseAmount,
      contentGap: other.contentGap,
      animationDuration: other.animationDuration,
      animationCurve: other.animationCurve,
      disabledBackgroundColor: other.disabledBackgroundColor,
      disabledDepthColor: other.disabledDepthColor,
      disabledShadowColor: other.disabledShadowColor,
      disabledForegroundColor: other.disabledForegroundColor,
      disabledBorderColor: other.disabledBorderColor,
    );
  }

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
        animationCurve,
        disabledBackgroundColor,
        disabledDepthColor,
        disabledShadowColor,
        disabledForegroundColor,
        disabledBorderColor,
      ]);
}

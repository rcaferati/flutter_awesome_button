part of '../awesome_button.dart';

class _ResolvedAwesomeButtonStyle {
  const _ResolvedAwesomeButtonStyle({
    required this.backgroundColor,
    required this.activeBackgroundColor,
    required this.backgroundPlaceholderColor,
    required this.progressFillColor,
    required this.activityColor,
    required this.depthColor,
    required this.shadowColor,
    required this.pressedOverlayColor,
    required this.foregroundColor,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.raiseAmount,
    required this.contentGap,
    required this.animationDuration,
    required this.animationCurve,
  });

  final Color backgroundColor;
  final Color activeBackgroundColor;
  final Color backgroundPlaceholderColor;
  final Color progressFillColor;
  final Color activityColor;
  final Color depthColor;
  final Color shadowColor;
  final Color pressedOverlayColor;
  final Color foregroundColor;
  final double textSize;
  final double textLineHeight;
  final String? textFontFamily;
  final BorderRadiusGeometry borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double raiseAmount;
  final double contentGap;
  final Duration animationDuration;
  final Curve animationCurve;

  static _ResolvedAwesomeButtonStyle lerp(
    _ResolvedAwesomeButtonStyle from,
    _ResolvedAwesomeButtonStyle to,
    double progress,
  ) {
    final t = progress.clamp(0.0, 1.0);
    return _ResolvedAwesomeButtonStyle(
      backgroundColor: Color.lerp(from.backgroundColor, to.backgroundColor, t)!,
      activeBackgroundColor: Color.lerp(
        from.activeBackgroundColor,
        to.activeBackgroundColor,
        t,
      )!,
      backgroundPlaceholderColor: Color.lerp(
        from.backgroundPlaceholderColor,
        to.backgroundPlaceholderColor,
        t,
      )!,
      progressFillColor:
          Color.lerp(from.progressFillColor, to.progressFillColor, t)!,
      activityColor: Color.lerp(from.activityColor, to.activityColor, t)!,
      depthColor: Color.lerp(from.depthColor, to.depthColor, t)!,
      shadowColor: Color.lerp(from.shadowColor, to.shadowColor, t)!,
      pressedOverlayColor: Color.lerp(
        from.pressedOverlayColor,
        to.pressedOverlayColor,
        t,
      )!,
      foregroundColor: Color.lerp(from.foregroundColor, to.foregroundColor, t)!,
      textSize: lerpDouble(from.textSize, to.textSize, t)!,
      textLineHeight: lerpDouble(from.textLineHeight, to.textLineHeight, t)!,
      textFontFamily: t < 1 ? from.textFontFamily : to.textFontFamily,
      borderRadius: BorderRadiusGeometry.lerp(
        from.borderRadius,
        to.borderRadius,
        t,
      )!,
      borderWidth: lerpDouble(from.borderWidth, to.borderWidth, t)!,
      borderColor: Color.lerp(from.borderColor, to.borderColor, t)!,
      raiseAmount: lerpDouble(from.raiseAmount, to.raiseAmount, t)!,
      contentGap: lerpDouble(from.contentGap, to.contentGap, t)!,
      animationDuration: to.animationDuration,
      animationCurve: to.animationCurve,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ResolvedAwesomeButtonStyle &&
          other.backgroundColor == backgroundColor &&
          other.activeBackgroundColor == activeBackgroundColor &&
          other.backgroundPlaceholderColor == backgroundPlaceholderColor &&
          other.progressFillColor == progressFillColor &&
          other.activityColor == activityColor &&
          other.depthColor == depthColor &&
          other.shadowColor == shadowColor &&
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
          other.animationCurve == animationCurve;

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        activeBackgroundColor,
        backgroundPlaceholderColor,
        progressFillColor,
        activityColor,
        depthColor,
        shadowColor,
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
      ]);
}

class _ResolvedAwesomeButtonStyleTween
    extends Tween<_ResolvedAwesomeButtonStyle> {
  _ResolvedAwesomeButtonStyleTween({required super.end});

  @override
  _ResolvedAwesomeButtonStyle lerp(double t) {
    final target = end!;
    return _ResolvedAwesomeButtonStyle.lerp(begin ?? target, target, t);
  }
}

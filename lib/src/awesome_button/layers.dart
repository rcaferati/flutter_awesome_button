part of '../awesome_button.dart';

class _ButtonShadowLayer extends StatelessWidget {
  const _ButtonShadowLayer({
    required this.height,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final double height;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('aws-btn-shadow'),
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _ButtonBottomLayer extends StatelessWidget {
  const _ButtonBottomLayer({
    required this.height,
    required this.backgroundColor,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.stretch,
  });

  final double height;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Color borderColor;
  final double borderWidth;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('aws-btn-bottom-shell'),
      width: stretch ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: borderWidth > 0
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
        ),
      ),
    );
  }
}

class _ButtonFaceLayer extends StatelessWidget {
  const _ButtonFaceLayer({
    required this.stretch,
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.foregroundColor,
    required this.activeBackgroundColor,
    required this.activeBackgroundOpacity,
    required this.hoverOverlayColor,
    required this.before,
    required this.after,
    required this.extra,
    required this.child,
    required this.displayedText,
    required this.contentGap,
    required this.backgroundPlaceholderColor,
    required this.progressFillColor,
    required this.activityColor,
    required this.progressValue,
    required this.progressOverlayOpacity,
    required this.contentTransitionValue,
    required this.activityTransitionValue,
    required this.showProgressVisuals,
    required this.showProgressBar,
    required this.animatedPlaceholder,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
  });

  final bool stretch;
  final double height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color foregroundColor;
  final Color activeBackgroundColor;
  final double activeBackgroundOpacity;
  final Color hoverOverlayColor;
  final Widget? before;
  final Widget? after;
  final Widget? extra;
  final Object? child;
  final String? displayedText;
  final double contentGap;
  final Color backgroundPlaceholderColor;
  final Color progressFillColor;
  final Color activityColor;
  final double progressValue;
  final double progressOverlayOpacity;
  final double contentTransitionValue;
  final double activityTransitionValue;
  final bool showProgressVisuals;
  final bool showProgressBar;
  final bool animatedPlaceholder;
  final double textSize;
  final double textLineHeight;
  final String? textFontFamily;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final contentOpacity = contentTransitionValue.clamp(0.0, 1.0);
    final activityOpacity = activityTransitionValue.clamp(0.0, 1.0);
    final overlayOpacity = progressOverlayOpacity.clamp(0.0, 1.0);
    final hasPlaceholder = child == null;
    final contentInset = EdgeInsets.all(borderWidth);
    final innerBorderRadius = _insetBorderRadius(borderRadius, borderWidth);
    final renderedChild = switch (child) {
      final String text => Text(
          displayedText ?? text,
          key: const ValueKey<String>('aws-btn-content-text'),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      final Widget widget => widget,
      _ => const SizedBox.shrink(),
    };

    return SizedBox(
      key: const ValueKey<String>('aws-btn-face'),
      width: stretch ? double.infinity : null,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
          ),
          child: Padding(
            padding: contentInset,
            child: ClipRRect(
              borderRadius: innerBorderRadius,
              child: Stack(
                alignment: Alignment.center,
                fit: stretch ? StackFit.expand : StackFit.loose,
                children: [
                  if (extra != null)
                    Positioned.fill(child: IgnorePointer(child: extra!)),
                  if (activeBackgroundColor.a > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          key: const ValueKey<String>(
                              'aws-btn-active-background'),
                          opacity: activeBackgroundOpacity.clamp(0.0, 1.0),
                          child: DecoratedBox(
                            decoration:
                                BoxDecoration(color: activeBackgroundColor),
                          ),
                        ),
                      ),
                    ),
                  if (showProgressVisuals && showProgressBar)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          key: const ValueKey<String>(
                              'aws-btn-progress-overlay'),
                          opacity: overlayOpacity,
                          child: FractionalTranslation(
                            translation: Offset(
                              (progressValue.clamp(0.0, 1.0) - 1) *
                                  (direction == TextDirection.rtl ? -1 : 1),
                              0,
                            ),
                            child: DecoratedBox(
                              key: const ValueKey<String>(
                                  'aws-btn-progress-fill'),
                              decoration: BoxDecoration(
                                color: progressFillColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: padding,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          key: const ValueKey<String>(
                              'aws-btn-content-transition'),
                          scale: contentTransitionValue,
                          child: Opacity(
                            key: const ValueKey<String>(
                                'aws-btn-content-opacity'),
                            opacity: contentOpacity,
                            child: hasPlaceholder
                                ? _ButtonPlaceholder(
                                    animated: animatedPlaceholder,
                                    backgroundColor: backgroundPlaceholderColor,
                                    height: textLineHeight,
                                  )
                                : _ButtonContent(
                                    stretch: stretch,
                                    foregroundColor: foregroundColor,
                                    gap: contentGap,
                                    before: before,
                                    after: after,
                                    textSize: textSize,
                                    textLineHeight: textLineHeight,
                                    textFontFamily: textFontFamily,
                                    child: renderedChild,
                                  ),
                          ),
                        ),
                        if (showProgressVisuals)
                          IgnorePointer(
                            child: Transform.scale(
                              key: const ValueKey<String>(
                                  'aws-btn-activity-transition'),
                              scale: activityTransitionValue,
                              child: Opacity(
                                key: const ValueKey<String>(
                                    'aws-btn-activity-opacity'),
                                opacity: activityOpacity,
                                child: Center(
                                  child: SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        activityColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hoverOverlayColor.a > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: hoverOverlayColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

BorderRadius _insetBorderRadius(BorderRadius borderRadius, double inset) {
  if (inset <= 0) {
    return borderRadius;
  }

  Radius insetRadius(Radius radius) {
    return Radius.elliptical(
      math.max(0.0, radius.x - inset),
      math.max(0.0, radius.y - inset),
    );
  }

  return BorderRadius.only(
    topLeft: insetRadius(borderRadius.topLeft),
    topRight: insetRadius(borderRadius.topRight),
    bottomLeft: insetRadius(borderRadius.bottomLeft),
    bottomRight: insetRadius(borderRadius.bottomRight),
  );
}

double _origamiTensionToStiffness(double tension) {
  return (tension - 30.0) * 3.62 + 194.0;
}

double _origamiFrictionToDamping(double friction) {
  return (friction - 8.0) * 3.0 + 25.0;
}

class _RnElasticCurve extends Curve {
  const _RnElasticCurve(this.bounciness);

  final double bounciness;

  @override
  double transformInternal(double t) {
    final p = bounciness * math.pi;
    return 1 - math.pow(math.cos(t * math.pi / 2), 3) * math.cos(t * p);
  }
}

import 'package:flutter/widgets.dart';

/// Internal package scope used when a themed owner supplies interpolated frames.
class AwesomeButtonStyleFrameScope extends InheritedWidget {
  /// Creates an internal style-frame ownership scope.
  const AwesomeButtonStyleFrameScope({
    required this.framesArePreInterpolated,
    required super.child,
    super.key,
  });

  /// Whether the child receives already interpolated visual frames.
  final bool framesArePreInterpolated;

  /// Reads the nearest package-owned frame ownership decision.
  static bool framesArePreInterpolatedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AwesomeButtonStyleFrameScope>()
          ?.framesArePreInterpolated ??
      false;

  @override
  bool updateShouldNotify(AwesomeButtonStyleFrameScope oldWidget) =>
      framesArePreInterpolated != oldWidget.framesArePreInterpolated;
}

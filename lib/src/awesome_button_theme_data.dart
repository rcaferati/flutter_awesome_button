import 'package:flutter/material.dart';

import 'awesome_button_style.dart';

/// Theme extension that provides the default visual treatment for
/// [AwesomeButton] instances.
@immutable
class AwesomeButtonThemeData extends ThemeExtension<AwesomeButtonThemeData> {
  /// Creates theme data for [AwesomeButton] widgets.
  const AwesomeButtonThemeData({
    required this.style,
  });

  /// Base style values used by the theme.
  final AwesomeButtonStyle style;

  /// Fallback style used when no [Theme.of] extension is provided.
  static const AwesomeButtonStyle fallbackStyle = AwesomeButtonStyle(
    backgroundColor: Color(0xFF2563EB),
    depthColor: Color(0xFF1D4ED8),
    shadowColor: Color.fromRGBO(0, 0, 0, 0.15),
    backgroundPlaceholder: Color.fromRGBO(0, 0, 0, 0.15),
    backgroundProgress: Color.fromRGBO(0, 0, 0, 0.15),
    pressedOverlayColor: Color(0x14000000),
    foregroundColor: Colors.white,
    activityColor: Colors.white,
    textSize: 14,
    textLineHeight: 20,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderWidth: 0,
    borderColor: Colors.transparent,
    raiseAmount: 6,
    contentGap: 10,
    animationDuration: Duration(milliseconds: 140),
    animationCurve: Curves.easeOutCubic,
    disabledBackgroundColor: Color(0xFFB8C6DB),
    disabledDepthColor: Color(0xFF98A9C2),
    disabledShadowColor: Color.fromRGBO(0, 0, 0, 0.10),
    disabledForegroundColor: Color(0xFFF8FAFC),
    disabledBorderColor: Colors.transparent,
  );

  /// Fallback theme extension used when the ambient theme does not define one.
  static const AwesomeButtonThemeData fallback = AwesomeButtonThemeData(
    style: fallbackStyle,
  );

  /// Resolves the current [AwesomeButtonThemeData] from the nearest [Theme].
  static AwesomeButtonThemeData resolve(BuildContext context) {
    return Theme.of(context).extension<AwesomeButtonThemeData>() ?? fallback;
  }

  @override

  /// Returns a copy of this theme with the provided style merged in.
  AwesomeButtonThemeData copyWith({
    AwesomeButtonStyle? style,
  }) {
    return AwesomeButtonThemeData(
      style: this.style.merge(style),
    );
  }

  @override

  /// Linearly interpolates between two theme extensions.
  AwesomeButtonThemeData lerp(
    ThemeExtension<AwesomeButtonThemeData>? other,
    double t,
  ) {
    if (other is! AwesomeButtonThemeData) {
      return this;
    }

    return AwesomeButtonThemeData(
      style: AwesomeButtonStyle.lerp(style, other.style, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AwesomeButtonThemeData && other.style == style;
  }

  @override
  int get hashCode => style.hashCode;
}

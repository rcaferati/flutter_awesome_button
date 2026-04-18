import 'package:flutter/material.dart';

import '../awesome_button.dart';
import '../awesome_button_style.dart';
import '../awesome_button_theme_data.dart';
import 'colors.dart' as themed_colors;
import 'models.dart';
import 'resolution.dart';
import 'themes.dart';

const double _defaultThemedHorizontalPadding = 16;

class ThemedButton extends StatefulWidget {
  const ThemedButton({
    super.key,
    this.child,
    this.config,
    this.index,
    this.name,
    this.type = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.flat = false,
    this.transparent = false,
    this.textTransition = false,
    this.animatedPlaceholder = true,
    this.onPress,
    this.onLongPress,
    this.disabled = false,
    this.width,
    this.autoWidth = false,
    this.height,
    this.paddingHorizontal,
    this.paddingTop,
    this.paddingBottom,
    this.before,
    this.after,
    this.extra,
    this.stretch = false,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.activeOpacity = 1,
    this.debouncedPressTime = Duration.zero,
    this.progress = false,
    this.showProgressBar = true,
    this.progressLoadingTime = const Duration(milliseconds: 3000),
    this.onPressIn,
    this.onPressOut,
    this.onPressedIn,
    this.onPressedOut,
    this.onProgressStart,
    this.onProgressEnd,
  });

  final Object? child;
  final ThemeDefinition? config;
  final int? index;
  final ThemeName? name;
  final ButtonVariant type;
  final ButtonSize size;
  final bool flat;
  final bool transparent;
  final bool textTransition;
  final bool animatedPlaceholder;
  final AwesomeButtonPressCallback? onPress;
  final VoidCallback? onLongPress;
  final bool disabled;
  final double? width;
  final bool autoWidth;
  final double? height;
  final double? paddingHorizontal;
  final double? paddingTop;
  final double? paddingBottom;
  final Widget? before;
  final Widget? after;
  final Widget? extra;
  final bool stretch;
  final AwesomeButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final double activeOpacity;
  final Duration debouncedPressTime;
  final bool progress;
  final bool showProgressBar;
  final Duration progressLoadingTime;
  final VoidCallback? onPressIn;
  final VoidCallback? onPressOut;
  final VoidCallback? onPressedIn;
  final VoidCallback? onPressedOut;
  final VoidCallback? onProgressStart;
  final VoidCallback? onProgressEnd;

  @override
  State<ThemedButton> createState() => _ThemedButtonState();
}

class _ThemedButtonState extends State<ThemedButton>
    with SingleTickerProviderStateMixin {
  static const Duration _typeTransitionDuration = Duration(milliseconds: 200);
  static const Curve _typeTransitionCurve = Curves.easeOutCubic;
  static const ThemeSizeStyle _fallbackMediumSize = ThemeSizeStyle(
    width: 200,
    height: 60,
  );

  late final AnimationController _transitionController;
  late _ResolvedThemedButtonData _resolvedData;
  late ThemeButtonStyle _displayedPalette;
  ThemeButtonStyle? _transitionFromPalette;
  ThemeButtonStyle? _transitionToPalette;

  @override
  void initState() {
    super.initState();
    _resolvedData = _resolveThemedData(widget);
    _displayedPalette = _resolvedData.targetPalette;
    _transitionController = AnimationController(
      vsync: this,
      duration: _typeTransitionDuration,
    )..addListener(_handleTransitionTick);
  }

  @override
  void didUpdateWidget(covariant ThemedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousData = _resolvedData;
    final nextData = _resolveThemedData(widget);
    final sameThemeSource =
        _hasSameThemeSource(oldWidget, previousData, nextData);
    final shouldAnimate = sameThemeSource &&
        oldWidget.transparent == widget.transparent &&
        previousData.buttonType != nextData.buttonType;

    _resolvedData = nextData;

    if (!shouldAnimate) {
      _stopTransition();
      _displayedPalette = nextData.targetPalette;
      return;
    }

    if (areThemeButtonStylesEqual(_displayedPalette, nextData.targetPalette)) {
      _stopTransition();
      _displayedPalette = nextData.targetPalette;
      return;
    }

    _transitionFromPalette = _displayedPalette;
    _transitionToPalette = nextData.targetPalette;
    _transitionController
      ..stop()
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _handleTransitionTick() {
    final fromPalette = _transitionFromPalette;
    final toPalette = _transitionToPalette;

    if (fromPalette == null || toPalette == null) {
      return;
    }

    final progress =
        _typeTransitionCurve.transform(_transitionController.value);
    final nextPalette = themed_colors.interpolateThemeButtonStyle(
      fromPalette,
      toPalette,
      progress,
    );

    if (areThemeButtonStylesEqual(_displayedPalette, nextPalette)) {
      return;
    }

    setState(() {
      _displayedPalette = nextPalette;
    });
  }

  bool _hasSameThemeSource(
    ThemedButton oldWidget,
    _ResolvedThemedButtonData previousData,
    _ResolvedThemedButtonData nextData,
  ) {
    if (oldWidget.config != null || widget.config != null) {
      return identical(oldWidget.config, widget.config);
    }

    return previousData.themeSourceDescriptor == nextData.themeSourceDescriptor;
  }

  void _stopTransition() {
    _transitionController.stop();
    _transitionFromPalette = null;
    _transitionToPalette = null;
  }

  double? _resolveAutoWidth(
    BuildContext context, {
    required ThemeButtonStyle resolvedButtonStyle,
    required ThemeSizeStyle resolvedSizeStyle,
    required AwesomeButtonStyle effectiveStyle,
  }) {
    if (widget.stretch) {
      return widget.width;
    }

    if (!widget.autoWidth || widget.width != null) {
      return widget.width ?? resolvedSizeStyle.width;
    }

    final text = switch (widget.child) {
      final String value when value.isNotEmpty => value,
      final Text value when value.data != null && value.data!.isNotEmpty =>
        value.data!,
      _ => null,
    };

    if (text == null) {
      return null;
    }

    final fallbackStyle = AwesomeButtonThemeData.fallbackStyle;
    final textSize = effectiveStyle.textSize ?? fallbackStyle.textSize!;
    final textLineHeight =
        effectiveStyle.textLineHeight ?? fallbackStyle.textLineHeight!;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: textSize,
          height: textSize > 0 ? textLineHeight / textSize : null,
          fontFamily: effectiveStyle.textFontFamily,
        ),
      ),
      maxLines: 1,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    )..layout();

    final paddingHorizontal = widget.paddingHorizontal ??
        resolvedSizeStyle.paddingHorizontal ??
        resolvedButtonStyle.paddingHorizontal ??
        _defaultThemedHorizontalPadding;
    final borderWidth =
        effectiveStyle.borderWidth ?? fallbackStyle.borderWidth ?? 0;

    return textPainter.width.ceilToDouble() +
        (paddingHorizontal * 2) +
        (borderWidth * 2);
  }

  _ResolvedThemedButtonData _resolveThemedData(ThemedButton widget) {
    final theme =
        widget.config ?? getTheme(index: widget.index, name: widget.name);
    final buttonType = resolveButtonType(
      theme,
      widget.disabled,
      widget.flat,
      widget.type,
    );
    final buttonStyle =
        theme.buttons[buttonType] ?? theme.buttons[ButtonVariant.primary];
    final resolvedButtonStyle = widget.transparent
        ? buttonStyle!.merge(transparentStyles)
        : buttonStyle!;
    final sizeStyle = theme.size[widget.size] ??
        theme.size[ButtonSize.medium] ??
        _fallbackMediumSize;

    return _ResolvedThemedButtonData(
      theme: theme,
      buttonType: buttonType,
      themeSourceDescriptor: getThemeSourceDescriptor(
        index: widget.index,
        name: widget.name,
        config: widget.config,
      ),
      resolvedButtonStyle: resolvedButtonStyle,
      targetPalette: getInterpolatablePalette(resolvedButtonStyle),
      sizeStyle: sizeStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBaseStyle = themeButtonStyleToAwesomeButtonStyle(
      _resolvedData.resolvedButtonStyle,
    );
    final paletteStyle =
        themeButtonStyleToAwesomeButtonStyle(_displayedPalette);
    final sizeStyle =
        AwesomeButtonStyle(textSize: _resolvedData.sizeStyle.textSize);
    final effectiveStyle = resolvedBaseStyle
        .merge(paletteStyle)
        .merge(sizeStyle)
        .merge(widget.style);

    final resolvedButtonStyle = _resolvedData.resolvedButtonStyle;
    final resolvedSizeStyle = _resolvedData.sizeStyle;
    final resolvedWidth = _resolveAutoWidth(
      context,
      resolvedButtonStyle: resolvedButtonStyle,
      resolvedSizeStyle: resolvedSizeStyle,
      effectiveStyle: effectiveStyle,
    );

    return AwesomeButton(
      onPress: widget.onPress,
      onLongPress: widget.onLongPress,
      disabled: widget.disabled,
      width: resolvedWidth,
      height: widget.height ?? resolvedSizeStyle.height,
      paddingHorizontal: widget.paddingHorizontal ??
          resolvedSizeStyle.paddingHorizontal ??
          resolvedButtonStyle.paddingHorizontal,
      paddingTop: widget.paddingTop ?? resolvedButtonStyle.paddingTop,
      paddingBottom: widget.paddingBottom ?? resolvedButtonStyle.paddingBottom,
      before: widget.before,
      after: widget.after,
      extra: widget.extra,
      stretch: widget.stretch,
      style: effectiveStyle,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      activeOpacity: widget.activeOpacity,
      debouncedPressTime: widget.debouncedPressTime,
      progress: widget.progress,
      showProgressBar: widget.showProgressBar,
      progressLoadingTime: widget.progressLoadingTime,
      textTransition: widget.textTransition,
      animatedPlaceholder: widget.animatedPlaceholder,
      onPressIn: widget.onPressIn,
      onPressOut: widget.onPressOut,
      onPressedIn: widget.onPressedIn,
      onPressedOut: widget.onPressedOut,
      onProgressStart: widget.onProgressStart,
      onProgressEnd: widget.onProgressEnd,
      child: widget.child,
    );
  }
}

class _ResolvedThemedButtonData {
  const _ResolvedThemedButtonData({
    required this.theme,
    required this.buttonType,
    required this.themeSourceDescriptor,
    required this.resolvedButtonStyle,
    required this.targetPalette,
    required this.sizeStyle,
  });

  final ThemeDefinition theme;
  final ButtonVariant buttonType;
  final String themeSourceDescriptor;
  final ThemeButtonStyle resolvedButtonStyle;
  final ThemeButtonStyle targetPalette;
  final ThemeSizeStyle sizeStyle;
}

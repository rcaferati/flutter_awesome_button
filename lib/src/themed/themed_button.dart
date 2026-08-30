import 'package:flutter/material.dart';

import '../awesome_button.dart';
import '../awesome_button_style.dart';
import '../style_frame_scope.dart';
import 'colors.dart' as themed_colors;
import 'models.dart';
import 'resolution.dart';
import 'themes.dart';

double? _normalizedThemedDimension(double? value) {
  if (value == null || !value.isFinite) {
    return null;
  }
  return value < 0 ? 0 : value;
}

/// A typed wrapper around [AwesomeButton] that resolves built-in themes,
/// variants, and sizes.
class ThemedButton extends StatefulWidget {
  /// Creates a [ThemedButton].
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
    this.animateSize = true,
    this.onPressIn,
    this.onPressOut,
    this.onPressedIn,
    this.onPressedOut,
    this.onProgressStart,
    this.onProgressEnd,
    this.pressInAnimationDuration,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.accessibilityLongPressLabel,
  });

  /// Main child content shown in the button face.
  final Object? child;

  /// Explicit theme configuration override.
  final ThemeDefinition? config;

  /// Built-in theme index lookup.
  final int? index;

  /// Built-in theme name lookup.
  final ThemeName? name;

  /// Visual variant to resolve from the active theme.
  final ButtonVariant type;

  /// Size preset to resolve from the active theme.
  final ButtonSize size;

  /// Whether the themed flat variant should override [type].
  final bool flat;

  /// Whether shell, shadow, and border colors should resolve transparent.
  final bool transparent;

  /// Enables string-only text transition effects between child updates.
  final bool textTransition;

  /// Whether placeholder buttons should animate their shimmer.
  final bool animatedPlaceholder;

  /// Press callback for normal and progress buttons.
  final AwesomeButtonPressCallback? onPress;

  /// Long-press callback fired after the platform long-press gesture wins.
  final VoidCallback? onLongPress;

  /// Whether the button should ignore interactions and render disabled styles.
  final bool disabled;

  /// Fixed button width override.
  final double? width;

  /// Whether width should be measured from the string child instead of presets.
  final bool autoWidth;

  /// Fixed face height override.
  final double? height;

  /// Horizontal content padding override.
  final double? paddingHorizontal;

  /// Top content padding override.
  final double? paddingTop;

  /// Bottom content padding override.
  final double? paddingBottom;

  /// Leading content that animates with the main child.
  final Widget? before;

  /// Trailing content that animates with the main child.
  final Widget? after;

  /// Background content rendered inside the face behind the main content.
  final Widget? extra;

  /// Whether the button should fill the available horizontal space.
  final bool stretch;

  /// Additional visual overrides merged on top of the themed resolution.
  final AwesomeButtonStyle? style;

  /// Optional focus node used by keyboard and accessibility focus.
  final FocusNode? focusNode;

  /// Whether the button should request focus when inserted.
  final bool autofocus;

  /// Face opacity applied while a non-progress button is pressed.
  final double activeOpacity;

  /// Leading-edge debounce window for accepted presses.
  final Duration debouncedPressTime;

  /// Enables one-shot progress mode with the [AwesomeButtonNext] contract.
  final bool progress;

  /// Whether the loading bar is rendered during progress mode.
  final bool showProgressBar;

  /// Default duration for the animated progress fill.
  final Duration progressLoadingTime;

  /// Animates fixed-size and auto-width string-label size changes.
  final bool animateSize;

  /// Callback fired when a pointer/touch down arms the pressed state.
  final VoidCallback? onPressIn;

  /// Callback fired when a press is canceled or released.
  final VoidCallback? onPressOut;

  /// Callback fired when the visual pressed state begins.
  final VoidCallback? onPressedIn;

  /// Callback fired after the release animation settles.
  final VoidCallback? onPressedOut;

  /// Callback fired when progress mode begins.
  final VoidCallback? onProgressStart;

  /// Callback fired after progress mode fully completes.
  final VoidCallback? onProgressEnd;

  /// Optional press-down timing override.
  final Duration? pressInAnimationDuration;

  /// Explicit accessible name.
  final String? accessibilityLabel;

  /// Optional assistive-technology hint.
  final String? accessibilityHint;

  /// Optional assistive long-action label.
  final String? accessibilityLongPressLabel;

  @override

  /// Creates the mutable state for this themed button.
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
  bool _reduceMotion = false;
  bool _skipInnerStyleAnimationOnce = false;

  @override
  void initState() {
    super.initState();
    _resolvedData = _resolveThemedData(widget);
    _displayedPalette = _resolvedData.targetPalette;
    _transitionController = AnimationController(
      vsync: this,
      duration: _typeTransitionDuration,
    )
      ..addListener(_handleTransitionTick)
      ..addStatusListener(_handleTransitionStatus);
  }

  @override
  void didUpdateWidget(covariant ThemedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousData = _resolvedData;
    final nextData = _resolveThemedData(widget);
    final sameThemeSource =
        _hasSameThemeSource(oldWidget, previousData, nextData);
    final shouldAnimate = !_reduceMotion &&
        sameThemeSource &&
        oldWidget.transparent == widget.transparent &&
        previousData.buttonType != nextData.buttonType;

    _resolvedData = nextData;

    if (!shouldAnimate) {
      if (!areThemeButtonStylesEqual(
        _displayedPalette,
        nextData.targetPalette,
      )) {
        _skipInnerStyleAnimationForNextBuild();
      }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ??
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;
    if (_reduceMotion == nextReduceMotion) {
      return;
    }
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      if (!areThemeButtonStylesEqual(
        _displayedPalette,
        _resolvedData.targetPalette,
      )) {
        _skipInnerStyleAnimationForNextBuild();
      }
      _stopTransition();
      _displayedPalette = _resolvedData.targetPalette;
    }
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

  void _handleTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    final targetPalette = _transitionToPalette;
    if (targetPalette == null) {
      return;
    }

    // The controller is no longer animating by the time the completed status
    // rebuild runs. Retain wrapper ownership for that final exact frame so the
    // inner button cannot start a second transition from the preceding tick.
    _skipInnerStyleAnimationForNextBuild();
    setState(() {
      _displayedPalette = targetPalette;
      _transitionFromPalette = null;
      _transitionToPalette = null;
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

  void _skipInnerStyleAnimationForNextBuild() {
    _skipInnerStyleAnimationOnce = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _skipInnerStyleAnimationOnce = false;
    });
  }

  double? _resolveAutoWidth({
    required ThemeSizeStyle resolvedSizeStyle,
    required ThemeButtonStyle resolvedButtonStyle,
  }) {
    if (widget.stretch) {
      return _normalizedThemedDimension(widget.width);
    }

    final explicitWidth = _normalizedThemedDimension(widget.width);
    if (widget.autoWidth && explicitWidth == null) {
      return null;
    }

    return explicitWidth ??
        _normalizedThemedDimension(resolvedButtonStyle.width) ??
        _normalizedThemedDimension(resolvedSizeStyle.width);
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
    final buttonStyle = theme.buttons[buttonType] ??
        theme.buttons[ButtonVariant.primary] ??
        const ThemeButtonStyle();
    final resolvedButtonStyle =
        widget.transparent ? buttonStyle.merge(transparentStyles) : buttonStyle;
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
    final effectiveStyle = sizeStyle
        .merge(resolvedBaseStyle)
        .merge(paletteStyle)
        .merge(widget.style);

    final resolvedSizeStyle = _resolvedData.sizeStyle;
    final resolvedButtonStyle = _resolvedData.resolvedButtonStyle;
    final resolvedWidth = _resolveAutoWidth(
      resolvedSizeStyle: resolvedSizeStyle,
      resolvedButtonStyle: resolvedButtonStyle,
    );

    return AwesomeButtonStyleFrameScope(
      framesArePreInterpolated:
          _skipInnerStyleAnimationOnce || _transitionController.isAnimating,
      child: AwesomeButton(
        onPress: widget.onPress,
        onLongPress: widget.onLongPress,
        disabled: widget.disabled,
        width: resolvedWidth,
        height: _normalizedThemedDimension(widget.height) ??
            _normalizedThemedDimension(resolvedButtonStyle.height) ??
            _normalizedThemedDimension(resolvedSizeStyle.height) ??
            52,
        paddingHorizontal:
            _normalizedThemedDimension(widget.paddingHorizontal) ??
                _normalizedThemedDimension(
                  resolvedButtonStyle.paddingHorizontal,
                ) ??
                _normalizedThemedDimension(
                  resolvedSizeStyle.paddingHorizontal,
                ),
        paddingTop: _normalizedThemedDimension(widget.paddingTop) ??
            _normalizedThemedDimension(resolvedButtonStyle.paddingTop),
        paddingBottom: _normalizedThemedDimension(widget.paddingBottom) ??
            _normalizedThemedDimension(resolvedButtonStyle.paddingBottom),
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
        animateSize: widget.animateSize,
        textTransition: widget.textTransition,
        animatedPlaceholder: widget.animatedPlaceholder,
        onPressIn: widget.onPressIn,
        onPressOut: widget.onPressOut,
        onPressedIn: widget.onPressedIn,
        onPressedOut: widget.onPressedOut,
        onProgressStart: widget.onProgressStart,
        onProgressEnd: widget.onProgressEnd,
        pressInAnimationDuration: widget.pressInAnimationDuration,
        accessibilityLabel: widget.accessibilityLabel,
        accessibilityHint: widget.accessibilityHint,
        accessibilityLongPressLabel: widget.accessibilityLongPressLabel,
        child: widget.child,
      ),
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

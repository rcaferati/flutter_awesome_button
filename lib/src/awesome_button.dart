import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'awesome_button_style.dart';
import 'awesome_button_theme_data.dart';
import 'style_frame_scope.dart';
import 'text_transition.dart';

/// Completion callback used by progress buttons.
typedef AwesomeButtonNext = void Function([VoidCallback? callback]);

/// Press handler used by [AwesomeButton] and [ThemedButton].
typedef AwesomeButtonPressCallback = void Function([AwesomeButtonNext? next]);

double? _normalizedOptionalDimension(double? value) {
  if (value == null || !value.isFinite) {
    return null;
  }
  return math.max(0, value);
}

double _normalizedRequiredDimension(double value, double fallback) {
  return _normalizedOptionalDimension(value) ?? fallback;
}

double _normalizedOpacity(double value, double fallback) {
  final finite = value.isFinite ? value : fallback;
  return finite.clamp(0.0, 1.0);
}

Duration _normalizedDuration(Duration value) {
  if (value.isNegative) {
    return Duration.zero;
  }
  return value;
}

Duration? _normalizedOptionalDuration(Duration? value) {
  if (value == null) {
    return null;
  }
  return value.isNegative ? Duration.zero : value;
}

Radius _normalizedRadius(Radius radius) {
  final x = radius.x.isFinite ? math.max(0.0, radius.x) : 0.0;
  final y = radius.y.isFinite ? math.max(0.0, radius.y) : 0.0;
  return Radius.elliptical(x, y);
}

BorderRadius _normalizedBorderRadius(BorderRadius radius) {
  return BorderRadius.only(
    topLeft: _normalizedRadius(radius.topLeft),
    topRight: _normalizedRadius(radius.topRight),
    bottomLeft: _normalizedRadius(radius.bottomLeft),
    bottomRight: _normalizedRadius(radius.bottomRight),
  );
}

const double _defaultHorizontalPadding = 16;
const double _defaultVerticalPadding = 0;
const Duration _sizeAnimationDuration = Duration(milliseconds: 175);
const Curve _sizeAnimationCurve = Cubic(0.3, 0.05, 0.2, 1);
const Duration _shrinkWidthAnimationDelay = Duration(milliseconds: 50);

enum _ButtonWidthMode {
  auto,
  fixed,
  stretch,
}

enum _AutoWidthTextFlow {
  initial,
  textOnly,
  growFirst,
  shrinkLast,
}

/// A layered 3D button with optional progress, themed styling, and slot-based
/// content.
class AwesomeButton extends StatefulWidget {
  /// Creates an [AwesomeButton].
  const AwesomeButton({
    super.key,
    this.child,
    this.onPress,
    this.onLongPress,
    this.disabled = false,
    this.width,
    this.height = 52,
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
    this.textTransition = false,
    this.animatedPlaceholder = true,
    this.pressInAnimationDuration,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.accessibilityLongPressLabel,
    this.onPressIn,
    this.onPressOut,
    this.onPressedIn,
    this.onPressedOut,
    this.onProgressStart,
    this.onProgressEnd,
  });

  /// Main child content shown in the button face.
  final Object? child;

  /// Press callback for normal and progress buttons.
  final AwesomeButtonPressCallback? onPress;

  /// Long-press callback fired after the platform long-press gesture wins.
  final VoidCallback? onLongPress;

  /// Whether the button should ignore interactions and render disabled styles.
  final bool disabled;

  /// Fixed button width. Leave null to use the intrinsic width.
  final double? width;

  /// Height of the moving face.
  final double height;

  /// Horizontal content padding.
  final double? paddingHorizontal;

  /// Top content padding.
  final double? paddingTop;

  /// Bottom content padding.
  final double? paddingBottom;

  /// Leading content that animates with the main child.
  final Widget? before;

  /// Trailing content that animates with the main child.
  final Widget? after;

  /// Background content rendered inside the face behind the main content.
  final Widget? extra;

  /// Whether the button should fill the available horizontal space.
  final bool stretch;

  /// Visual overrides merged on top of the active theme.
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

  /// Enables string-only text transition effects between child updates.
  final bool textTransition;

  /// Whether placeholder buttons should animate their shimmer.
  final bool animatedPlaceholder;

  /// Optional press-down timing override.
  final Duration? pressInAnimationDuration;

  /// Explicit accessible name. Plain string children are inferred when absent.
  final String? accessibilityLabel;

  /// Optional assistive-technology usage hint.
  final String? accessibilityHint;

  /// Optional label for the assistive long-press action.
  final String? accessibilityLongPressLabel;

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

  @override

  /// Creates the mutable state for this button.
  State<AwesomeButton> createState() => _AwesomeButtonState();
}

class _AwesomeButtonState extends State<AwesomeButton>
    with TickerProviderStateMixin {
  static const Duration _progressSwapDuration = Duration(milliseconds: 300);
  static const Duration _progressFillCompletionDuration = Duration(
    milliseconds: 120,
  );
  static const Duration _progressOverlayFadeDuration = Duration(
    milliseconds: 160,
  );
  static const Duration _progressOverlayFadeDelay = Duration(
    milliseconds: 120,
  );
  static const double _shadowWidthFactor = 0.98;
  static const double _releaseSpringTension = 100;
  static const double _releaseSpringFriction = 6.75;
  static const Curve _progressCompletionCurve = Curves.easeOutCubic;
  static const Curve _progressSwapCurve = _RnElasticCurve(1.2);
  static final SpringDescription _releaseSpring = SpringDescription(
    mass: 1,
    stiffness: _origamiTensionToStiffness(_releaseSpringTension),
    damping: _origamiFrictionToDamping(_releaseSpringFriction),
  );

  late final AnimationController _pressController;
  late final AnimationController _contentTransitionController;
  late final AnimationController _activityTransitionController;
  late final AnimationController _progressOverlayOpacityController;
  late final AnimationController _progressController;
  late final AnimationController _widthController;
  late final AnimationController _heightController;
  TextTransitionController? _textTransitionController;

  bool _hovered = false;
  bool _focused = false;
  bool _pressArmed = false;
  bool _longPressArmed = false;
  bool _longPressDisarmed = false;
  bool _longPressDispatched = false;
  bool _reduceMotion = false;
  bool _releaseInProgress = false;
  VoidCallback? _releaseCompletionSnapshot;
  bool _busy = false;
  bool _nextConsumed = false;
  bool _progressHasPhysicalLifecycle = true;
  bool _showProgressVisuals = false;
  bool _debounceActive = false;
  Timer? _debounceResetTimer;
  Timer? _longPressTimer;
  Timer? _delayedWidthAnimationTimer;
  late String? _displayedText;
  late String? _currentTextTarget;
  late _ButtonWidthMode _widthMode;
  double? _resolvedWidth;
  late double _resolvedHeight;
  double? _widthAnimationFrom;
  double? _widthAnimationTo;
  late double _heightAnimationFrom;
  late double _heightAnimationTo;
  bool _isWidthAnimating = false;
  bool _isHeightAnimating = false;
  int _widthAnimationToken = 0;
  int _heightAnimationToken = 0;
  int _sizeRunId = 0;
  int? _measurementRequestId;
  String? _measurementText;
  Duration _pressAnimationDuration =
      AwesomeButtonThemeData.fallbackStyle.animationDuration!;
  Curve _pressAnimationCurve =
      AwesomeButtonThemeData.fallbackStyle.animationCurve!;
  int _gestureId = 0;
  int _progressRunId = 0;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController.unbounded(vsync: this, value: 0);
    _contentTransitionController = AnimationController.unbounded(
      vsync: this,
      value: 1,
    );
    _activityTransitionController = AnimationController.unbounded(
      vsync: this,
      value: 0,
    );
    _progressOverlayOpacityController = AnimationController(
      vsync: this,
      duration: _progressOverlayFadeDuration,
      value: 0,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.progressLoadingTime,
    );
    _widthController = AnimationController(
      vsync: this,
      duration: _sizeAnimationDuration,
    );
    _heightController = AnimationController(
      vsync: this,
      duration: _sizeAnimationDuration,
    );
    final initialText = _extractStringChild(widget.child);
    _displayedText = initialText;
    _currentTextTarget = initialText;
    _widthMode = _widthModeFor(widget);
    _resolvedWidth = _widthMode == _ButtonWidthMode.fixed
        ? _normalizedOptionalDimension(widget.width)
        : null;
    _resolvedHeight = _normalizedRequiredDimension(widget.height, 52);
    _heightAnimationFrom = _resolvedHeight;
    _heightAnimationTo = _resolvedHeight;
    final initialMeasurementText = _autoWidthMeasurementTextFor(widget);
    if (initialMeasurementText != null) {
      _sizeRunId += 1;
      _measurementRequestId = _sizeRunId;
      _measurementText = initialMeasurementText;
    }
  }

  @override
  void didUpdateWidget(covariant AwesomeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressLoadingTime != widget.progressLoadingTime) {
      _progressController.duration = _normalizedDuration(
        widget.progressLoadingTime,
      );
    }
    if (oldWidget.onLongPress != null && widget.onLongPress == null) {
      _disarmLongPress();
    }
    if ((widget.disabled || widget.child == null) && !_busy && _pressArmed) {
      _cancelPhysicalGesture(notifyPressOut: true);
    }
    if ((widget.disabled || widget.child == null) && _busy && !_nextConsumed) {
      _abortProgressFlow(_progressRunId);
    }
    _syncSizeState(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.width != widget.width ||
        oldWidget.stretch != widget.stretch ||
        oldWidget.before != widget.before ||
        oldWidget.after != widget.after ||
        oldWidget.extra != widget.extra ||
        oldWidget.animateSize != widget.animateSize ||
        oldWidget.textTransition != widget.textTransition) {
      _syncTextAndAutoWidthState();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _contentTransitionController.dispose();
    _activityTransitionController.dispose();
    _progressOverlayOpacityController.dispose();
    _progressController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _debounceResetTimer?.cancel();
    _longPressTimer?.cancel();
    _delayedWidthAnimationTimer?.cancel();
    _stopTextTransition();
    super.dispose();
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
    _settleForMotionPolicy();
  }

  bool get _hasContent => widget.child != null;

  String? get _stringChild => _extractStringChild(widget.child);

  bool get _canStartGesture => !widget.disabled && !_busy && _hasContent;

  bool get _canDispatchTap =>
      !widget.disabled && !_busy && _hasContent && widget.onPress != null;

  bool get _semanticsEnabled => !widget.disabled && !_busy && _hasContent;

  String? _extractStringChild(Object? child) {
    return child is String ? child : null;
  }

  _ButtonWidthMode _widthModeFor(AwesomeButton widget) {
    if (widget.stretch) {
      return _ButtonWidthMode.stretch;
    }

    if (_normalizedOptionalDimension(widget.width) != null) {
      return _ButtonWidthMode.fixed;
    }

    return _ButtonWidthMode.auto;
  }

  bool _canChoreographAutoWidthTextFor(AwesomeButton widget) {
    final text = _extractStringChild(widget.child);

    return _widthModeFor(widget) == _ButtonWidthMode.auto &&
        text != null &&
        text.isNotEmpty &&
        widget.before == null &&
        widget.after == null;
  }

  bool get _canChoreographAutoWidthText =>
      _canChoreographAutoWidthTextFor(widget);

  String? _autoWidthMeasurementTextFor(AwesomeButton widget) {
    if (_widthModeFor(widget) != _ButtonWidthMode.auto ||
        widget.before != null ||
        widget.after != null) {
      return null;
    }

    return switch (widget.child) {
      final String value when value.isNotEmpty => value,
      _ => null,
    };
  }

  double? get _currentWidthSnapshot {
    final from = _widthAnimationFrom;
    final to = _widthAnimationTo;

    if (_isWidthAnimating && from != null && to != null) {
      return lerpDouble(
          from,
          to,
          _sizeAnimationCurve.transform(
            _widthController.value,
          ));
    }

    return _resolvedWidth;
  }

  double get _currentHeightSnapshot {
    if (_isHeightAnimating) {
      return lerpDouble(
            _heightAnimationFrom,
            _heightAnimationTo,
            _sizeAnimationCurve.transform(_heightController.value),
          ) ??
          _resolvedHeight;
    }

    return _resolvedHeight;
  }

  EdgeInsets get _contentPadding {
    final horizontal = _normalizedOptionalDimension(widget.paddingHorizontal) ??
        _defaultHorizontalPadding;
    return EdgeInsets.fromLTRB(
      horizontal,
      _normalizedOptionalDimension(widget.paddingTop) ??
          _defaultVerticalPadding,
      horizontal,
      _normalizedOptionalDimension(widget.paddingBottom) ??
          _defaultVerticalPadding,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton || !_canStartGesture || _pressArmed) {
      return;
    }
    _gestureId += 1;
    final gestureId = _gestureId;
    _pressArmed = true;
    _longPressArmed = widget.onLongPress != null;
    _longPressDisarmed = !_longPressArmed;
    _longPressDispatched = false;
    widget.onPressIn?.call();

    if (!mounted ||
        gestureId != _gestureId ||
        !_pressArmed ||
        !_canStartGesture) {
      _cancelPhysicalGesture(notifyPressOut: mounted);
      return;
    }

    widget.onPressedIn?.call();

    if (!mounted ||
        gestureId != _gestureId ||
        !_pressArmed ||
        !_canStartGesture) {
      _cancelPhysicalGesture(notifyPressOut: mounted);
      return;
    }

    _animatePressIn();
    if (_longPressArmed) {
      _longPressTimer?.cancel();
      _longPressTimer = Timer(kLongPressTimeout, () {
        _longPressTimer = null;
        if (!mounted ||
            gestureId != _gestureId ||
            !_pressArmed ||
            !_longPressArmed ||
            _longPressDisarmed ||
            !_canStartGesture) {
          return;
        }
        final callback = widget.onLongPress;
        if (callback == null) {
          _disarmLongPress();
          return;
        }
        _longPressDispatched = true;
        callback();
      });
    }
  }

  void _handleTapCancel() {
    if (!_pressArmed || _busy) {
      return;
    }
    _cancelPhysicalGesture(notifyPressOut: true);
  }

  void _handleTap() {
    if (!_pressArmed) {
      return;
    }

    final wasLongPress = _longPressDispatched;
    final onPressOutSnapshot = widget.onPressOut;
    final onPressedOutSnapshot = widget.onPressedOut;
    _pressArmed = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _longPressArmed = false;
    onPressOutSnapshot?.call();

    if (!mounted) {
      return;
    }

    if (wasLongPress) {
      _releasePressedState(onPressedOutSnapshot);
      return;
    }

    if (!_canDispatchTap) {
      _releasePressedState(onPressedOutSnapshot);
      return;
    }

    if (!_consumeDebouncedPressWindow()) {
      _releasePressedState(onPressedOutSnapshot);
      return;
    }

    if (widget.progress) {
      _startProgressFlow(physicalLifecycle: true);
      return;
    }

    widget.onPress?.call(null);
    if (!mounted) {
      return;
    }
    _releasePressedState(onPressedOutSnapshot);
  }

  void _handleAtomicActivate() {
    if (!_canDispatchTap) {
      return;
    }

    if (!_consumeDebouncedPressWindow()) {
      return;
    }

    if (widget.progress) {
      _startProgressFlow(physicalLifecycle: false);
      return;
    }

    widget.onPress?.call(null);
  }

  void _handleAtomicLongPress() {
    if (!_semanticsEnabled) {
      return;
    }
    widget.onLongPress?.call();
  }

  void _disarmLongPress() {
    _longPressArmed = false;
    _longPressDisarmed = true;
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _cancelPhysicalGesture({required bool notifyPressOut}) {
    if (!_pressArmed) {
      return;
    }
    final onPressOutSnapshot = widget.onPressOut;
    final onPressedOutSnapshot = widget.onPressedOut;
    _pressArmed = false;
    _gestureId += 1;
    _disarmLongPress();
    _longPressDispatched = false;
    if (notifyPressOut) {
      onPressOutSnapshot?.call();
    }
    if (!mounted) {
      return;
    }
    _releasePressedState(onPressedOutSnapshot);
  }

  bool _consumeDebouncedPressWindow() {
    final duration = _normalizedDuration(widget.debouncedPressTime);
    if (duration <= Duration.zero) {
      return true;
    }

    if (_debounceActive) {
      return false;
    }

    _debounceActive = true;
    _debounceResetTimer?.cancel();
    _debounceResetTimer = Timer(duration, () {
      _debounceActive = false;
    });
    return true;
  }

  void _cancelDelayedWidthAnimation() {
    _delayedWidthAnimationTimer?.cancel();
    _delayedWidthAnimationTimer = null;
  }

  void _clearMeasurementRequest() {
    if (_measurementText == null && _measurementRequestId == null) {
      return;
    }

    setState(() {
      _measurementText = null;
      _measurementRequestId = null;
    });
  }

  void _setWidthImmediately(double? nextWidth) {
    _widthAnimationToken += 1;
    _widthController.stop();

    if (_resolvedWidth == nextWidth && !_isWidthAnimating) {
      return;
    }

    setState(() {
      _resolvedWidth = nextWidth;
      _widthAnimationFrom = null;
      _widthAnimationTo = null;
      _isWidthAnimating = false;
    });
  }

  void _animateWidthTo(double nextWidth, {VoidCallback? onComplete}) {
    final currentWidth = _currentWidthSnapshot;

    if (widget.animateSize == false ||
        _reduceMotion ||
        currentWidth == null ||
        (currentWidth - nextWidth).abs() < 0.5) {
      _setWidthImmediately(nextWidth);
      onComplete?.call();
      return;
    }

    _widthAnimationToken += 1;
    final animationToken = _widthAnimationToken;
    _widthController.stop();

    setState(() {
      _widthAnimationFrom = currentWidth;
      _widthAnimationTo = nextWidth;
      _isWidthAnimating = true;
    });

    _widthController.forward(from: 0).orCancel.then((_) {
      if (!mounted || _widthAnimationToken != animationToken) {
        return;
      }

      setState(() {
        _resolvedWidth = nextWidth;
        _widthAnimationFrom = null;
        _widthAnimationTo = null;
        _isWidthAnimating = false;
      });
      onComplete?.call();
    }).catchError((Object _) {
      return;
    }, test: (error) => error is TickerCanceled);
  }

  void _setHeightImmediately(double nextHeight) {
    _heightAnimationToken += 1;
    _heightController.stop();

    if ((_resolvedHeight - nextHeight).abs() < 0.5 && !_isHeightAnimating) {
      return;
    }

    setState(() {
      _resolvedHeight = nextHeight;
      _heightAnimationFrom = nextHeight;
      _heightAnimationTo = nextHeight;
      _isHeightAnimating = false;
    });
  }

  void _animateHeightTo(double nextHeight) {
    final currentHeight = _currentHeightSnapshot;

    if (widget.animateSize == false ||
        _reduceMotion ||
        (currentHeight - nextHeight).abs() < 0.5) {
      _setHeightImmediately(nextHeight);
      return;
    }

    _heightAnimationToken += 1;
    final animationToken = _heightAnimationToken;
    _heightController.stop();

    setState(() {
      _heightAnimationFrom = currentHeight;
      _heightAnimationTo = nextHeight;
      _isHeightAnimating = true;
    });

    _heightController.forward(from: 0).orCancel.then((_) {
      if (!mounted || _heightAnimationToken != animationToken) {
        return;
      }

      setState(() {
        _resolvedHeight = nextHeight;
        _heightAnimationFrom = nextHeight;
        _heightAnimationTo = nextHeight;
        _isHeightAnimating = false;
      });
    }).catchError((Object _) {
      return;
    }, test: (error) => error is TickerCanceled);
  }

  void _syncSizeState(AwesomeButton oldWidget) {
    final previousWidthMode = _widthMode;
    final nextWidthMode = _widthModeFor(widget);
    _widthMode = nextWidthMode;

    if (previousWidthMode != nextWidthMode) {
      _sizeRunId += 1;
      _stopTextTransition();
      _cancelDelayedWidthAnimation();
      _clearMeasurementRequest();

      if (nextWidthMode == _ButtonWidthMode.fixed) {
        _setWidthImmediately(_normalizedOptionalDimension(widget.width));
      } else {
        _setWidthImmediately(null);
      }
    } else if (nextWidthMode == _ButtonWidthMode.fixed &&
        _normalizedOptionalDimension(widget.width) != null &&
        (oldWidget.width != widget.width ||
            oldWidget.animateSize != widget.animateSize)) {
      _animateWidthTo(_normalizedOptionalDimension(widget.width)!);
    }

    if (oldWidget.height != widget.height ||
        oldWidget.animateSize != widget.animateSize) {
      _animateHeightTo(_normalizedRequiredDimension(widget.height, 52));
    }
  }

  void _stopTextTransition() {
    _cancelDelayedWidthAnimation();
    _textTransitionController?.stop();
    _textTransitionController = null;
  }

  void _updateDisplayedText(String? value) {
    if (_displayedText == value) {
      return;
    }

    setState(() {
      _displayedText = value;
    });
  }

  _AutoWidthTextFlow _autoWidthTextFlow(
      double? currentWidth, double nextWidth) {
    if (currentWidth == null) {
      return _AutoWidthTextFlow.initial;
    }

    if ((currentWidth - nextWidth).abs() < 0.5) {
      return _AutoWidthTextFlow.textOnly;
    }

    return nextWidth > currentWidth
        ? _AutoWidthTextFlow.growFirst
        : _AutoWidthTextFlow.shrinkLast;
  }

  void _runTextPhase(
    int runId,
    String? targetText, {
    VoidCallback? onComplete,
  }) {
    _stopTextTransition();

    if (widget.textTransition == false ||
        _reduceMotion ||
        targetText == null ||
        targetText.isEmpty ||
        _displayedText == null ||
        _displayedText!.isEmpty ||
        _displayedText == targetText) {
      _updateDisplayedText(targetText);
      onComplete?.call();
      return;
    }

    final fromText = _displayedText!;
    _textTransitionController = runTextTransition(
      fromText: fromText,
      targetText: targetText,
      onUpdate: (value) {
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(value);
      },
      onComplete: () {
        _textTransitionController = null;
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(targetText);
        onComplete?.call();
      },
    );
  }

  void _requestAutoWidthMeasurement(int runId, String text) {
    setState(() {
      _measurementRequestId = runId;
      _measurementText = text;
    });
  }

  void _syncAutoWidthTextState() {
    final nextText = _stringChild;

    if (nextText == null || nextText.isEmpty) {
      _syncTextTransitionState();
      return;
    }

    if (nextText == _currentTextTarget && _resolvedWidth != null) {
      return;
    }

    _stopTextTransition();
    _sizeRunId += 1;
    _currentTextTarget = nextText;
    _requestAutoWidthMeasurement(_sizeRunId, nextText);
  }

  void _syncTextAndAutoWidthState() {
    if (_canChoreographAutoWidthText) {
      _syncAutoWidthTextState();
      return;
    }

    final measurementText = _autoWidthMeasurementTextFor(widget);
    if (measurementText != null) {
      _sizeRunId += 1;
      _requestAutoWidthMeasurement(_sizeRunId, measurementText);
    } else {
      _clearMeasurementRequest();
    }
    _syncTextTransitionState();
  }

  void _handleAutoWidthMeasured(_AutoWidthMeasurement measurement) {
    if (!mounted ||
        _measurementRequestId != measurement.requestId ||
        _measurementText == null) {
      return;
    }

    final targetText = _measurementText!;
    final measuredWidth = measurement.width.ceilToDouble();

    setState(() {
      _measurementText = null;
      _measurementRequestId = null;
    });

    _resolveMeasuredAutoWidth(measurement.requestId, targetText, measuredWidth);
  }

  void _resolveMeasuredAutoWidth(
    int runId,
    String targetText,
    double nextWidth,
  ) {
    if (!mounted || _sizeRunId != runId) {
      return;
    }

    if (!_canChoreographAutoWidthText) {
      _setWidthImmediately(nextWidth);
      return;
    }

    final flow = _autoWidthTextFlow(_currentWidthSnapshot, nextWidth);

    if (flow == _AutoWidthTextFlow.initial) {
      _setWidthImmediately(nextWidth);
      _updateDisplayedText(targetText);
      return;
    }

    if (flow == _AutoWidthTextFlow.textOnly) {
      _runTextPhase(runId, targetText);
      return;
    }

    if (flow == _AutoWidthTextFlow.growFirst) {
      if (widget.textTransition) {
        _animateWidthTo(nextWidth);
        _runTextPhase(runId, targetText);
        return;
      }

      _animateWidthTo(nextWidth, onComplete: () {
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _runTextPhase(runId, targetText);
      });
      return;
    }

    if (widget.textTransition) {
      _runTextPhase(runId, targetText);
      _delayedWidthAnimationTimer = Timer(_shrinkWidthAnimationDelay, () {
        _delayedWidthAnimationTimer = null;
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _animateWidthTo(nextWidth);
      });
      return;
    }

    _runTextPhase(runId, targetText, onComplete: () {
      if (!mounted || _sizeRunId != runId) {
        return;
      }
      _animateWidthTo(nextWidth);
    });
  }

  void _syncTextTransitionState() {
    final nextText = _stringChild;
    final previousTarget = _currentTextTarget;
    final previousDisplayedText = _displayedText;
    final previousText = previousDisplayedText ?? previousTarget;

    if (widget.textTransition == false ||
        nextText == null ||
        nextText.isEmpty) {
      _stopTextTransition();
      _currentTextTarget = nextText;
      _updateDisplayedText(nextText);
      return;
    }

    if (nextText == previousTarget) {
      return;
    }

    if (previousText == null || previousText.isEmpty) {
      _stopTextTransition();
      _currentTextTarget = nextText;
      _updateDisplayedText(nextText);
      return;
    }

    _stopTextTransition();
    _sizeRunId += 1;
    final runId = _sizeRunId;
    _currentTextTarget = nextText;
    _textTransitionController = runTextTransition(
      fromText: previousText,
      targetText: nextText,
      onUpdate: (value) {
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(value);
      },
      onComplete: () {
        _textTransitionController = null;
        if (!mounted || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(nextText);
      },
    );
  }

  void _resetProgressVisualState({bool unmount = true}) {
    _contentTransitionController
      ..stop()
      ..value = 1;
    _activityTransitionController
      ..stop()
      ..value = 0;
    _progressOverlayOpacityController
      ..stop()
      ..value = 0;
    _progressController
      ..stop()
      ..value = 0;
    if (unmount) {
      _showProgressVisuals = false;
    }
  }

  void _animateProgressSwapIn() {
    if (_reduceMotion) {
      _contentTransitionController.value = 0;
      _activityTransitionController.value = 1;
      return;
    }
    _contentTransitionController
      ..stop()
      ..animateTo(
        0,
        duration: _progressSwapDuration,
        curve: _progressSwapCurve,
      );
    _activityTransitionController
      ..stop()
      ..animateTo(
        1,
        duration: _progressSwapDuration,
        curve: _progressSwapCurve,
      );
  }

  Future<void> _animateProgressSwapOut() async {
    if (_reduceMotion) {
      _contentTransitionController.value = 1;
      _activityTransitionController.value = 0;
      _progressOverlayOpacityController.value = 0;
      return;
    }
    try {
      await Future.wait<void>([
        _contentTransitionController.animateTo(
          1,
          duration: _progressSwapDuration,
          curve: _progressSwapCurve,
        ),
        _activityTransitionController.animateTo(
          0,
          duration: _progressSwapDuration,
          curve: _progressSwapCurve,
        ),
        _fadeOutProgressOverlay(),
      ]);
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _fadeOutProgressOverlay() async {
    try {
      await _progressOverlayOpacityController.animateTo(
        0,
        duration: Duration(
          milliseconds: _progressOverlayFadeDelay.inMilliseconds +
              _progressOverlayFadeDuration.inMilliseconds,
        ),
        curve: Interval(
          _progressOverlayFadeDelay.inMilliseconds /
              (_progressOverlayFadeDelay.inMilliseconds +
                  _progressOverlayFadeDuration.inMilliseconds),
          1,
          curve: _progressCompletionCurve,
        ),
      );
    } on TickerCanceled {
      return;
    }
  }

  void _startProgressFlow({required bool physicalLifecycle}) {
    if (_busy || widget.onPress == null) {
      return;
    }

    _progressRunId += 1;
    final runId = _progressRunId;
    setState(() {
      _busy = true;
      _nextConsumed = false;
      _progressHasPhysicalLifecycle = physicalLifecycle;
      _showProgressVisuals = true;
    });

    if (!physicalLifecycle) {
      _pressController.value = 0;
    }

    _resetProgressVisualState(unmount: false);
    _progressController.duration =
        _normalizedDuration(widget.progressLoadingTime);
    _progressOverlayOpacityController.value = widget.showProgressBar ? 1 : 0;

    widget.onProgressStart?.call();
    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }
    _animateProgressSwapIn();
    if (_reduceMotion) {
      _progressController.value = widget.showProgressBar ? 1 : 0;
    } else {
      _progressController.forward();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_busy || runId != _progressRunId) {
        return;
      }
      final onPress = widget.onPress;
      if (onPress == null || widget.disabled || widget.child == null) {
        _abortProgressFlow(runId);
        return;
      }
      onPress(([callback]) => _handleProgressNext(runId, callback));
    });
  }

  void _handleProgressNext(int runId, [VoidCallback? callback]) {
    if (_nextConsumed || !_busy || runId != _progressRunId) {
      return;
    }
    _nextConsumed = true;
    final onProgressEndSnapshot = widget.onProgressEnd;
    Future<void>.microtask(
      () => _completeProgressFlow(
        runId,
        callback,
        onProgressEndSnapshot,
      ),
    );
  }

  Future<void> _completeProgressFlow(
    int runId,
    VoidCallback? callback,
    VoidCallback? onProgressEndSnapshot,
  ) async {
    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }
    try {
      if (!_reduceMotion && _progressController.value < 1) {
        await _progressController.animateTo(
          1,
          duration: _progressFillCompletionDuration,
          curve: _progressCompletionCurve,
        );
      }
    } on TickerCanceled {
      return;
    }

    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }

    await _animateProgressSwapOut();

    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }

    if (_progressHasPhysicalLifecycle) {
      final onPressedOutSnapshot = widget.onPressedOut;
      await _releasePressedState(onPressedOutSnapshot);
    } else {
      _pressController.value = 0;
    }

    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }

    setState(() {
      _busy = false;
      _showProgressVisuals = false;
    });
    _resetProgressVisualState(unmount: false);
    callback?.call();
    if (!mounted) {
      return;
    }
    onProgressEndSnapshot?.call();
  }

  void _abortProgressFlow(int runId) {
    if (!mounted || !_busy || _nextConsumed || runId != _progressRunId) {
      return;
    }
    _nextConsumed = true;
    final onProgressEndSnapshot = widget.onProgressEnd;
    _progressController.stop();
    _contentTransitionController.stop();
    _activityTransitionController.stop();
    _progressOverlayOpacityController.stop();
    unawaited(
      _finishProgressRollback(
        runId,
        onProgressEndSnapshot,
      ),
    );
  }

  Future<void> _finishProgressRollback(
    int runId,
    VoidCallback? onProgressEndSnapshot,
  ) async {
    if (_progressHasPhysicalLifecycle) {
      await _releasePressedState(widget.onPressedOut);
    } else {
      _pressController.value = 0;
    }
    if (!mounted || !_busy || runId != _progressRunId) {
      return;
    }
    setState(() {
      _busy = false;
      _showProgressVisuals = false;
    });
    _resetProgressVisualState();
    onProgressEndSnapshot?.call();
  }

  Future<void> _animatePressIn() async {
    _pressController.stop();
    if (_reduceMotion || _pressAnimationDuration == Duration.zero) {
      _pressController.value = 1;
      return;
    }
    try {
      await _pressController.animateTo(
        1,
        duration: _pressAnimationDuration,
        curve: _pressAnimationCurve,
      );
    } on TickerCanceled {
      return;
    }

    if (!mounted) {
      return;
    }
  }

  Future<void> _releasePressedState(
      [VoidCallback? onPressedOutSnapshot]) async {
    if (_releaseInProgress) {
      return;
    }
    _releaseInProgress = true;
    _releaseCompletionSnapshot = onPressedOutSnapshot;
    _pressController.stop();
    if (_reduceMotion) {
      _pressController.value = 0;
      _finishRelease();
      return;
    }
    try {
      await _pressController.animateWith(
        SpringSimulation(
          _releaseSpring,
          _pressController.value,
          0,
          0,
        ),
      );
    } on TickerCanceled {
      _releaseInProgress = false;
      _releaseCompletionSnapshot = null;
      return;
    }

    if (!mounted) {
      return;
    }

    _pressController.value = 0;
    _finishRelease();
  }

  void _finishRelease() {
    if (!_releaseInProgress || !mounted) {
      return;
    }
    final callback = _releaseCompletionSnapshot;
    _releaseInProgress = false;
    _releaseCompletionSnapshot = null;
    callback?.call();
  }

  void _settleForMotionPolicy() {
    if (!_reduceMotion) {
      return;
    }
    _pressController.stop();
    _contentTransitionController.stop();
    _activityTransitionController.stop();
    _progressController.stop();
    _progressOverlayOpacityController.stop();
    if (_busy) {
      _pressController.value = 1;
      _contentTransitionController.value = 0;
      _activityTransitionController.value = 1;
      _progressController.value = widget.showProgressBar ? 1 : 0;
      _progressOverlayOpacityController.value = widget.showProgressBar ? 1 : 0;
    } else if (_pressArmed) {
      _pressController.value = 1;
    } else {
      _pressController.value = 0;
    }
    if (_releaseInProgress) {
      _finishRelease();
    }
    _stopTextTransition();
    _updateDisplayedText(_currentTextTarget);
  }

  @override
  Widget build(BuildContext context) {
    final targetResolvedStyle = _resolveStyle(context);
    _pressAnimationDuration = _normalizedOptionalDuration(
          widget.pressInAnimationDuration ??
              widget.style?.pressInAnimationDuration,
        ) ??
        targetResolvedStyle.animationDuration;
    _pressAnimationCurve = targetResolvedStyle.animationCurve;
    final styleFramesArePreInterpolated =
        AwesomeButtonStyleFrameScope.framesArePreInterpolatedOf(context);

    return TweenAnimationBuilder<_ResolvedAwesomeButtonStyle>(
      tween: _ResolvedAwesomeButtonStyleTween(end: targetResolvedStyle),
      duration: _reduceMotion || styleFramesArePreInterpolated
          ? Duration.zero
          : targetResolvedStyle.animationDuration,
      curve: targetResolvedStyle.animationCurve,
      builder: (context, resolvedStyle, child) {
        final direction = Directionality.of(context);
        final borderRadius = _normalizedBorderRadius(
          resolvedStyle.borderRadius.resolve(direction),
        );
        final shell = AnimatedBuilder(
          animation: Listenable.merge([
            _pressController,
            _progressController,
            _contentTransitionController,
            _activityTransitionController,
            _progressOverlayOpacityController,
            _widthController,
            _heightController,
          ]),
          builder: (context, child) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final textGrowthHeight = widget.child is String
                ? resolvedStyle.textLineHeight * textScale +
                    _contentPadding.vertical +
                    (resolvedStyle.borderWidth * 2)
                : 0.0;
            final visualHeight =
                math.max(_currentHeightSnapshot, textGrowthHeight);
            final totalHeight = visualHeight + resolvedStyle.raiseAmount;
            final shadowHeight =
                math.max(0.0, visualHeight - resolvedStyle.raiseAmount);
            final shellWidth = switch (_widthMode) {
              _ButtonWidthMode.stretch => double.infinity,
              _ButtonWidthMode.fixed => _currentWidthSnapshot,
              _ButtonWidthMode.auto => _currentWidthSnapshot,
            };
            final stretchFace = widget.stretch || shellWidth != null;
            final pressValue = _pressController.value;
            final clampedPressValue = pressValue.clamp(0.0, 1.0);
            final faceOffset = resolvedStyle.raiseAmount * pressValue;
            final pressedOpacity = widget.progress
                ? 1.0
                : 1 -
                    ((1 - _normalizedOpacity(widget.activeOpacity, 1)) *
                        clampedPressValue);
            final visual = Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -(resolvedStyle.raiseAmount / 2),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      -(resolvedStyle.raiseAmount / 2) * pressValue,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: _shadowWidthFactor,
                        child: _ButtonShadowLayer(
                          height: shadowHeight,
                          backgroundColor: resolvedStyle.shadowColor,
                          borderRadius: borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: resolvedStyle.raiseAmount),
                    child: _ButtonBottomLayer(
                      height: visualHeight,
                      backgroundColor: resolvedStyle.depthColor,
                      borderRadius: borderRadius,
                      borderColor: resolvedStyle.borderColor,
                      borderWidth: resolvedStyle.borderWidth,
                      stretch: true,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, faceOffset),
                  child: _ButtonFaceLayer(
                    stretch: stretchFace,
                    height: visualHeight,
                    padding: _contentPadding,
                    borderRadius: borderRadius,
                    backgroundColor: resolvedStyle.backgroundColor,
                    borderColor: resolvedStyle.borderColor,
                    borderWidth: resolvedStyle.borderWidth,
                    foregroundColor: resolvedStyle.foregroundColor,
                    activeBackgroundColor: resolvedStyle.activeBackgroundColor,
                    activeBackgroundOpacity:
                        widget.showProgressBar || !_showProgressVisuals
                            ? clampedPressValue
                            : 0,
                    hoverOverlayColor: _hoverFocusOverlayColor(
                      resolvedStyle.pressedOverlayColor,
                    ),
                    before: widget.before,
                    after: widget.after,
                    extra: widget.extra,
                    contentGap: resolvedStyle.contentGap,
                    backgroundPlaceholderColor:
                        resolvedStyle.backgroundPlaceholderColor,
                    progressFillColor: resolvedStyle.progressFillColor,
                    activityColor: resolvedStyle.activityColor,
                    progressValue: _progressController.value,
                    progressOverlayOpacity:
                        _progressOverlayOpacityController.value,
                    contentTransitionValue: _contentTransitionController.value,
                    activityTransitionValue:
                        _activityTransitionController.value,
                    showProgressVisuals: _showProgressVisuals,
                    showProgressBar: widget.showProgressBar,
                    animatedPlaceholder:
                        widget.animatedPlaceholder && !_reduceMotion,
                    textSize: resolvedStyle.textSize,
                    textLineHeight: resolvedStyle.textLineHeight,
                    textFontFamily: resolvedStyle.textFontFamily,
                    child: widget.child,
                    displayedText: _displayedText,
                  ),
                ),
              ],
            );

            return SizedBox(
              key: const ValueKey<String>('aws-btn-shell'),
              width: shellWidth,
              height: totalHeight,
              child: Opacity(
                key: const ValueKey<String>('aws-btn-pressed-opacity'),
                opacity: pressedOpacity.clamp(0.0, 1.0),
                child: visual,
              ),
            );
          },
        );
        final measurementText = _measurementText;
        final measurementRequestId = _measurementRequestId;
        final interactiveChild = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            shell,
            if (measurementText != null && measurementRequestId != null)
              _AutoWidthMeasurementProbe(
                requestId: measurementRequestId,
                text: measurementText,
                padding: _contentPadding,
                borderWidth: resolvedStyle.borderWidth,
                foregroundColor: resolvedStyle.foregroundColor,
                textSize: resolvedStyle.textSize,
                textLineHeight: resolvedStyle.textLineHeight,
                textFontFamily: resolvedStyle.textFontFamily,
                onMeasured: _handleAutoWidthMeasured,
              ),
          ],
        );

        final minimumTarget =
            Theme.of(context).platform == TargetPlatform.android ? 48.0 : 44.0;
        final inferredLabel =
            widget.child is String ? widget.child! as String : null;
        final labeledLongAction = widget.accessibilityLongPressLabel != null &&
                _semanticsEnabled &&
                widget.onLongPress != null
            ? <CustomSemanticsAction, VoidCallback>{
                CustomSemanticsAction(
                  label: widget.accessibilityLongPressLabel!,
                ): _handleAtomicLongPress,
              }
            : null;

        return Semantics(
          button: true,
          container: true,
          excludeSemantics: true,
          enabled: _semanticsEnabled,
          focusable: _semanticsEnabled,
          label: widget.accessibilityLabel ?? inferredLabel,
          hint: widget.accessibilityHint,
          liveRegion: _busy,
          customSemanticsActions: labeledLongAction,
          onTap: _canDispatchTap ? _handleAtomicActivate : null,
          onLongPress: labeledLongAction == null &&
                  _semanticsEnabled &&
                  widget.onLongPress != null
              ? _handleAtomicLongPress
              : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minimumTarget,
              minHeight: minimumTarget,
            ),
            child: FocusableActionDetector(
              enabled: _hasContent && !widget.disabled && !_busy,
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              onShowFocusHighlight: (value) {
                if (_focused == value) {
                  return;
                }
                setState(() => _focused = value);
              },
              onShowHoverHighlight: (value) {
                if (_hovered == value) {
                  return;
                }
                setState(() => _hovered = value);
              },
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (intent) {
                    _handleAtomicActivate();
                    return null;
                  },
                ),
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _canStartGesture ? _handlePointerDown : null,
                onPointerCancel:
                    _canStartGesture ? (_) => _handleTapCancel() : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTapCancel: _canStartGesture ? _handleTapCancel : null,
                  onTap: _canStartGesture ? _handleTap : null,
                  child: interactiveChild,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _ResolvedAwesomeButtonStyle _resolveStyle(BuildContext context) {
    final mergedStyle = AwesomeButtonThemeData.resolve(context).style.merge(
          widget.style,
        );
    final fallbackStyle = AwesomeButtonThemeData.fallbackStyle;
    final backgroundColor = widget.disabled
        ? mergedStyle.disabledBackgroundColor ??
            mergedStyle.backgroundColor ??
            fallbackStyle.disabledBackgroundColor!
        : mergedStyle.backgroundColor ?? fallbackStyle.backgroundColor!;
    final depthColor = widget.disabled
        ? mergedStyle.disabledDepthColor ??
            mergedStyle.depthColor ??
            fallbackStyle.disabledDepthColor!
        : mergedStyle.depthColor ?? fallbackStyle.depthColor!;
    final shadowColor = widget.disabled
        ? mergedStyle.disabledShadowColor ??
            mergedStyle.shadowColor ??
            fallbackStyle.disabledShadowColor!
        : mergedStyle.shadowColor ?? fallbackStyle.shadowColor!;
    final pressedOverlayColor =
        mergedStyle.pressedOverlayColor ?? fallbackStyle.pressedOverlayColor!;
    final foregroundColor = widget.disabled
        ? mergedStyle.disabledForegroundColor ??
            mergedStyle.foregroundColor ??
            fallbackStyle.disabledForegroundColor!
        : mergedStyle.foregroundColor ?? fallbackStyle.foregroundColor!;
    final borderColor = widget.disabled
        ? mergedStyle.disabledBorderColor ??
            mergedStyle.borderColor ??
            fallbackStyle.disabledBorderColor!
        : mergedStyle.borderColor ?? fallbackStyle.borderColor!;

    return _ResolvedAwesomeButtonStyle(
      backgroundColor: backgroundColor,
      activeBackgroundColor: mergedStyle.backgroundActive ??
          _deriveActiveBackgroundColor(backgroundColor, pressedOverlayColor),
      backgroundPlaceholderColor: mergedStyle.backgroundPlaceholder ??
          fallbackStyle.backgroundPlaceholder!,
      progressFillColor: mergedStyle.backgroundProgress ??
          fallbackStyle.backgroundProgress ??
          fallbackStyle.shadowColor!,
      activityColor: mergedStyle.activityColor ??
          fallbackStyle.activityColor ??
          foregroundColor,
      depthColor: depthColor,
      shadowColor: shadowColor,
      pressedOverlayColor: pressedOverlayColor,
      foregroundColor: foregroundColor,
      textSize: _normalizedRequiredDimension(
        mergedStyle.textSize ?? fallbackStyle.textSize!,
        fallbackStyle.textSize!,
      ),
      textLineHeight: _normalizedRequiredDimension(
        mergedStyle.textLineHeight ?? fallbackStyle.textLineHeight!,
        fallbackStyle.textLineHeight!,
      ),
      textFontFamily: mergedStyle.textFontFamily,
      borderRadius: mergedStyle.borderRadius ?? fallbackStyle.borderRadius!,
      borderWidth: _normalizedRequiredDimension(
        mergedStyle.borderWidth ?? fallbackStyle.borderWidth!,
        fallbackStyle.borderWidth!,
      ),
      borderColor: borderColor,
      raiseAmount: _normalizedRequiredDimension(
        mergedStyle.raiseAmount ?? fallbackStyle.raiseAmount!,
        fallbackStyle.raiseAmount!,
      ),
      contentGap: _normalizedRequiredDimension(
        mergedStyle.contentGap ?? fallbackStyle.contentGap!,
        fallbackStyle.contentGap!,
      ),
      animationDuration: _normalizedDuration(
        mergedStyle.animationDuration ?? fallbackStyle.animationDuration!,
      ),
      animationCurve:
          mergedStyle.animationCurve ?? fallbackStyle.animationCurve!,
    );
  }

  Color _deriveActiveBackgroundColor(
      Color backgroundColor, Color overlayColor) {
    return Color.alphaBlend(overlayColor, backgroundColor);
  }

  Color _hoverFocusOverlayColor(Color baseColor) {
    final stateOpacity = _focused
        ? 0.75
        : _hovered
            ? 0.45
            : 0.0;

    return baseColor.withValues(alpha: baseColor.a * stateOpacity);
  }
}

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

class _AutoWidthMeasurement {
  const _AutoWidthMeasurement({
    required this.requestId,
    required this.width,
  });

  final int requestId;
  final double width;
}

class _AutoWidthMeasurementProbe extends StatelessWidget {
  const _AutoWidthMeasurementProbe({
    required this.requestId,
    required this.text,
    required this.padding,
    required this.borderWidth,
    required this.foregroundColor,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
    required this.onMeasured,
  });

  final int requestId;
  final String text;
  final EdgeInsets padding;
  final double borderWidth;
  final Color foregroundColor;
  final double textSize;
  final double textLineHeight;
  final String? textFontFamily;
  final ValueChanged<_AutoWidthMeasurement> onMeasured;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: TickerMode(
            enabled: false,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              fit: OverflowBoxFit.deferToChild,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: 0,
              maxHeight: double.infinity,
              child: _MeasureSize(
                onChange: (size) {
                  onMeasured(
                    _AutoWidthMeasurement(
                      requestId: requestId,
                      width: size.width,
                    ),
                  );
                },
                child: DecoratedBox(
                  key: const ValueKey<String>('aws-btn-auto-width-measure'),
                  decoration: BoxDecoration(
                    border: borderWidth > 0
                        ? Border.all(
                            color: Colors.transparent,
                            width: borderWidth,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(borderWidth) + padding,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                        fontSize: textSize,
                        height: textSize > 0 ? textLineHeight / textSize : null,
                        fontFamily: textFontFamily,
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();
    final nextSize = child?.size ?? size;

    if (_previousSize == nextSize) {
      return;
    }

    _previousSize = nextSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(nextSize);
    });
  }
}

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

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.stretch,
    required this.foregroundColor,
    required this.gap,
    required this.before,
    required this.after,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
    required this.child,
  });

  final bool stretch;
  final Color foregroundColor;
  final double gap;
  final Widget? before;
  final Widget? after;
  final double? textSize;
  final double? textLineHeight;
  final String? textFontFamily;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w700,
        fontSize: textSize,
        height: textSize != null && textLineHeight != null && textSize! > 0
            ? textLineHeight! / textSize!
            : null,
        fontFamily: textFontFamily,
      ),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: Builder(
          builder: (context) {
            final entries = <Widget>[
              if (before != null) before!,
              child,
              if (after != null) after!,
            ];

            final rowChildren = <Widget>[];
            for (var index = 0; index < entries.length; index += 1) {
              if (index > 0) {
                rowChildren.add(SizedBox(width: gap));
              }
              final entry = entries[index];
              final isCenterChild = before != null ? index == 1 : index == 0;

              rowChildren.add(
                isCenterChild && stretch ? Flexible(child: entry) : entry,
              );
            }

            return Row(
              mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowChildren,
            );
          },
        ),
      ),
    );
  }
}

class _ButtonPlaceholder extends StatefulWidget {
  const _ButtonPlaceholder({
    required this.animated,
    required this.backgroundColor,
    required this.height,
  });

  final bool animated;
  final Color backgroundColor;
  final double height;

  @override
  State<_ButtonPlaceholder> createState() => _ButtonPlaceholderState();
}

class _ButtonPlaceholderState extends State<_ButtonPlaceholder>
    with SingleTickerProviderStateMixin {
  static const Duration _loopDuration = Duration(milliseconds: 3223);
  static const Color _barColor = Color.fromRGBO(0, 0, 0, 0.15);

  late final AnimationController _controller;
  double _measuredWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _loopDuration);
    _syncLoop();
  }

  @override
  void didUpdateWidget(covariant _ButtonPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) {
      _syncLoop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncLoop() {
    _controller.stop();
    _controller.value = 0;

    if (widget.animated && _measuredWidth > 0) {
      _controller.repeat();
    }
  }

  void _updateMeasuredWidth(double width) {
    if ((_measuredWidth - width).abs() < 0.5) {
      return;
    }

    setState(() {
      _measuredWidth = width;
    });
    _syncLoop();
  }

  double _translateXFor(double width) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(-width), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -width, end: width), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(width), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: width, end: -width), weight: 30),
    ]).transform(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _updateMeasuredWidth(constraints.maxWidth);
          });

          return SizedBox(
            key: const ValueKey<String>('aws-btn-content-placeholder'),
            height: widget.height,
            child: ClipRect(
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.backgroundColor),
                child: widget.animated
                    ? AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            key: const ValueKey<String>(
                              'aws-btn-content-placeholder-bar',
                            ),
                            offset: Offset(
                              _translateXFor(constraints.maxWidth),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: widget.height,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(color: _barColor),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'awesome_button_style.dart';
import 'awesome_button_theme_data.dart';
import 'text_transition.dart';

typedef AwesomeButtonNext = void Function([VoidCallback? callback]);
typedef AwesomeButtonPressCallback = void Function([AwesomeButtonNext? next]);

const double _defaultHorizontalPadding = 16;
const double _defaultVerticalPadding = 0;

class AwesomeButton extends StatefulWidget {
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
    this.textTransition = false,
    this.animatedPlaceholder = true,
    this.onPressIn,
    this.onPressOut,
    this.onPressedIn,
    this.onPressedOut,
    this.onProgressStart,
    this.onProgressEnd,
  });

  final Object? child;
  final AwesomeButtonPressCallback? onPress;
  final VoidCallback? onLongPress;
  final bool disabled;
  final double? width;
  final double height;
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
  final bool textTransition;
  final bool animatedPlaceholder;
  final VoidCallback? onPressIn;
  final VoidCallback? onPressOut;
  final VoidCallback? onPressedIn;
  final VoidCallback? onPressedOut;
  final VoidCallback? onProgressStart;
  final VoidCallback? onProgressEnd;

  @override
  State<AwesomeButton> createState() => _AwesomeButtonState();
}

class _AwesomeButtonState extends State<AwesomeButton>
    with TickerProviderStateMixin {
  static const Duration _progressSwapDuration = Duration(milliseconds: 300);
  static const Duration _progressFillCompletionDuration = Duration(
    milliseconds: 200,
  );
  static const Duration _progressOverlayFadeDuration = Duration(
    milliseconds: 200,
  );
  static const Duration _progressOverlayFadeDelay = Duration(
    milliseconds: 100,
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
  TextTransitionController? _textTransitionController;

  bool _hovered = false;
  bool _focused = false;
  bool _pressArmed = false;
  bool _busy = false;
  bool _nextConsumed = false;
  bool _showProgressVisuals = false;
  bool _debounceActive = false;
  Timer? _debounceResetTimer;
  late String? _displayedText;
  late String? _currentTextTarget;
  Duration _pressAnimationDuration =
      AwesomeButtonThemeData.fallbackStyle.animationDuration!;
  Curve _pressAnimationCurve =
      AwesomeButtonThemeData.fallbackStyle.animationCurve!;

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
    final initialText = _extractStringChild(widget.child);
    _displayedText = initialText;
    _currentTextTarget = initialText;
  }

  @override
  void didUpdateWidget(covariant AwesomeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressLoadingTime != widget.progressLoadingTime) {
      _progressController.duration = widget.progressLoadingTime;
    }
    if (widget.disabled && !_busy && _pressArmed) {
      _pressArmed = false;
      _notifyPressOut();
      _releasePressedState();
    }
    if (oldWidget.child != widget.child ||
        oldWidget.textTransition != widget.textTransition) {
      _syncTextTransitionState();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _contentTransitionController.dispose();
    _activityTransitionController.dispose();
    _progressOverlayOpacityController.dispose();
    _progressController.dispose();
    _debounceResetTimer?.cancel();
    _stopTextTransition();
    super.dispose();
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

  EdgeInsets get _contentPadding {
    final horizontal = widget.paddingHorizontal ?? _defaultHorizontalPadding;
    return EdgeInsets.fromLTRB(
      horizontal,
      widget.paddingTop ?? _defaultVerticalPadding,
      horizontal,
      widget.paddingBottom ?? _defaultVerticalPadding,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton || !_canStartGesture || _pressArmed) {
      return;
    }
    _pressArmed = true;
    widget.onPressIn?.call();
    widget.onPressedIn?.call();
    _animatePressIn();
  }

  void _handleTapCancel() {
    if (!_pressArmed || _busy) {
      return;
    }
    _pressArmed = false;
    _notifyPressOut();
    _releasePressedState();
  }

  void _handleTap() {
    if (!_pressArmed) {
      return;
    }

    _pressArmed = false;
    _notifyPressOut();

    if (!_canDispatchTap) {
      _releasePressedState();
      return;
    }

    if (!_consumeDebouncedPressWindow()) {
      _releasePressedState();
      return;
    }

    if (widget.progress) {
      _startProgressFlow();
      return;
    }

    widget.onPress?.call(null);
    _releasePressedState();
  }

  Future<void> _handleKeyboardActivate() async {
    if (!_canDispatchTap) {
      return;
    }

    widget.onPressIn?.call();
    widget.onPressedIn?.call();
    await _animatePressIn();

    if (!mounted || widget.disabled || _busy) {
      return;
    }

    _notifyPressOut();

    if (!_consumeDebouncedPressWindow()) {
      await _releasePressedState();
      return;
    }

    if (widget.progress) {
      _startProgressFlow();
      return;
    }

    widget.onPress?.call(null);
    await _releasePressedState();
  }

  void _notifyPressOut() {
    widget.onPressOut?.call();
  }

  bool _consumeDebouncedPressWindow() {
    if (widget.debouncedPressTime <= Duration.zero) {
      return true;
    }

    if (_debounceActive) {
      return false;
    }

    _debounceActive = true;
    _debounceResetTimer?.cancel();
    _debounceResetTimer = Timer(widget.debouncedPressTime, () {
      _debounceActive = false;
    });
    return true;
  }

  void _stopTextTransition() {
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
    _currentTextTarget = nextText;
    _textTransitionController = runTextTransition(
      fromText: previousText,
      targetText: nextText,
      onUpdate: (value) {
        if (!mounted) {
          return;
        }
        _updateDisplayedText(value);
      },
      onComplete: () {
        _textTransitionController = null;
        if (!mounted) {
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

  void _startProgressFlow() {
    if (_busy || widget.onPress == null) {
      return;
    }

    setState(() {
      _busy = true;
      _nextConsumed = false;
      _showProgressVisuals = true;
    });

    _resetProgressVisualState(unmount: false);
    _progressController.duration = widget.progressLoadingTime;
    _progressOverlayOpacityController.value = 1;

    widget.onProgressStart?.call();
    _animateProgressSwapIn();
    _progressController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_busy) {
        return;
      }
      widget.onPress?.call(_handleProgressNext);
    });
  }

  void _handleProgressNext([VoidCallback? callback]) {
    if (_nextConsumed || !_busy) {
      return;
    }
    _nextConsumed = true;
    _completeProgressFlow(callback);
  }

  Future<void> _completeProgressFlow([VoidCallback? callback]) async {
    try {
      if (_progressController.value < 1) {
        await _progressController.animateTo(
          1,
          duration: _progressFillCompletionDuration,
          curve: _progressCompletionCurve,
        );
      }
    } on TickerCanceled {
      return;
    }

    if (!mounted) {
      return;
    }

    await _animateProgressSwapOut();

    if (!mounted) {
      return;
    }

    await _releasePressedState();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _showProgressVisuals = false;
    });
    _resetProgressVisualState(unmount: false);
    callback?.call();
    widget.onProgressEnd?.call();
  }

  Future<void> _animatePressIn() async {
    _pressController.stop();
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

  Future<void> _releasePressedState() async {
    _pressController.stop();
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
      return;
    }

    if (!mounted) {
      return;
    }

    _pressController.value = 0;
    widget.onPressedOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _resolveStyle(context);
    _pressAnimationDuration = resolvedStyle.animationDuration;
    _pressAnimationCurve = resolvedStyle.animationCurve;
    final direction = Directionality.of(context);
    final borderRadius = resolvedStyle.borderRadius.resolve(direction);
    final totalHeight = widget.height + resolvedStyle.raiseAmount;
    final shadowHeight =
        math.max(0.0, widget.height - resolvedStyle.raiseAmount);
    final shellWidth = widget.stretch ? double.infinity : widget.width;
    final shell = AnimatedBuilder(
      animation: Listenable.merge([
        _pressController,
        _progressController,
        _contentTransitionController,
        _activityTransitionController,
        _progressOverlayOpacityController,
      ]),
      builder: (context, child) {
        final pressValue = _pressController.value;
        final clampedPressValue = pressValue.clamp(0.0, 1.0);
        final faceOffset = resolvedStyle.raiseAmount * pressValue;
        final pressedOpacity = widget.progress
            ? 1.0
            : 1 - ((1 - widget.activeOpacity) * clampedPressValue);
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
                  height: widget.height,
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
                stretch: widget.stretch || widget.width != null,
                height: widget.height,
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
                progressOverlayOpacity: _progressOverlayOpacityController.value,
                contentTransitionValue: _contentTransitionController.value,
                activityTransitionValue: _activityTransitionController.value,
                showProgressVisuals: _showProgressVisuals,
                showProgressBar: widget.showProgressBar,
                animatedPlaceholder: widget.animatedPlaceholder,
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

    return Semantics(
      button: true,
      enabled: _semanticsEnabled,
      value: _busy ? 'Busy' : null,
      onTap: _canDispatchTap ? _handleKeyboardActivate : null,
      onLongPress: _canStartGesture && widget.onLongPress != null
          ? widget.onLongPress
          : null,
      child: FocusableActionDetector(
        enabled: _hasContent && !widget.disabled,
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
              _handleKeyboardActivate();
              return null;
            },
          ),
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _canStartGesture ? _handlePointerDown : null,
          onPointerCancel: _canStartGesture ? (_) => _handleTapCancel() : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapCancel: _canStartGesture ? _handleTapCancel : null,
            onTap: _canStartGesture ? _handleTap : null,
            onLongPress: _canStartGesture && widget.onLongPress != null
                ? widget.onLongPress
                : null,
            child: shell,
          ),
        ),
      ),
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
      textSize: mergedStyle.textSize ?? fallbackStyle.textSize!,
      textLineHeight:
          mergedStyle.textLineHeight ?? fallbackStyle.textLineHeight!,
      textFontFamily: mergedStyle.textFontFamily,
      borderRadius: mergedStyle.borderRadius ?? fallbackStyle.borderRadius!,
      borderWidth: mergedStyle.borderWidth ?? fallbackStyle.borderWidth!,
      borderColor: borderColor,
      raiseAmount: mergedStyle.raiseAmount ?? fallbackStyle.raiseAmount!,
      contentGap: mergedStyle.contentGap ?? fallbackStyle.contentGap!,
      animationDuration:
          mergedStyle.animationDuration ?? fallbackStyle.animationDuration!,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                      constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
                  final progressTranslateX =
                      maxWidth * (progressValue.clamp(0.0, 1.0) - 1);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (extra != null) IgnorePointer(child: extra!),
                      if (activeBackgroundColor.a > 0)
                        IgnorePointer(
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
                      if (showProgressVisuals && showProgressBar)
                        IgnorePointer(
                          child: Opacity(
                            key: const ValueKey<String>(
                                'aws-btn-progress-overlay'),
                            opacity: overlayOpacity,
                            child: Transform.translate(
                              offset: Offset(progressTranslateX, 0),
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
                                        backgroundColor:
                                            backgroundPlaceholderColor,
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: hoverOverlayColor,
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
    final hasSideContent = before != null || after != null;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canConstrainCenterChild =
                stretch || hasSideContent || constraints.hasBoundedWidth;
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
                isCenterChild && canConstrainCenterChild
                    ? Flexible(child: entry)
                    : entry,
              );
            }

            return Row(
              mainAxisSize:
                  stretch || hasSideContent || constraints.hasBoundedWidth
                      ? MainAxisSize.max
                      : MainAxisSize.min,
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

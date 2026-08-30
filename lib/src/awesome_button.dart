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

part 'awesome_button/resolved_style.dart';
part 'awesome_button/measurement.dart';
part 'awesome_button/layers.dart';
part 'awesome_button/content.dart';
part 'awesome_button/placeholder.dart';
part 'awesome_button/size_text_owner.dart';
part 'awesome_button/progress_owner.dart';
part 'awesome_button/interaction_release_owner.dart';

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

  /// Enables measured, grapheme-aware transitions between non-empty strings.
  ///
  /// Transient frames remain on one clipped line and never replace the latest
  /// target string as the button's accessibility identity. Auto-width frames
  /// are measured before publication; stable labels regain normal wrapping
  /// after settlement. Reduced Motion settles text and geometry immediately.
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
  static const double _shadowWidthFactor = 0.98;

  late final _AwesomeButtonSizeTextOwner _sizeTextOwner;
  late final _AwesomeButtonProgressOwner _progressOwner;
  late final _AwesomeButtonInteractionReleaseOwner _interactionOwner;

  bool _hovered = false;
  bool _focused = false;
  bool _reduceMotion = false;
  int _auxiliaryMeasurementRevision = 0;
  int _textMetricRevision = 0;
  _ButtonAuxiliaryMeasurement? _auxiliaryMeasurement;
  Object? _textMetricSignature;
  Object? _scheduledTextMeasurementKey;
  Object? _scheduledTargetRemeasureKey;
  Object? _scheduledTargetCommitKey;

  @override
  void initState() {
    super.initState();
    if (widget.before == null && widget.after == null) {
      _auxiliaryMeasurement = const _ButtonAuxiliaryMeasurement(
        revision: 0,
        beforeWidth: 0,
        afterWidth: 0,
      );
    }
    _sizeTextOwner = _AwesomeButtonSizeTextOwner(
      vsync: this,
      initialConfiguration: _sizeTextConfigurationFor(widget),
    )..addListener(_handleSizeTextChanged);
    _progressOwner = _AwesomeButtonProgressOwner(
      vsync: this,
      initialConfiguration: _progressConfiguration,
    )..addListener(_handleProgressChanged);
    _interactionOwner = _AwesomeButtonInteractionReleaseOwner(
      vsync: this,
      initialConfiguration: _interactionConfiguration(
        AwesomeButtonThemeData.fallbackStyle.animationDuration!,
        AwesomeButtonThemeData.fallbackStyle.animationCurve!,
      ),
    )..addListener(_handleInteractionChanged);
  }

  @override
  void didUpdateWidget(covariant AwesomeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.before != widget.before || oldWidget.after != widget.after) {
      _auxiliaryMeasurementRevision += 1;
      _auxiliaryMeasurement = widget.before == null && widget.after == null
          ? _ButtonAuxiliaryMeasurement(
              revision: _auxiliaryMeasurementRevision,
              beforeWidth: 0,
              afterWidth: 0,
            )
          : null;
    }
    _progressOwner.updateConfiguration(_progressConfiguration);
    if (oldWidget.onLongPress != null && widget.onLongPress == null) {
      _interactionOwner.disarmLongPress();
    }
    if ((widget.disabled || widget.child == null) &&
        !_progressOwner.busy &&
        _interactionOwner.presentation.pressArmed) {
      _cancelPhysicalGesture(notifyPressOut: true);
    }
    if ((widget.disabled || widget.child == null) &&
        _progressOwner.busy &&
        !_progressOwner.nextConsumed) {
      _progressOwner.abort(_progressOwner.runId, widget.onProgressEnd);
    }
    final textOrMeasurementDependenciesChanged =
        oldWidget.child != widget.child ||
            oldWidget.width != widget.width ||
            oldWidget.stretch != widget.stretch ||
            oldWidget.before != widget.before ||
            oldWidget.after != widget.after ||
            oldWidget.extra != widget.extra ||
            oldWidget.animateSize != widget.animateSize ||
            oldWidget.textTransition != widget.textTransition;
    _sizeTextOwner.update(
      previous: _sizeTextConfigurationFor(oldWidget),
      current: _sizeTextConfigurationFor(widget),
      textOrMeasurementDependenciesChanged:
          textOrMeasurementDependenciesChanged,
    );
  }

  @override
  void dispose() {
    _scheduledTextMeasurementKey = null;
    _scheduledTargetRemeasureKey = null;
    _scheduledTargetCommitKey = null;
    _sizeTextOwner.removeListener(_handleSizeTextChanged);
    _progressOwner.removeListener(_handleProgressChanged);
    _interactionOwner.removeListener(_handleInteractionChanged);
    _sizeTextOwner.dispose();
    _progressOwner.dispose();
    _interactionOwner.dispose();
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
    _sizeTextOwner.setReduceMotion(nextReduceMotion);
    _progressOwner.updateConfiguration(_progressConfiguration);
    _interactionOwner.setReduceMotion(nextReduceMotion);
    _settleForMotionPolicy();
  }

  bool get _hasContent => widget.child != null;

  bool get _canStartGesture =>
      !widget.disabled && !_progressOwner.busy && _hasContent;

  bool get _canDispatchTap =>
      !widget.disabled &&
      !_progressOwner.busy &&
      _hasContent &&
      widget.onPress != null;

  bool get _semanticsEnabled =>
      !widget.disabled && !_progressOwner.busy && _hasContent;

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

  _AwesomeButtonSizeTextConfiguration _sizeTextConfigurationFor(
    AwesomeButton candidate,
  ) {
    return _AwesomeButtonSizeTextConfiguration(
      widthMode: _widthModeFor(candidate),
      fixedWidth: _normalizedOptionalDimension(candidate.width),
      height: _normalizedRequiredDimension(candidate.height, 52),
      animateSize: candidate.animateSize,
      textTransition: candidate.textTransition,
      reduceMotion: _reduceMotion,
      stringChild: _extractStringChild(candidate.child),
    );
  }

  _AwesomeButtonProgressConfiguration get _progressConfiguration =>
      _AwesomeButtonProgressConfiguration(
        loadingTime: _normalizedDuration(widget.progressLoadingTime),
        showProgressBar: widget.showProgressBar,
        reduceMotion: _reduceMotion,
      );

  _AwesomeButtonInteractionConfiguration _interactionConfiguration(
    Duration pressAnimationDuration,
    Curve pressAnimationCurve,
  ) {
    return _AwesomeButtonInteractionConfiguration(
      pressAnimationDuration: pressAnimationDuration,
      pressAnimationCurve: pressAnimationCurve,
      debounceDuration: _normalizedDuration(widget.debouncedPressTime),
      reduceMotion: _reduceMotion,
    );
  }

  void _handleSizeTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleProgressChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    for (final command in _progressOwner.drainCommands()) {
      if (!mounted || !_progressOwner.ownsGeneration(command.runId)) {
        if (command is _ProgressReleaseCommand &&
            !command.completer.isCompleted) {
          command.completer.complete(false);
        }
        continue;
      }
      switch (command) {
        case _ProgressStartedCommand():
          widget.onProgressStart?.call();
          if (!mounted ||
              !_progressOwner.isCurrent(command.runId) ||
              widget.disabled ||
              widget.child == null ||
              widget.onPress == null) {
            if (mounted) {
              _progressOwner.abort(command.runId, widget.onProgressEnd);
            }
            continue;
          }
          _progressOwner.continueAfterStart(command.runId);
        case _ProgressActivateCommand():
          final onPress = widget.onPress;
          if (!_progressOwner.isCurrent(command.runId) ||
              widget.disabled ||
              widget.child == null ||
              onPress == null) {
            _progressOwner.abort(command.runId, widget.onProgressEnd);
            continue;
          }
          onPress(
            ([callback]) {
              if (!mounted) {
                return;
              }
              _progressOwner.acceptNext(
                command.runId,
                callback,
                widget.onProgressEnd,
              );
            },
          );
        case _ProgressReleaseCommand():
          unawaited(_routeProgressRelease(command));
        case _ProgressCallbacksCommand():
          command.completion?.call();
          if (!mounted || !_progressOwner.ownsGeneration(command.runId)) {
            continue;
          }
          command.onProgressEnd?.call();
      }
    }
  }

  Future<void> _routeProgressRelease(_ProgressReleaseCommand command) async {
    if (!mounted || !_progressOwner.isCurrent(command.runId)) {
      if (!command.completer.isCompleted) {
        command.completer.complete(false);
      }
      return;
    }
    await _releasePressedState(widget.onPressedOut);
    if (!command.completer.isCompleted) {
      command.completer.complete(
        mounted && _progressOwner.isCurrent(command.runId),
      );
    }
  }

  void _handleInteractionChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    for (final command in _interactionOwner.drainCommands()) {
      switch (command) {
        case _LongPressDueCommand():
          if (!_interactionOwner.ownsGesture(command.gestureId) ||
              !_canStartGesture) {
            continue;
          }
          final callback = widget.onLongPress;
          if (callback == null) {
            _interactionOwner.disarmLongPress();
            continue;
          }
          _interactionOwner.markLongPressDispatched(command.gestureId);
          callback();
        case _ReleaseSettledCommand():
          if (!_interactionOwner.ownsReleaseGeneration(command.releaseId)) {
            if (!command.completer.isCompleted) {
              command.completer.complete(false);
            }
            continue;
          }
          command.callback?.call();
          if (!command.completer.isCompleted) {
            command.completer.complete(
              mounted &&
                  _interactionOwner.ownsReleaseGeneration(command.releaseId),
            );
          }
      }
    }
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
    final gestureId = _interactionOwner.beginPointer(
      buttons: event.buttons,
      eligible: _canStartGesture,
      hasLongPress: widget.onLongPress != null,
    );
    if (gestureId == null) {
      return;
    }

    widget.onPressIn?.call();
    if (!mounted ||
        !_interactionOwner.ownsGesture(gestureId) ||
        !_canStartGesture) {
      _cancelPhysicalGesture(notifyPressOut: mounted);
      return;
    }

    widget.onPressedIn?.call();
    if (!mounted ||
        !_interactionOwner.ownsGesture(gestureId) ||
        !_canStartGesture) {
      _cancelPhysicalGesture(notifyPressOut: mounted);
      return;
    }

    _interactionOwner.beginVisualsAndLongPress(gestureId);
  }

  void _handleTapCancel() {
    if (!_interactionOwner.presentation.pressArmed || _progressOwner.busy) {
      return;
    }
    _cancelPhysicalGesture(notifyPressOut: true);
  }

  void _handleTap() {
    if (!_interactionOwner.presentation.pressArmed) {
      return;
    }

    final onPressOutSnapshot = widget.onPressOut;
    final onPressedOutSnapshot = widget.onPressedOut;
    final terminal = _interactionOwner.claimTerminal();
    if (terminal == null) {
      return;
    }
    onPressOutSnapshot?.call();

    if (!mounted) {
      return;
    }

    if (terminal.wasLongPress ||
        !_canDispatchTap ||
        !_interactionOwner.consumeDebounce()) {
      unawaited(_releasePressedState(onPressedOutSnapshot));
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
    unawaited(_releasePressedState(onPressedOutSnapshot));
  }

  void _handleAtomicActivate() {
    if (!_canDispatchTap || !_interactionOwner.consumeDebounce()) {
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

  void _cancelPhysicalGesture({required bool notifyPressOut}) {
    if (!_interactionOwner.presentation.pressArmed) {
      return;
    }
    final onPressOutSnapshot = widget.onPressOut;
    final onPressedOutSnapshot = widget.onPressedOut;
    final terminal = _interactionOwner.cancelPointer();
    if (terminal == null) {
      return;
    }
    if (notifyPressOut) {
      onPressOutSnapshot?.call();
    }
    if (!mounted) {
      return;
    }
    unawaited(_releasePressedState(onPressedOutSnapshot));
  }

  void _handleAuxiliaryMeasured(_ButtonAuxiliaryMeasurement measurement) {
    if (!mounted ||
        measurement.revision != _auxiliaryMeasurementRevision ||
        measurement == _auxiliaryMeasurement) {
      return;
    }
    setState(() {
      _auxiliaryMeasurement = measurement;
    });
    _sizeTextOwner.requestCurrentTargetMeasurement();
  }

  void _scheduleTextMeasurement(_AutoWidthMeasurement measurement) {
    final key = Object.hash(
      measurement.runId,
      measurement.requestId,
      measurement.metricRevision,
      measurement.kind,
      measurement.text,
      measurement.requiredWidth.toStringAsFixed(3),
      measurement.displayedRequiredWidth.toStringAsFixed(3),
      measurement.availableWidth.toStringAsFixed(3),
      measurement.fits,
      measurement.externallyConstrained,
      _auxiliaryMeasurementRevision,
    );
    if (_scheduledTextMeasurementKey == key) {
      return;
    }
    _scheduledTextMeasurementKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _scheduledTextMeasurementKey != key ||
          measurement.metricRevision != _textMetricRevision) {
        return;
      }
      _scheduledTextMeasurementKey = null;
      _sizeTextOwner.handleMeasurement(measurement);
    });
  }

  void _scheduleTargetCommitProof(_TargetCommitProof proof) {
    final key = Object.hash(
      proof.runId,
      proof.publicationId,
      proof.metricRevision,
      proof.text,
      proof.requiredWidth.toStringAsFixed(3),
      proof.availableWidth.toStringAsFixed(3),
      proof.fits,
      proof.externallyConstrained,
    );
    if (_scheduledTargetCommitKey == key) {
      return;
    }
    _scheduledTargetCommitKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scheduledTargetCommitKey != key) {
        return;
      }
      _scheduledTargetCommitKey = null;
      _sizeTextOwner.handleTargetCommitProof(proof);
    });
  }

  void _scheduleCurrentTargetRemeasure(Object key) {
    if (_scheduledTargetRemeasureKey == key) {
      return;
    }
    _scheduledTargetRemeasureKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scheduledTargetRemeasureKey != key) {
        return;
      }
      _scheduledTargetRemeasureKey = null;
      _sizeTextOwner.requestCurrentTargetMeasurement();
    });
  }

  void _startProgressFlow({required bool physicalLifecycle}) {
    if (_progressOwner.busy || widget.onPress == null) {
      return;
    }
    _progressOwner.updateConfiguration(_progressConfiguration);
    if (!physicalLifecycle) {
      _interactionOwner.resetForAtomicActivation();
    }
    _progressOwner.start(physicalLifecycle: physicalLifecycle);
  }

  Future<void> _releasePressedState(
      [VoidCallback? onPressedOutSnapshot]) async {
    await _interactionOwner.release(onPressedOutSnapshot);
  }

  void _settleForMotionPolicy() {
    if (!_reduceMotion) {
      return;
    }
    _progressOwner.settleForReducedMotion();
    _interactionOwner.settleForReducedMotion();
    if (_progressOwner.busy && !_progressOwner.nextConsumed) {
      _interactionOwner.pressController.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetResolvedStyle = _resolveStyle(context);
    final pressAnimationDuration = _normalizedOptionalDuration(
          widget.pressInAnimationDuration ??
              widget.style?.pressInAnimationDuration,
        ) ??
        targetResolvedStyle.animationDuration;
    _interactionOwner.updateConfiguration(
      _interactionConfiguration(
        pressAnimationDuration,
        targetResolvedStyle.animationCurve,
      ),
    );
    final progressPresentation = _progressOwner.presentation;
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
            _interactionOwner.pressController,
            _progressOwner.progressController,
            _progressOwner.contentTransitionController,
            _progressOwner.activityTransitionController,
            _progressOwner.overlayOpacityController,
            _sizeTextOwner.widthController,
            _sizeTextOwner.heightController,
          ]),
          builder: (context, child) {
            final sizePresentation = _sizeTextOwner.presentation;
            return LayoutBuilder(
              builder: (context, constraints) {
                final devicePixelRatio = View.of(context).devicePixelRatio;
                final labelTextStyle =
                    _resolvedButtonLabelTextStyle(context, resolvedStyle);
                final auxiliary = _auxiliaryMeasurement;
                final displayedText = sizePresentation.displayedText;
                final displayedRequiredWidth = auxiliary != null &&
                        displayedText != null &&
                        displayedText.isNotEmpty
                    ? _roundRequiredWidthToPhysicalPixel(
                        _measureButtonLabelOuterWidth(
                          context: context,
                          text: displayedText,
                          textStyle: labelTextStyle,
                          padding: _contentPadding,
                          borderWidth: resolvedStyle.borderWidth,
                          contentGap: resolvedStyle.contentGap,
                          hasBefore: widget.before != null,
                          hasAfter: widget.after != null,
                          auxiliary: auxiliary,
                        ),
                        devicePixelRatio,
                      )
                    : null;
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final textGrowthHeight = widget.child is String
                    ? resolvedStyle.textLineHeight * textScale +
                        _contentPadding.vertical +
                        (resolvedStyle.borderWidth * 2)
                    : 0.0;
                final visualHeight =
                    math.max(sizePresentation.height, textGrowthHeight);
                final totalHeight = visualHeight + resolvedStyle.raiseAmount;
                final shadowHeight =
                    math.max(0.0, visualHeight - resolvedStyle.raiseAmount);
                final requestedShellWidth =
                    switch (sizePresentation.widthMode) {
                  _ButtonWidthMode.stretch => double.infinity,
                  _ButtonWidthMode.fixed => sizePresentation.width,
                  _ButtonWidthMode.auto => auxiliary == null
                      ? null
                      : _reduceMotion && displayedRequiredWidth != null
                          ? displayedRequiredWidth
                          : sizePresentation.transientTextFrame &&
                                  displayedRequiredWidth != null
                              ? math.max(
                                  sizePresentation.width ?? 0,
                                  displayedRequiredWidth,
                                )
                              : sizePresentation.width ??
                                  displayedRequiredWidth,
                };
                final availableWidth = requestedShellWidth == null
                    ? displayedRequiredWidth ?? constraints.minWidth
                    : requestedShellWidth.isFinite
                        ? constraints.constrainWidth(requestedShellWidth)
                        : constraints.maxWidth;
                final metricSignature = Object.hashAll([
                  labelTextStyle,
                  DefaultTextStyle.of(context).textWidthBasis,
                  DefaultTextStyle.of(context).textHeightBehavior,
                  MediaQuery.textScalerOf(context),
                  Localizations.maybeLocaleOf(context),
                  direction,
                  _contentPadding,
                  resolvedStyle.borderWidth,
                  resolvedStyle.contentGap,
                  widget.before != null,
                  widget.after != null,
                  auxiliary,
                  constraints.minWidth,
                  constraints.maxWidth,
                  devicePixelRatio,
                ]);
                if (_textMetricSignature != metricSignature) {
                  _textMetricSignature = metricSignature;
                  _textMetricRevision += 1;
                }
                final measurementRequest = sizePresentation.measurementRequest;
                if (measurementRequest != null && auxiliary != null) {
                  final requiredWidth = _roundRequiredWidthToPhysicalPixel(
                    _measureButtonLabelOuterWidth(
                      context: context,
                      text: measurementRequest.text,
                      textStyle: labelTextStyle,
                      padding: _contentPadding,
                      borderWidth: resolvedStyle.borderWidth,
                      contentGap: resolvedStyle.contentGap,
                      hasBefore: widget.before != null,
                      hasAfter: widget.after != null,
                      auxiliary: auxiliary,
                    ),
                    devicePixelRatio,
                  );
                  final fits = _hasPhysicalPixelFit(
                    requiredWidth,
                    availableWidth,
                    devicePixelRatio,
                  );
                  final externallyConstrained =
                      sizePresentation.widthMode != _ButtonWidthMode.auto ||
                          (constraints.hasBoundedWidth &&
                              !_hasPhysicalPixelFit(
                                requiredWidth,
                                constraints.maxWidth,
                                devicePixelRatio,
                              ));
                  _scheduleTextMeasurement(
                    _AutoWidthMeasurement(
                      runId: measurementRequest.runId,
                      requestId: measurementRequest.requestId,
                      metricRevision: _textMetricRevision,
                      kind: measurementRequest.kind,
                      text: measurementRequest.text,
                      requiredWidth: requiredWidth,
                      displayedRequiredWidth:
                          displayedRequiredWidth ?? requiredWidth,
                      availableWidth: availableWidth,
                      fits: fits,
                      externallyConstrained: externallyConstrained,
                    ),
                  );
                }
                final publicationId = sizePresentation.targetPublicationId;
                final publicationRunId =
                    sizePresentation.targetPublicationRunId;
                if (publicationId != null &&
                    publicationRunId != null &&
                    displayedText == widget.child &&
                    displayedRequiredWidth != null) {
                  final fits = _hasPhysicalPixelFit(
                    displayedRequiredWidth,
                    availableWidth,
                    devicePixelRatio,
                  );
                  final externallyConstrained =
                      sizePresentation.widthMode != _ButtonWidthMode.auto ||
                          (constraints.hasBoundedWidth &&
                              !_hasPhysicalPixelFit(
                                displayedRequiredWidth,
                                constraints.maxWidth,
                                devicePixelRatio,
                              ));
                  _scheduleTargetCommitProof(
                    _TargetCommitProof(
                      runId: publicationRunId,
                      publicationId: publicationId,
                      metricRevision: _textMetricRevision,
                      text: displayedText!,
                      requiredWidth: displayedRequiredWidth,
                      availableWidth: availableWidth,
                      fits: fits,
                      externallyConstrained: externallyConstrained,
                    ),
                  );
                } else if (measurementRequest == null &&
                    sizePresentation.widthMode == _ButtonWidthMode.auto &&
                    !sizePresentation.transientTextFrame &&
                    displayedText == widget.child &&
                    displayedRequiredWidth != null &&
                    sizePresentation.width != null &&
                    (displayedRequiredWidth - sizePresentation.width!).abs() >=
                        _textTransitionFitTolerance &&
                    !_sizeTextOwner.widthController.isAnimating) {
                  _scheduleCurrentTargetRemeasure(
                    Object.hash(
                      displayedText,
                      displayedRequiredWidth.toStringAsFixed(3),
                      sizePresentation.width!.toStringAsFixed(3),
                      _auxiliaryMeasurementRevision,
                    ),
                  );
                }
                final shellWidth = requestedShellWidth;
                final stretchFace = widget.stretch || shellWidth != null;
                final pressValue = _interactionOwner.pressController.value;
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
                        padding:
                            EdgeInsets.only(top: resolvedStyle.raiseAmount),
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
                        activeBackgroundColor:
                            resolvedStyle.activeBackgroundColor,
                        activeBackgroundOpacity: widget.showProgressBar ||
                                !progressPresentation.showVisuals
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
                        progressValue: _progressOwner.progressController.value,
                        progressOverlayOpacity:
                            _progressOwner.overlayOpacityController.value,
                        contentTransitionValue:
                            _progressOwner.contentTransitionController.value,
                        activityTransitionValue:
                            _progressOwner.activityTransitionController.value,
                        showProgressVisuals: progressPresentation.showVisuals,
                        showProgressBar: widget.showProgressBar,
                        animatedPlaceholder:
                            widget.animatedPlaceholder && !_reduceMotion,
                        textStyle: labelTextStyle,
                        textLineHeight: resolvedStyle.textLineHeight,
                        transientTextFrame: sizePresentation.transientTextFrame,
                        alignTextLogicalLeading:
                            sizePresentation.alignTextLogicalLeading,
                        auxiliaryMeasurementRevision:
                            _auxiliaryMeasurementRevision,
                        onAuxiliaryMeasured: _handleAuxiliaryMeasured,
                        child: widget.child,
                        displayedText: sizePresentation.displayedText,
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
          },
        );
        final interactiveChild = shell;

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
          liveRegion: progressPresentation.busy,
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
              enabled:
                  _hasContent && !widget.disabled && !progressPresentation.busy,
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

part of '../awesome_button.dart';

const Duration _sizeAnimationDuration = Duration(milliseconds: 175);
const Curve _sizeAnimationCurve = Cubic(0.3, 0.05, 0.2, 1);
const double _textTransitionFitTolerance = 0.5;
const double _textTransitionPhaseLead = 0.3;

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

@immutable
class _AwesomeButtonSizeTextConfiguration {
  const _AwesomeButtonSizeTextConfiguration({
    required this.widthMode,
    required this.fixedWidth,
    required this.height,
    required this.animateSize,
    required this.textTransition,
    required this.reduceMotion,
    required this.stringChild,
  });

  final _ButtonWidthMode widthMode;
  final double? fixedWidth;
  final double height;
  final bool animateSize;
  final bool textTransition;
  final bool reduceMotion;
  final String? stringChild;
}

@immutable
class _AwesomeButtonSizeTextPresentation {
  const _AwesomeButtonSizeTextPresentation({
    required this.widthMode,
    required this.width,
    required this.height,
    required this.displayedText,
    required this.measurementRequest,
    required this.transientTextFrame,
    required this.alignTextLogicalLeading,
    required this.targetPublicationId,
    required this.targetPublicationRunId,
  });

  final _ButtonWidthMode widthMode;
  final double? width;
  final double height;
  final String? displayedText;
  final _AutoWidthMeasurementRequest? measurementRequest;
  final bool transientTextFrame;
  final bool alignTextLogicalLeading;
  final int? targetPublicationId;
  final int? targetPublicationRunId;
}

class _PendingTargetCommit {
  _PendingTargetCommit({
    required this.runId,
    required this.publicationId,
    required this.metricRevision,
    required this.text,
    required this.requiredWidth,
  });

  final int runId;
  final int publicationId;
  int metricRevision;
  final String text;
  double requiredWidth;
  bool nativeCommitted = false;
  bool fits = false;
  bool externallyConstrained = false;
}

class _AwesomeButtonSizeTextOwner extends ChangeNotifier {
  _AwesomeButtonSizeTextOwner({
    required TickerProvider vsync,
    required _AwesomeButtonSizeTextConfiguration initialConfiguration,
  })  : _configuration = initialConfiguration,
        _displayedText = initialConfiguration.stringChild,
        _currentTextTarget = initialConfiguration.stringChild,
        _widthMode = initialConfiguration.widthMode,
        _resolvedWidth =
            initialConfiguration.widthMode == _ButtonWidthMode.fixed
                ? initialConfiguration.fixedWidth
                : null,
        _resolvedHeight = initialConfiguration.height,
        _heightAnimationFrom = initialConfiguration.height,
        _heightAnimationTo = initialConfiguration.height,
        widthController = AnimationController(
          vsync: vsync,
          duration: _sizeAnimationDuration,
        ),
        heightController = AnimationController(
          vsync: vsync,
          duration: _sizeAnimationDuration,
        ) {
    widthController.addListener(_handleWidthTick);
    final initialText = initialConfiguration.stringChild;
    if (initialText != null && initialText.isNotEmpty) {
      _sizeRunId += 1;
      _requestMeasurement(_TextMeasurementKind.target, initialText);
    }
  }

  final AnimationController widthController;
  final AnimationController heightController;

  _AwesomeButtonSizeTextConfiguration _configuration;
  TextTransitionController? _textTransitionController;
  String? _displayedText;
  String? _currentTextTarget;
  String? _transitionSourceText;
  _ButtonWidthMode _widthMode;
  _AutoWidthTextFlow _activeFlow = _AutoWidthTextFlow.initial;
  TextTransitionTimeline? _activeTimeline;
  double? _resolvedWidth;
  double? _widthAnimationFrom;
  double? _widthAnimationTo;
  double? _displayedFrameWidth;
  double? _targetMeasuredWidth;
  double _resolvedHeight;
  double _heightAnimationFrom;
  double _heightAnimationTo;
  bool _isWidthAnimating = false;
  bool _isHeightAnimating = false;
  bool _transitionStarted = false;
  bool _textEngineComplete = false;
  bool _textPhaseComplete = false;
  bool _widthPhaseComplete = true;
  bool _growthTextGatePending = false;
  bool _shrinkWidthGatePending = false;
  bool _atomicGrowthHandoffPending = false;
  bool _transientTextFrame = false;
  int _widthAnimationToken = 0;
  int _heightAnimationToken = 0;
  int _sizeRunId = 0;
  int _measurementSequence = 0;
  int _publicationSequence = 0;
  _AutoWidthMeasurementRequest? _measurementRequest;
  _PendingTargetCommit? _pendingTargetCommit;
  bool _disposed = false;

  _AwesomeButtonSizeTextPresentation get presentation =>
      _AwesomeButtonSizeTextPresentation(
        widthMode: _widthMode,
        width: currentWidth,
        height: currentHeight,
        displayedText: _displayedText,
        measurementRequest: _measurementRequest,
        transientTextFrame: _transientTextFrame,
        alignTextLogicalLeading:
            _transitionStarted && _activeFlow == _AutoWidthTextFlow.shrinkLast,
        targetPublicationId: _pendingTargetCommit?.publicationId,
        targetPublicationRunId: _pendingTargetCommit?.runId,
      );

  double? get _nominalCurrentWidth {
    final from = _widthAnimationFrom;
    final to = _widthAnimationTo;
    if (_isWidthAnimating && from != null && to != null) {
      return lerpDouble(
        from,
        to,
        _sizeAnimationCurve.transform(widthController.value),
      );
    }
    return _resolvedWidth;
  }

  double? get currentWidth {
    final nominal = _nominalCurrentWidth;
    if (!_transitionStarted ||
        _widthMode != _ButtonWidthMode.auto ||
        _displayedFrameWidth == null) {
      return nominal;
    }
    if (nominal == null) {
      return _displayedFrameWidth;
    }
    return math.max(nominal, _displayedFrameWidth!);
  }

  double get currentHeight {
    if (_isHeightAnimating) {
      return lerpDouble(
            _heightAnimationFrom,
            _heightAnimationTo,
            _sizeAnimationCurve.transform(heightController.value),
          ) ??
          _resolvedHeight;
    }
    return _resolvedHeight;
  }

  void update({
    required _AwesomeButtonSizeTextConfiguration previous,
    required _AwesomeButtonSizeTextConfiguration current,
    required bool textOrMeasurementDependenciesChanged,
  }) {
    if (_disposed) {
      return;
    }
    _configuration = current;
    final previousWidthMode = _widthMode;
    _widthMode = current.widthMode;

    if (previousWidthMode != current.widthMode) {
      _invalidateTextRun();
      _setWidthImmediately(
        current.widthMode == _ButtonWidthMode.fixed ? current.fixedWidth : null,
      );
    } else if (current.widthMode == _ButtonWidthMode.fixed &&
        current.fixedWidth != null &&
        (previous.fixedWidth != current.fixedWidth ||
            previous.animateSize != current.animateSize)) {
      _animateWidthTo(current.fixedWidth!);
    }

    if (previous.height != current.height ||
        previous.animateSize != current.animateSize) {
      _animateHeightTo(current.height);
    }

    if (textOrMeasurementDependenciesChanged) {
      _syncTextAndWidthState();
    }
  }

  void setReduceMotion(bool reduceMotion) {
    if (_disposed || _configuration.reduceMotion == reduceMotion) {
      return;
    }
    _configuration = _copyConfiguration(reduceMotion: reduceMotion);
    if (!reduceMotion) {
      return;
    }

    final target = _currentTextTarget;
    _invalidateTextRun(preserveTarget: true);
    _displayedText = target;
    _transientTextFrame = false;
    _setHeightImmediately(_configuration.height);
    if (_widthMode == _ButtonWidthMode.fixed) {
      _setWidthImmediately(_configuration.fixedWidth);
    } else if (_widthMode == _ButtonWidthMode.auto) {
      _setWidthImmediately(_targetMeasuredWidth);
      if (target != null && target.isNotEmpty) {
        _requestMeasurement(_TextMeasurementKind.target, target);
      }
    }
    _notifyChanged();
  }

  _AwesomeButtonSizeTextConfiguration _copyConfiguration({
    required bool reduceMotion,
  }) {
    return _AwesomeButtonSizeTextConfiguration(
      widthMode: _configuration.widthMode,
      fixedWidth: _configuration.fixedWidth,
      height: _configuration.height,
      animateSize: _configuration.animateSize,
      textTransition: _configuration.textTransition,
      reduceMotion: reduceMotion,
      stringChild: _configuration.stringChild,
    );
  }

  void requestCurrentTargetMeasurement() {
    if (_disposed) {
      return;
    }
    final target = _currentTextTarget;
    if (target == null || target.isEmpty) {
      return;
    }
    _requestMeasurement(_TextMeasurementKind.target, target);
  }

  void handleMeasurement(_AutoWidthMeasurement measurement) {
    final request = _measurementRequest;
    if (_disposed ||
        request == null ||
        request.runId != measurement.runId ||
        request.requestId != measurement.requestId ||
        request.kind != measurement.kind ||
        request.text != measurement.text ||
        measurement.runId != _sizeRunId) {
      return;
    }

    _measurementRequest = null;
    switch (measurement.kind) {
      case _TextMeasurementKind.target:
        _handleTargetMeasurement(measurement);
        return;
      case _TextMeasurementKind.candidate:
        _handleCandidateMeasurement(measurement);
        return;
    }
  }

  void handleTargetCommitProof(_TargetCommitProof proof) {
    final pending = _pendingTargetCommit;
    if (_disposed ||
        pending == null ||
        pending.runId != proof.runId ||
        pending.publicationId != proof.publicationId ||
        pending.text != proof.text ||
        proof.metricRevision < pending.metricRevision ||
        proof.runId != _sizeRunId) {
      return;
    }
    pending
      ..metricRevision = proof.metricRevision
      ..requiredWidth = proof.requiredWidth;
    if (_widthMode == _ButtonWidthMode.auto &&
        (_targetMeasuredWidth == null ||
            (_targetMeasuredWidth! - proof.requiredWidth).abs() >=
                _textTransitionFitTolerance)) {
      _retargetActiveWidth(proof.requiredWidth);
    }
    pending
      ..nativeCommitted = true
      ..fits = proof.fits
      ..externallyConstrained = proof.externallyConstrained;
    _trySettleTargetCommit();
    _notifyChanged();
  }

  void _handleTargetMeasurement(_AutoWidthMeasurement measurement) {
    final targetWidth = measurement.requiredWidth;
    _targetMeasuredWidth = targetWidth;
    _displayedFrameWidth ??= measurement.displayedRequiredWidth;

    if (_transitionStarted) {
      if (_widthMode == _ButtonWidthMode.auto &&
          (_widthAnimationTo == null ||
              (_widthAnimationTo! - targetWidth).abs() >=
                  _textTransitionFitTolerance)) {
        _retargetActiveWidth(targetWidth);
      }
      _notifyChanged();
      return;
    }

    final targetText = _currentTextTarget;
    if (targetText == null || targetText.isEmpty) {
      _notifyChanged();
      return;
    }
    final displayed = _displayedText;
    final initial = displayed == targetText && _resolvedWidth == null;
    if (initial) {
      if (_widthMode == _ButtonWidthMode.auto) {
        _setWidthImmediately(targetWidth);
      }
      _displayedFrameWidth = targetWidth;
      _transientTextFrame = false;
      _notifyChanged();
      return;
    }

    if (!_shouldAnimateText(displayed, targetText)) {
      _settleWithoutTextTransition(
        targetText,
        measurement.displayedRequiredWidth,
        measurement,
      );
      return;
    }
    _startMeasuredTransition(
      targetText,
      measurement.displayedRequiredWidth,
      targetWidth,
    );
  }

  void _handleCandidateMeasurement(_AutoWidthMeasurement measurement) {
    if (!_transitionStarted) {
      return;
    }
    if (_atomicGrowthHandoffPending) {
      if (!measurement.fits && !measurement.externallyConstrained) {
        _notifyChanged();
        return;
      }
      _atomicGrowthHandoffPending = false;
      _displayedText = measurement.text;
      _displayedFrameWidth = measurement.requiredWidth;
      _publishTargetCommit(measurement);
      _notifyChanged();
      return;
    }
    final isFinalTarget =
        _textEngineComplete && measurement.text == _currentTextTarget;
    if (isFinalTarget &&
        _widthMode == _ButtonWidthMode.auto &&
        (_targetMeasuredWidth == null ||
            (_targetMeasuredWidth! - measurement.requiredWidth).abs() >=
                _textTransitionFitTolerance)) {
      _retargetActiveWidth(measurement.requiredWidth);
      _requestMeasurement(_TextMeasurementKind.candidate, measurement.text);
      return;
    }
    final requiresFit = _widthMode == _ButtonWidthMode.auto &&
        (_activeFlow == _AutoWidthTextFlow.growFirst ||
            _activeFlow == _AutoWidthTextFlow.textOnly);
    if (requiresFit &&
        !measurement.fits &&
        !measurement.externallyConstrained) {
      _notifyChanged();
      return;
    }

    _displayedText = measurement.text;
    _displayedFrameWidth = measurement.requiredWidth;
    if (isFinalTarget) {
      _publishTargetCommit(measurement);
    } else {
      _transientTextFrame = true;
    }
    _finishTransitionIfSettled();
    _notifyChanged();
  }

  void _publishTargetCommit(_AutoWidthMeasurement measurement) {
    _publicationSequence += 1;
    _pendingTargetCommit = _PendingTargetCommit(
      runId: measurement.runId,
      publicationId: _publicationSequence,
      metricRevision: measurement.metricRevision,
      text: measurement.text,
      requiredWidth: measurement.requiredWidth,
    );
    _textPhaseComplete = false;
    _transientTextFrame = true;
  }

  void _trySettleTargetCommit() {
    final pending = _pendingTargetCommit;
    if (pending == null || !pending.nativeCommitted) {
      return;
    }
    if (!pending.fits &&
        !(pending.externallyConstrained && _widthPhaseComplete)) {
      return;
    }
    _pendingTargetCommit = null;
    _textPhaseComplete = true;
    _transientTextFrame = false;
    _finishTransitionIfSettled();
  }

  bool _shouldAnimateText(String? source, String target) {
    return _configuration.textTransition &&
        !_configuration.reduceMotion &&
        source != null &&
        source.isNotEmpty &&
        target.isNotEmpty &&
        source != target;
  }

  void _settleWithoutTextTransition(
    String targetText,
    double sourceWidth,
    _AutoWidthMeasurement measurement,
  ) {
    final targetWidth = measurement.requiredWidth;
    final flow = _autoWidthTextFlow(sourceWidth, targetWidth);
    _targetMeasuredWidth = targetWidth;

    if (_widthMode != _ButtonWidthMode.auto ||
        !_configuration.animateSize ||
        _configuration.reduceMotion ||
        flow == _AutoWidthTextFlow.initial) {
      if (_widthMode == _ButtonWidthMode.auto) {
        _setWidthImmediately(targetWidth);
      }
      _displayedText = targetText;
      _displayedFrameWidth = targetWidth;
      _transientTextFrame = false;
      _notifyChanged();
      return;
    }

    _activeFlow = flow;
    _transitionSourceText = _displayedText;
    _transitionStarted = true;
    _textEngineComplete = true;
    _textPhaseComplete = false;
    _widthPhaseComplete = flow == _AutoWidthTextFlow.textOnly;
    _atomicGrowthHandoffPending = flow == _AutoWidthTextFlow.growFirst;
    _displayedFrameWidth = sourceWidth;
    _transientTextFrame = true;

    if (flow == _AutoWidthTextFlow.textOnly) {
      if (targetWidth > sourceWidth) {
        _setWidthImmediately(targetWidth);
      }
      _displayedText = targetText;
      _displayedFrameWidth = targetWidth;
      _publishTargetCommit(measurement);
      _notifyChanged();
      return;
    }

    if (flow == _AutoWidthTextFlow.shrinkLast) {
      _displayedText = targetText;
      _displayedFrameWidth = targetWidth;
      _publishTargetCommit(measurement);
      _animateWidthTo(
        targetWidth,
        onComplete: _markWidthPhaseComplete,
      );
      _notifyChanged();
      return;
    }

    _widthPhaseComplete = false;
    _requestMeasurement(_TextMeasurementKind.candidate, targetText);
    _animateWidthTo(
      targetWidth,
      onComplete: _markWidthPhaseComplete,
    );
  }

  void _startMeasuredTransition(
    String targetText,
    double sourceWidth,
    double targetWidth,
  ) {
    final sourceText = _displayedText!;
    _transitionSourceText = sourceText;
    _activeTimeline = getTextTransitionTimeline(sourceText, targetText);
    _activeFlow = _autoWidthTextFlow(sourceWidth, targetWidth);
    _displayedFrameWidth = sourceWidth;
    _transitionStarted = true;
    _textEngineComplete = false;
    _textPhaseComplete = false;
    _widthPhaseComplete = _widthMode != _ButtonWidthMode.auto ||
        _activeFlow == _AutoWidthTextFlow.textOnly;
    _growthTextGatePending = false;
    _shrinkWidthGatePending = false;
    _transientTextFrame = true;

    final duration = Duration(
      milliseconds: _activeTimeline!.totalDurationMs,
    );
    if (_widthMode != _ButtonWidthMode.auto || !_configuration.animateSize) {
      if (_widthMode == _ButtonWidthMode.auto) {
        _setWidthImmediately(targetWidth);
      }
      _widthPhaseComplete = true;
      _beginTextClock(_sizeRunId, sourceText, targetText);
      return;
    }

    switch (_activeFlow) {
      case _AutoWidthTextFlow.initial:
        _setWidthImmediately(targetWidth);
        _widthPhaseComplete = true;
        _beginTextClock(_sizeRunId, sourceText, targetText);
        return;
      case _AutoWidthTextFlow.textOnly:
        _beginTextClock(_sizeRunId, sourceText, targetText);
        return;
      case _AutoWidthTextFlow.growFirst:
        _growthTextGatePending = true;
        _animateWidthTo(
          targetWidth,
          duration: duration,
          onComplete: _markWidthPhaseComplete,
        );
        _handleWidthTick();
        return;
      case _AutoWidthTextFlow.shrinkLast:
        _shrinkWidthGatePending = true;
        _beginTextClock(_sizeRunId, sourceText, targetText);
        return;
    }
  }

  void _beginTextClock(int runId, String sourceText, String targetText) {
    if (_disposed || runId != _sizeRunId || _textTransitionController != null) {
      return;
    }
    _textTransitionController = runTextTransition(
      fromText: sourceText,
      targetText: targetText,
      onTick: (elapsedMs, timeline) {
        if (_disposed || runId != _sizeRunId) {
          return;
        }
        if (_shrinkWidthGatePending &&
            elapsedMs >=
                (timeline.totalDurationMs * _textTransitionPhaseLead)) {
          _shrinkWidthGatePending = false;
          final width = _targetMeasuredWidth;
          if (width != null) {
            _animateWidthTo(
              width,
              duration: Duration(milliseconds: timeline.totalDurationMs),
              onComplete: _markWidthPhaseComplete,
            );
          } else {
            _markWidthPhaseComplete();
          }
        }
      },
      onUpdate: (value) {
        if (_disposed || runId != _sizeRunId) {
          return;
        }
        _requestMeasurement(_TextMeasurementKind.candidate, value);
      },
      onComplete: () {
        if (_disposed || runId != _sizeRunId) {
          return;
        }
        _textTransitionController = null;
        _textEngineComplete = true;
        _requestMeasurement(
          _TextMeasurementKind.candidate,
          targetText,
        );
      },
    );
  }

  void _handleWidthTick() {
    if (_disposed) {
      return;
    }
    if (_atomicGrowthHandoffPending && _measurementRequest == null) {
      final target = _currentTextTarget;
      if (target != null && target.isNotEmpty) {
        _requestMeasurement(_TextMeasurementKind.candidate, target);
      }
    }
    _requestPendingFinalTargetIfNeeded();
    if (!_growthTextGatePending ||
        !_isWidthAnimating ||
        widthController.value < _textTransitionPhaseLead) {
      return;
    }
    _growthTextGatePending = false;
    final source = _displayedText;
    final target = _currentTextTarget;
    if (source != null && target != null) {
      _beginTextClock(_sizeRunId, source, target);
    }
  }

  void _markWidthPhaseComplete() {
    if (_disposed) {
      return;
    }
    _widthPhaseComplete = true;
    if (_atomicGrowthHandoffPending && _measurementRequest == null) {
      final target = _currentTextTarget;
      if (target != null && target.isNotEmpty) {
        _requestMeasurement(_TextMeasurementKind.candidate, target);
      }
    }
    _requestPendingFinalTargetIfNeeded();
    _trySettleTargetCommit();
    _finishTransitionIfSettled();
    _notifyChanged();
  }

  void _requestPendingFinalTargetIfNeeded() {
    if (!_transitionStarted ||
        !_textEngineComplete ||
        _textPhaseComplete ||
        _atomicGrowthHandoffPending ||
        _pendingTargetCommit != null ||
        _measurementRequest != null) {
      return;
    }
    final target = _currentTextTarget;
    if (target != null && target.isNotEmpty) {
      _requestMeasurement(_TextMeasurementKind.candidate, target);
    }
  }

  void _finishTransitionIfSettled() {
    if (!_transitionStarted ||
        !_textPhaseComplete ||
        !_widthPhaseComplete ||
        _pendingTargetCommit != null) {
      return;
    }
    _transitionStarted = false;
    _activeFlow = _AutoWidthTextFlow.initial;
    _activeTimeline = null;
    _transitionSourceText = null;
    _growthTextGatePending = false;
    _shrinkWidthGatePending = false;
    _atomicGrowthHandoffPending = false;
    _transientTextFrame = false;
    _displayedFrameWidth = _targetMeasuredWidth;
    if (_widthMode == _ButtonWidthMode.auto && _targetMeasuredWidth != null) {
      _resolvedWidth = _targetMeasuredWidth;
    }
  }

  void _retargetActiveWidth(double targetWidth) {
    if (_widthMode != _ButtonWidthMode.auto) {
      return;
    }
    _targetMeasuredWidth = targetWidth;
    if (!_isWidthAnimating) {
      if (_widthPhaseComplete) {
        _setWidthImmediately(targetWidth);
      }
      return;
    }
    final remainingFraction = (1 - widthController.value).clamp(0.0, 1.0);
    final originalDuration = widthController.duration ?? _sizeAnimationDuration;
    final remaining = Duration(
      microseconds:
          (originalDuration.inMicroseconds * remainingFraction).round(),
    );
    _animateWidthTo(
      targetWidth,
      duration: remaining,
      onComplete: _markWidthPhaseComplete,
    );
  }

  void _requestMeasurement(_TextMeasurementKind kind, String text) {
    if (_disposed || text.isEmpty) {
      return;
    }
    _measurementSequence += 1;
    _measurementRequest = _AutoWidthMeasurementRequest(
      runId: _sizeRunId,
      requestId: _measurementSequence,
      kind: kind,
      text: text,
    );
    _notifyChanged();
  }

  void _syncTextAndWidthState() {
    final nextText = _configuration.stringChild;
    if (nextText == _currentTextTarget &&
        !(_widthMode == _ButtonWidthMode.auto && _resolvedWidth == null)) {
      if (!_configuration.textTransition && _transitionStarted) {
        final replacementFrame = _activeFlow == _AutoWidthTextFlow.growFirst
            ? (_transitionSourceText ?? _displayedText)
            : nextText;
        _invalidateTextRun(preserveTarget: true);
        _displayedText = replacementFrame;
        final requiresMeasuredAutoHandoff =
            _widthMode == _ButtonWidthMode.auto &&
                nextText != null &&
                nextText.isNotEmpty &&
                _displayedText != null &&
                _displayedText!.isNotEmpty &&
                _displayedText != nextText;
        if (requiresMeasuredAutoHandoff) {
          _transientTextFrame = true;
          _requestMeasurement(_TextMeasurementKind.target, nextText);
        } else {
          _displayedText = nextText;
          _transientTextFrame = false;
          _notifyChanged();
        }
      }
      return;
    }

    _invalidateTextRun();
    _currentTextTarget = nextText;
    if (nextText == null || nextText.isEmpty) {
      _displayedText = nextText;
      _displayedFrameWidth = null;
      _transientTextFrame = false;
      if (_widthMode == _ButtonWidthMode.auto) {
        _setWidthImmediately(null);
      }
      _notifyChanged();
      return;
    }

    final requiresMeasuredAutoHandoff = _widthMode == _ButtonWidthMode.auto &&
        _displayedText != null &&
        _displayedText!.isNotEmpty &&
        _displayedText != nextText;
    if ((!_configuration.textTransition || _configuration.reduceMotion) &&
        requiresMeasuredAutoHandoff) {
      _transientTextFrame = true;
    } else if (!_configuration.textTransition ||
        _configuration.reduceMotion ||
        _displayedText == null ||
        _displayedText!.isEmpty ||
        _displayedText == nextText) {
      _displayedText = nextText;
      _transientTextFrame = false;
    } else {
      _transientTextFrame = true;
    }
    _requestMeasurement(_TextMeasurementKind.target, nextText);
  }

  void _invalidateTextRun({bool preserveTarget = false}) {
    final interruptedWidth = currentWidth;
    _sizeRunId += 1;
    _measurementRequest = null;
    _pendingTargetCommit = null;
    _textTransitionController?.stop();
    _textTransitionController = null;
    _transitionStarted = false;
    _textEngineComplete = false;
    _textPhaseComplete = false;
    _widthPhaseComplete = true;
    _growthTextGatePending = false;
    _shrinkWidthGatePending = false;
    _atomicGrowthHandoffPending = false;
    _activeFlow = _AutoWidthTextFlow.initial;
    _activeTimeline = null;
    _transitionSourceText = null;
    _transientTextFrame = _displayedText != _currentTextTarget;
    _widthAnimationToken += 1;
    widthController.stop();
    _resolvedWidth = interruptedWidth;
    _widthAnimationFrom = null;
    _widthAnimationTo = null;
    _isWidthAnimating = false;
    if (!preserveTarget) {
      _targetMeasuredWidth = null;
    }
  }

  _AutoWidthTextFlow _autoWidthTextFlow(double? width, double nextWidth) {
    if (width == null) {
      return _AutoWidthTextFlow.initial;
    }
    if ((width - nextWidth).abs() < _textTransitionFitTolerance) {
      return _AutoWidthTextFlow.textOnly;
    }
    return nextWidth > width
        ? _AutoWidthTextFlow.growFirst
        : _AutoWidthTextFlow.shrinkLast;
  }

  void _setWidthImmediately(double? nextWidth) {
    _widthAnimationToken += 1;
    widthController.stop();
    _resolvedWidth = nextWidth;
    _widthAnimationFrom = null;
    _widthAnimationTo = null;
    _isWidthAnimating = false;
    _notifyChanged();
  }

  void _animateWidthTo(
    double nextWidth, {
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    final width = currentWidth;
    if (!_configuration.animateSize ||
        _configuration.reduceMotion ||
        width == null ||
        (width - nextWidth).abs() < _textTransitionFitTolerance ||
        duration == Duration.zero) {
      _setWidthImmediately(nextWidth);
      onComplete?.call();
      return;
    }
    _widthAnimationToken += 1;
    final animationToken = _widthAnimationToken;
    widthController
      ..stop()
      ..duration = duration ?? _sizeAnimationDuration;
    _widthAnimationFrom = width;
    _widthAnimationTo = nextWidth;
    _isWidthAnimating = true;
    _notifyChanged();
    widthController.forward(from: 0).orCancel.then((_) {
      if (_disposed || _widthAnimationToken != animationToken) {
        return;
      }
      _resolvedWidth = nextWidth;
      _widthAnimationFrom = null;
      _widthAnimationTo = null;
      _isWidthAnimating = false;
      _notifyChanged();
      onComplete?.call();
    }).catchError((Object _) {
      return;
    }, test: (error) => error is TickerCanceled);
  }

  void _setHeightImmediately(double nextHeight) {
    _heightAnimationToken += 1;
    heightController.stop();
    _resolvedHeight = nextHeight;
    _heightAnimationFrom = nextHeight;
    _heightAnimationTo = nextHeight;
    _isHeightAnimating = false;
    _notifyChanged();
  }

  void _animateHeightTo(double nextHeight) {
    final height = currentHeight;
    if (!_configuration.animateSize ||
        _configuration.reduceMotion ||
        (height - nextHeight).abs() < _textTransitionFitTolerance) {
      _setHeightImmediately(nextHeight);
      return;
    }
    _heightAnimationToken += 1;
    final animationToken = _heightAnimationToken;
    heightController
      ..stop()
      ..duration = _sizeAnimationDuration;
    _heightAnimationFrom = height;
    _heightAnimationTo = nextHeight;
    _isHeightAnimating = true;
    _notifyChanged();
    heightController.forward(from: 0).orCancel.then((_) {
      if (_disposed || _heightAnimationToken != animationToken) {
        return;
      }
      _resolvedHeight = nextHeight;
      _heightAnimationFrom = nextHeight;
      _heightAnimationTo = nextHeight;
      _isHeightAnimating = false;
      _notifyChanged();
    }).catchError((Object _) {
      return;
    }, test: (error) => error is TickerCanceled);
  }

  void _notifyChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _sizeRunId += 1;
    _measurementRequest = null;
    _widthAnimationToken += 1;
    _heightAnimationToken += 1;
    _textTransitionController?.stop();
    _textTransitionController = null;
    widthController
      ..removeListener(_handleWidthTick)
      ..dispose();
    heightController.dispose();
    super.dispose();
  }
}

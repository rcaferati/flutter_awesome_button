part of '../awesome_button.dart';

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
    required this.canChoreographAutoWidthText,
    required this.autoWidthMeasurementText,
  });

  final _ButtonWidthMode widthMode;
  final double? fixedWidth;
  final double height;
  final bool animateSize;
  final bool textTransition;
  final bool reduceMotion;
  final String? stringChild;
  final bool canChoreographAutoWidthText;
  final String? autoWidthMeasurementText;
}

@immutable
class _AwesomeButtonSizeTextPresentation {
  const _AwesomeButtonSizeTextPresentation({
    required this.widthMode,
    required this.width,
    required this.height,
    required this.displayedText,
    required this.measurementRequest,
  });

  final _ButtonWidthMode widthMode;
  final double? width;
  final double height;
  final String? displayedText;
  final _AutoWidthMeasurementRequest? measurementRequest;
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
    final initialMeasurementText =
        initialConfiguration.autoWidthMeasurementText;
    if (initialMeasurementText != null) {
      _sizeRunId += 1;
      _measurementRequestId = _sizeRunId;
      _measurementText = initialMeasurementText;
    }
  }

  final AnimationController widthController;
  final AnimationController heightController;

  _AwesomeButtonSizeTextConfiguration _configuration;
  TextTransitionController? _textTransitionController;
  Timer? _delayedWidthAnimationTimer;
  String? _displayedText;
  String? _currentTextTarget;
  _ButtonWidthMode _widthMode;
  double? _resolvedWidth;
  double? _widthAnimationFrom;
  double? _widthAnimationTo;
  double _resolvedHeight;
  double _heightAnimationFrom;
  double _heightAnimationTo;
  bool _isWidthAnimating = false;
  bool _isHeightAnimating = false;
  int _widthAnimationToken = 0;
  int _heightAnimationToken = 0;
  int _sizeRunId = 0;
  int? _measurementRequestId;
  String? _measurementText;
  bool _disposed = false;

  _AwesomeButtonSizeTextPresentation get presentation =>
      _AwesomeButtonSizeTextPresentation(
        widthMode: _widthMode,
        width: currentWidth,
        height: currentHeight,
        displayedText: _displayedText,
        measurementRequest:
            _measurementRequestId != null && _measurementText != null
                ? _AutoWidthMeasurementRequest(
                    requestId: _measurementRequestId!,
                    text: _measurementText!,
                  )
                : null,
      );

  double? get currentWidth {
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
      _sizeRunId += 1;
      _stopTextTransition();
      _cancelDelayedWidthAnimation();
      _clearMeasurementRequest();
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
      _syncTextAndAutoWidthState();
    }
  }

  void setReduceMotion(bool reduceMotion) {
    if (_disposed || _configuration.reduceMotion == reduceMotion) {
      return;
    }
    _configuration = _AwesomeButtonSizeTextConfiguration(
      widthMode: _configuration.widthMode,
      fixedWidth: _configuration.fixedWidth,
      height: _configuration.height,
      animateSize: _configuration.animateSize,
      textTransition: _configuration.textTransition,
      reduceMotion: reduceMotion,
      stringChild: _configuration.stringChild,
      canChoreographAutoWidthText: _configuration.canChoreographAutoWidthText,
      autoWidthMeasurementText: _configuration.autoWidthMeasurementText,
    );
    if (reduceMotion) {
      _stopTextTransition();
      _updateDisplayedText(_currentTextTarget);
    }
  }

  void handleMeasurement(_AutoWidthMeasurement measurement) {
    if (_disposed ||
        _measurementRequestId != measurement.requestId ||
        _measurementText == null) {
      return;
    }
    final targetText = _measurementText!;
    final measuredWidth = measurement.width.ceilToDouble();
    _measurementText = null;
    _measurementRequestId = null;
    _notifyChanged();
    _resolveMeasuredAutoWidth(measurement.requestId, targetText, measuredWidth);
  }

  void _cancelDelayedWidthAnimation() {
    _delayedWidthAnimationTimer?.cancel();
    _delayedWidthAnimationTimer = null;
  }

  void _clearMeasurementRequest() {
    if (_measurementText == null && _measurementRequestId == null) {
      return;
    }
    _measurementText = null;
    _measurementRequestId = null;
    _notifyChanged();
  }

  void _setWidthImmediately(double? nextWidth) {
    _widthAnimationToken += 1;
    widthController.stop();
    if (_resolvedWidth == nextWidth && !_isWidthAnimating) {
      return;
    }
    _resolvedWidth = nextWidth;
    _widthAnimationFrom = null;
    _widthAnimationTo = null;
    _isWidthAnimating = false;
    _notifyChanged();
  }

  void _animateWidthTo(double nextWidth, {VoidCallback? onComplete}) {
    final width = currentWidth;
    if (!_configuration.animateSize ||
        _configuration.reduceMotion ||
        width == null ||
        (width - nextWidth).abs() < 0.5) {
      _setWidthImmediately(nextWidth);
      onComplete?.call();
      return;
    }
    _widthAnimationToken += 1;
    final animationToken = _widthAnimationToken;
    widthController.stop();
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
    if ((_resolvedHeight - nextHeight).abs() < 0.5 && !_isHeightAnimating) {
      return;
    }
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
        (height - nextHeight).abs() < 0.5) {
      _setHeightImmediately(nextHeight);
      return;
    }
    _heightAnimationToken += 1;
    final animationToken = _heightAnimationToken;
    heightController.stop();
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

  void _stopTextTransition() {
    _cancelDelayedWidthAnimation();
    _textTransitionController?.stop();
    _textTransitionController = null;
  }

  void _updateDisplayedText(String? value) {
    if (_displayedText == value) {
      return;
    }
    _displayedText = value;
    _notifyChanged();
  }

  _AutoWidthTextFlow _autoWidthTextFlow(double? width, double nextWidth) {
    if (width == null) {
      return _AutoWidthTextFlow.initial;
    }
    if ((width - nextWidth).abs() < 0.5) {
      return _AutoWidthTextFlow.textOnly;
    }
    return nextWidth > width
        ? _AutoWidthTextFlow.growFirst
        : _AutoWidthTextFlow.shrinkLast;
  }

  void _runTextPhase(
    int runId,
    String? targetText, {
    VoidCallback? onComplete,
  }) {
    _stopTextTransition();
    if (!_configuration.textTransition ||
        _configuration.reduceMotion ||
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
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(value);
      },
      onComplete: () {
        _textTransitionController = null;
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(targetText);
        onComplete?.call();
      },
    );
  }

  void _requestAutoWidthMeasurement(int runId, String text) {
    _measurementRequestId = runId;
    _measurementText = text;
    _notifyChanged();
  }

  void _syncAutoWidthTextState() {
    final nextText = _configuration.stringChild;
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
    if (_configuration.canChoreographAutoWidthText) {
      _syncAutoWidthTextState();
      return;
    }
    final measurementText = _configuration.autoWidthMeasurementText;
    if (measurementText != null) {
      _sizeRunId += 1;
      _requestAutoWidthMeasurement(_sizeRunId, measurementText);
    } else {
      _clearMeasurementRequest();
    }
    _syncTextTransitionState();
  }

  void _resolveMeasuredAutoWidth(
    int runId,
    String targetText,
    double nextWidth,
  ) {
    if (_disposed || _sizeRunId != runId) {
      return;
    }
    if (!_configuration.canChoreographAutoWidthText) {
      _setWidthImmediately(nextWidth);
      return;
    }
    final flow = _autoWidthTextFlow(currentWidth, nextWidth);
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
      if (_configuration.textTransition) {
        _animateWidthTo(nextWidth);
        _runTextPhase(runId, targetText);
        return;
      }
      _animateWidthTo(nextWidth, onComplete: () {
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _runTextPhase(runId, targetText);
      });
      return;
    }
    if (_configuration.textTransition) {
      _runTextPhase(runId, targetText);
      _delayedWidthAnimationTimer = Timer(_shrinkWidthAnimationDelay, () {
        _delayedWidthAnimationTimer = null;
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _animateWidthTo(nextWidth);
      });
      return;
    }
    _runTextPhase(runId, targetText, onComplete: () {
      if (_disposed || _sizeRunId != runId) {
        return;
      }
      _animateWidthTo(nextWidth);
    });
  }

  void _syncTextTransitionState() {
    final nextText = _configuration.stringChild;
    final previousTarget = _currentTextTarget;
    final previousDisplayedText = _displayedText;
    final previousText = previousDisplayedText ?? previousTarget;
    if (!_configuration.textTransition ||
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
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(value);
      },
      onComplete: () {
        _textTransitionController = null;
        if (_disposed || _sizeRunId != runId) {
          return;
        }
        _updateDisplayedText(nextText);
      },
    );
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
    _widthAnimationToken += 1;
    _heightAnimationToken += 1;
    _cancelDelayedWidthAnimation();
    _textTransitionController?.stop();
    _textTransitionController = null;
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }
}

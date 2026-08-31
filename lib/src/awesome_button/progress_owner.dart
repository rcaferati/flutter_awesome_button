part of '../awesome_button.dart';

const Duration _progressSwapDuration = Duration(milliseconds: 300);
const Duration _progressFillCompletionDuration = Duration(milliseconds: 120);
const Duration _progressOverlayFadeDuration = Duration(milliseconds: 160);
const Duration _progressOverlayFadeDelay = Duration(milliseconds: 120);
const Curve _progressCompletionCurve = Curves.easeOutCubic;
const Curve _progressSwapCurve = _RnElasticCurve(1.2);

@immutable
class _AwesomeButtonProgressConfiguration {
  const _AwesomeButtonProgressConfiguration({
    required this.loadingTime,
    required this.showProgressBar,
    required this.reduceMotion,
  });

  final Duration loadingTime;
  final bool showProgressBar;
  final bool reduceMotion;
}

@immutable
class _AwesomeButtonProgressPresentation {
  const _AwesomeButtonProgressPresentation({
    required this.busy,
    required this.nextConsumed,
    required this.showVisuals,
    required this.runId,
  });

  final bool busy;
  final bool nextConsumed;
  final bool showVisuals;
  final int runId;
}

sealed class _AwesomeButtonProgressCommand {
  const _AwesomeButtonProgressCommand(this.runId);

  final int runId;
}

final class _ProgressStartedCommand extends _AwesomeButtonProgressCommand {
  const _ProgressStartedCommand(super.runId);
}

final class _ProgressActivateCommand extends _AwesomeButtonProgressCommand {
  const _ProgressActivateCommand(super.runId);
}

final class _ProgressReleaseCommand extends _AwesomeButtonProgressCommand {
  _ProgressReleaseCommand(super.runId, this.completer);

  final Completer<bool> completer;
}

final class _ProgressCallbacksCommand extends _AwesomeButtonProgressCommand {
  const _ProgressCallbacksCommand(
    super.runId,
    this.completion,
    this.onProgressEnd,
  );

  final VoidCallback? completion;
  final VoidCallback? onProgressEnd;
}

class _AwesomeButtonProgressOwner extends ChangeNotifier {
  _AwesomeButtonProgressOwner({
    required TickerProvider vsync,
    required _AwesomeButtonProgressConfiguration initialConfiguration,
  })  : _configuration = initialConfiguration,
        contentTransitionController = AnimationController.unbounded(
          vsync: vsync,
          value: 1,
        ),
        activityTransitionController = AnimationController.unbounded(
          vsync: vsync,
          value: 0,
        ),
        overlayOpacityController = AnimationController(
          vsync: vsync,
          duration: _progressOverlayFadeDuration,
          value: 0,
        ),
        progressController = AnimationController(
          vsync: vsync,
          duration: initialConfiguration.loadingTime,
        );

  final AnimationController contentTransitionController;
  final AnimationController activityTransitionController;
  final AnimationController overlayOpacityController;
  final AnimationController progressController;

  final List<_AwesomeButtonProgressCommand> _commands = [];
  _AwesomeButtonProgressConfiguration _configuration;
  bool _busy = false;
  bool _nextConsumed = false;
  bool _hasPhysicalLifecycle = true;
  bool _showVisuals = false;
  bool _disposed = false;
  int _runId = 0;

  bool get busy => _busy;
  bool get nextConsumed => _nextConsumed;
  int get runId => _runId;
  _AwesomeButtonProgressPresentation get presentation =>
      _AwesomeButtonProgressPresentation(
        busy: _busy,
        nextConsumed: _nextConsumed,
        showVisuals: _showVisuals,
        runId: _runId,
      );

  bool ownsGeneration(int candidate) => !_disposed && candidate == _runId;

  bool isCurrent(int candidate) => ownsGeneration(candidate) && _busy;

  List<_AwesomeButtonProgressCommand> drainCommands() {
    final drained = List<_AwesomeButtonProgressCommand>.of(_commands);
    _commands.clear();
    return drained;
  }

  void updateConfiguration(_AwesomeButtonProgressConfiguration current) {
    if (_disposed) {
      return;
    }
    final motionChanged = _configuration.reduceMotion != current.reduceMotion;
    _configuration = current;
    progressController.duration = current.loadingTime;
    if (motionChanged && current.reduceMotion) {
      settleForReducedMotion();
    }
  }

  bool start({required bool physicalLifecycle}) {
    if (_disposed || _busy) {
      return false;
    }
    _runId += 1;
    _busy = true;
    _nextConsumed = false;
    _hasPhysicalLifecycle = physicalLifecycle;
    _showVisuals = true;
    _resetVisualState(unmount: false);
    progressController.duration = _configuration.loadingTime;
    overlayOpacityController.value = _configuration.showProgressBar ? 1 : 0;
    _enqueue(_ProgressStartedCommand(_runId));
    return true;
  }

  void continueAfterStart(int candidate) {
    if (!isCurrent(candidate)) {
      return;
    }
    _animateSwapIn();
    if (_configuration.reduceMotion) {
      progressController.value = _configuration.showProgressBar ? 1 : 0;
    } else {
      progressController.forward();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isCurrent(candidate)) {
        return;
      }
      _enqueue(_ProgressActivateCommand(candidate));
    });
  }

  void acceptNext(
    int candidate,
    VoidCallback? completion,
    VoidCallback? onProgressEndSnapshot,
  ) {
    if (!isCurrent(candidate) || _nextConsumed) {
      return;
    }
    _nextConsumed = true;
    Future<void>.microtask(
      () => _complete(candidate, completion, onProgressEndSnapshot),
    );
  }

  void abort(int candidate, VoidCallback? onProgressEndSnapshot) {
    if (!isCurrent(candidate) || _nextConsumed) {
      return;
    }
    _nextConsumed = true;
    progressController.stop();
    contentTransitionController.stop();
    activityTransitionController.stop();
    overlayOpacityController.stop();
    unawaited(_finishRollback(candidate, onProgressEndSnapshot));
  }

  void settleForReducedMotion() {
    if (_disposed || !_configuration.reduceMotion) {
      return;
    }
    contentTransitionController.stop();
    activityTransitionController.stop();
    progressController.stop();
    overlayOpacityController.stop();
    if (_busy) {
      contentTransitionController.value = 0;
      activityTransitionController.value = 1;
      progressController.value = _configuration.showProgressBar ? 1 : 0;
      overlayOpacityController.value = _configuration.showProgressBar ? 1 : 0;
    }
  }

  Future<void> _complete(
    int candidate,
    VoidCallback? completion,
    VoidCallback? onProgressEndSnapshot,
  ) async {
    if (!isCurrent(candidate)) {
      return;
    }
    try {
      if (!_configuration.reduceMotion && progressController.value < 1) {
        await progressController.animateTo(
          1,
          duration: _progressFillCompletionDuration,
          curve: _progressCompletionCurve,
        );
      }
    } on TickerCanceled {
      return;
    }
    if (!isCurrent(candidate)) {
      return;
    }
    await _animateSwapOut();
    if (!isCurrent(candidate)) {
      return;
    }
    if (_hasPhysicalLifecycle) {
      final released = await _requestRelease(candidate);
      if (!released || !isCurrent(candidate)) {
        return;
      }
    }
    if (!isCurrent(candidate)) {
      return;
    }
    _busy = false;
    _showVisuals = false;
    _resetVisualState(unmount: false);
    _enqueue(
      _ProgressCallbacksCommand(
        candidate,
        completion,
        onProgressEndSnapshot,
      ),
    );
  }

  Future<void> _finishRollback(
    int candidate,
    VoidCallback? onProgressEndSnapshot,
  ) async {
    if (_hasPhysicalLifecycle) {
      final released = await _requestRelease(candidate);
      if (!released || !isCurrent(candidate)) {
        return;
      }
    }
    if (!isCurrent(candidate)) {
      return;
    }
    _busy = false;
    _showVisuals = false;
    _resetVisualState();
    _enqueue(_ProgressCallbacksCommand(candidate, null, onProgressEndSnapshot));
  }

  Future<bool> _requestRelease(int candidate) {
    if (!isCurrent(candidate)) {
      return Future<bool>.value(false);
    }
    final completer = Completer<bool>();
    _enqueue(_ProgressReleaseCommand(candidate, completer));
    return completer.future;
  }

  void _resetVisualState({bool unmount = true}) {
    contentTransitionController
      ..stop()
      ..value = 1;
    activityTransitionController
      ..stop()
      ..value = 0;
    overlayOpacityController
      ..stop()
      ..value = 0;
    progressController
      ..stop()
      ..value = 0;
    if (unmount) {
      _showVisuals = false;
    }
  }

  void _animateSwapIn() {
    if (_configuration.reduceMotion) {
      contentTransitionController.value = 0;
      activityTransitionController.value = 1;
      return;
    }
    contentTransitionController
      ..stop()
      ..animateTo(
        0,
        duration: _progressSwapDuration,
        curve: _progressSwapCurve,
      );
    activityTransitionController
      ..stop()
      ..animateTo(
        1,
        duration: _progressSwapDuration,
        curve: _progressSwapCurve,
      );
  }

  Future<void> _animateSwapOut() async {
    if (_configuration.reduceMotion) {
      contentTransitionController.value = 1;
      activityTransitionController.value = 0;
      overlayOpacityController.value = 0;
      return;
    }
    try {
      await Future.wait<void>([
        contentTransitionController.animateTo(
          1,
          duration: _progressSwapDuration,
          curve: _progressSwapCurve,
        ),
        activityTransitionController.animateTo(
          0,
          duration: _progressSwapDuration,
          curve: _progressSwapCurve,
        ),
        _fadeOutOverlay(),
      ]);
    } on TickerCanceled {
      return;
    }
  }

  Future<void> _fadeOutOverlay() async {
    try {
      const delay = _progressOverlayFadeDelay;
      const fade = _progressOverlayFadeDuration;
      await overlayOpacityController.animateTo(
        0,
        duration: Duration(
          milliseconds: delay.inMilliseconds + fade.inMilliseconds,
        ),
        curve: Interval(
          delay.inMilliseconds / (delay.inMilliseconds + fade.inMilliseconds),
          1,
          curve: _progressCompletionCurve,
        ),
      );
    } on TickerCanceled {
      return;
    }
  }

  void _enqueue(_AwesomeButtonProgressCommand command) {
    if (_disposed) {
      if (command is _ProgressReleaseCommand &&
          !command.completer.isCompleted) {
        command.completer.complete(false);
      }
      return;
    }
    _commands.add(command);
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _runId += 1;
    _busy = false;
    for (final command in _commands) {
      if (command is _ProgressReleaseCommand &&
          !command.completer.isCompleted) {
        command.completer.complete(false);
      }
    }
    _commands.clear();
    contentTransitionController.dispose();
    activityTransitionController.dispose();
    overlayOpacityController.dispose();
    progressController.dispose();
    super.dispose();
  }
}

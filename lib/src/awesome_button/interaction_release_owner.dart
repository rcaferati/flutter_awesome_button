part of '../awesome_button.dart';

const double _releaseSpringTension = 100;
const double _releaseSpringFriction = 6.75;
final SpringDescription _releaseSpring = SpringDescription(
  mass: 1,
  stiffness: _origamiTensionToStiffness(_releaseSpringTension),
  damping: _origamiFrictionToDamping(_releaseSpringFriction),
);

@immutable
class _AwesomeButtonInteractionConfiguration {
  const _AwesomeButtonInteractionConfiguration({
    required this.pressAnimationDuration,
    required this.pressAnimationCurve,
    required this.debounceDuration,
    required this.reduceMotion,
  });

  final Duration pressAnimationDuration;
  final Curve pressAnimationCurve;
  final Duration debounceDuration;
  final bool reduceMotion;
}

@immutable
class _AwesomeButtonTerminal {
  const _AwesomeButtonTerminal({
    required this.gestureId,
    required this.wasLongPress,
  });

  final int gestureId;
  final bool wasLongPress;
}

@immutable
class _AwesomeButtonInteractionPresentation {
  const _AwesomeButtonInteractionPresentation({
    required this.pressArmed,
    required this.gestureId,
  });

  final bool pressArmed;
  final int gestureId;
}

sealed class _AwesomeButtonInteractionCommand {
  const _AwesomeButtonInteractionCommand();
}

final class _LongPressDueCommand extends _AwesomeButtonInteractionCommand {
  const _LongPressDueCommand(this.gestureId);

  final int gestureId;
}

final class _ReleaseSettledCommand extends _AwesomeButtonInteractionCommand {
  const _ReleaseSettledCommand(
    this.releaseId,
    this.callback,
    this.completer,
  );

  final int releaseId;
  final VoidCallback? callback;
  final Completer<bool> completer;
}

class _AwesomeButtonInteractionReleaseOwner extends ChangeNotifier {
  _AwesomeButtonInteractionReleaseOwner({
    required TickerProvider vsync,
    required _AwesomeButtonInteractionConfiguration initialConfiguration,
  })  : _configuration = initialConfiguration,
        pressController = AnimationController.unbounded(
          vsync: vsync,
          value: 0,
        );

  final AnimationController pressController;
  final List<_AwesomeButtonInteractionCommand> _commands = [];
  _AwesomeButtonInteractionConfiguration _configuration;
  Timer? _debounceResetTimer;
  Timer? _longPressTimer;
  bool _pressArmed = false;
  bool _longPressArmed = false;
  bool _longPressDisarmed = false;
  bool _longPressDispatched = false;
  bool _debounceActive = false;
  bool _releaseInProgress = false;
  bool _disposed = false;
  int _gestureId = 0;
  int _releaseId = 0;
  Completer<bool>? _releaseCompleter;
  VoidCallback? _releaseCallback;

  _AwesomeButtonInteractionPresentation get presentation =>
      _AwesomeButtonInteractionPresentation(
        pressArmed: _pressArmed,
        gestureId: _gestureId,
      );

  bool ownsGesture(int candidate) =>
      !_disposed && _pressArmed && candidate == _gestureId;

  bool ownsRelease(int candidate) =>
      !_disposed && _releaseInProgress && candidate == _releaseId;

  bool ownsReleaseGeneration(int candidate) =>
      !_disposed && candidate == _releaseId;

  List<_AwesomeButtonInteractionCommand> drainCommands() {
    final drained = List<_AwesomeButtonInteractionCommand>.of(_commands);
    _commands.clear();
    return drained;
  }

  void updateConfiguration(_AwesomeButtonInteractionConfiguration current) {
    if (_disposed) {
      return;
    }
    final motionChanged = _configuration.reduceMotion != current.reduceMotion;
    _configuration = current;
    if (motionChanged && current.reduceMotion) {
      settleForReducedMotion();
    }
  }

  void setReduceMotion(bool reduceMotion) {
    updateConfiguration(
      _AwesomeButtonInteractionConfiguration(
        pressAnimationDuration: _configuration.pressAnimationDuration,
        pressAnimationCurve: _configuration.pressAnimationCurve,
        debounceDuration: _configuration.debounceDuration,
        reduceMotion: reduceMotion,
      ),
    );
  }

  int? beginPointer({
    required int buttons,
    required bool eligible,
    required bool hasLongPress,
  }) {
    if (_disposed || buttons != kPrimaryButton || !eligible || _pressArmed) {
      return null;
    }
    _gestureId += 1;
    _pressArmed = true;
    _longPressArmed = hasLongPress;
    _longPressDisarmed = !hasLongPress;
    _longPressDispatched = false;
    return _gestureId;
  }

  void beginVisualsAndLongPress(int candidate) {
    if (!ownsGesture(candidate)) {
      return;
    }
    _cancelReleaseForNewGesture();
    _animatePressIn();
    if (!_longPressArmed) {
      return;
    }
    _longPressTimer?.cancel();
    _longPressTimer = Timer(kLongPressTimeout, () {
      _longPressTimer = null;
      if (!ownsGesture(candidate) || !_longPressArmed || _longPressDisarmed) {
        return;
      }
      _enqueue(_LongPressDueCommand(candidate));
    });
  }

  void markLongPressDispatched(int candidate) {
    if (ownsGesture(candidate) && _longPressArmed && !_longPressDisarmed) {
      _longPressDispatched = true;
    }
  }

  void disarmLongPress() {
    _longPressArmed = false;
    _longPressDisarmed = true;
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  _AwesomeButtonTerminal? claimTerminal() {
    if (_disposed || !_pressArmed) {
      return null;
    }
    final terminal = _AwesomeButtonTerminal(
      gestureId: _gestureId,
      wasLongPress: _longPressDispatched,
    );
    _pressArmed = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _longPressArmed = false;
    _longPressDisarmed = false;
    _longPressDispatched = false;
    return terminal;
  }

  _AwesomeButtonTerminal? cancelPointer() {
    final terminal = claimTerminal();
    if (terminal != null) {
      _gestureId += 1;
    }
    return terminal;
  }

  bool consumeDebounce() {
    final duration = _configuration.debounceDuration;
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

  void resetForAtomicActivation() {
    if (_disposed) {
      return;
    }
    pressController.stop();
    pressController.value = 0;
  }

  Future<bool> release(VoidCallback? callbackSnapshot) {
    if (_disposed) {
      return Future<bool>.value(false);
    }
    if (_releaseInProgress) {
      return _releaseCompleter?.future ?? Future<bool>.value(false);
    }
    _releaseInProgress = true;
    _releaseId += 1;
    _releaseCallback = callbackSnapshot;
    _releaseCompleter = Completer<bool>();
    final result = _releaseCompleter!;
    pressController.stop();
    if (_configuration.reduceMotion) {
      pressController.value = 0;
      _finishRelease(_releaseId);
      return result.future;
    }
    final candidate = _releaseId;
    pressController
        .animateWith(
          SpringSimulation(
            _releaseSpring,
            pressController.value,
            0,
            0,
          ),
        )
        .orCancel
        .then((_) {
      if (!ownsRelease(candidate)) {
        return;
      }
      pressController.value = 0;
      _finishRelease(candidate);
    }).catchError((Object _) {
      if (ownsRelease(candidate)) {
        _cancelRelease(candidate);
      }
      return;
    }, test: (error) => error is TickerCanceled);
    return result.future;
  }

  void settleForReducedMotion() {
    if (_disposed || !_configuration.reduceMotion) {
      return;
    }
    pressController.stop();
    if (_releaseInProgress) {
      pressController.value = 0;
      _finishRelease(_releaseId);
    } else {
      pressController.value = _pressArmed ? 1 : 0;
    }
  }

  void _animatePressIn() {
    pressController.stop();
    if (_configuration.reduceMotion ||
        _configuration.pressAnimationDuration == Duration.zero) {
      pressController.value = 1;
      return;
    }
    pressController
        .animateTo(
          1,
          duration: _configuration.pressAnimationDuration,
          curve: _configuration.pressAnimationCurve,
        )
        .orCancel
        .catchError((Object _) {
      return;
    }, test: (error) => error is TickerCanceled);
  }

  void _finishRelease(int candidate) {
    if (!ownsRelease(candidate)) {
      return;
    }
    final callback = _releaseCallback;
    final completer = _releaseCompleter!;
    _releaseInProgress = false;
    _releaseCallback = null;
    _releaseCompleter = null;
    _enqueue(_ReleaseSettledCommand(candidate, callback, completer));
  }

  void _cancelReleaseForNewGesture() {
    if (!_releaseInProgress) {
      return;
    }
    final candidate = _releaseId;
    pressController.stop();
    _cancelRelease(candidate);
  }

  void _cancelRelease(int candidate) {
    if (candidate != _releaseId) {
      return;
    }
    final completer = _releaseCompleter;
    _releaseInProgress = false;
    _releaseCallback = null;
    _releaseCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
  }

  void _enqueue(_AwesomeButtonInteractionCommand command) {
    if (_disposed) {
      if (command is _ReleaseSettledCommand && !command.completer.isCompleted) {
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
    _gestureId += 1;
    _releaseId += 1;
    _pressArmed = false;
    _longPressTimer?.cancel();
    _debounceResetTimer?.cancel();
    final pendingRelease = _releaseCompleter;
    _releaseCompleter = null;
    _releaseCallback = null;
    if (pendingRelease != null && !pendingRelease.isCompleted) {
      pendingRelease.complete(false);
    }
    for (final command in _commands) {
      if (command is _ReleaseSettledCommand && !command.completer.isCompleted) {
        command.completer.complete(false);
      }
    }
    _commands.clear();
    pressController.dispose();
    super.dispose();
  }
}

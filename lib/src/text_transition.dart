import 'dart:math' as math;

import 'package:flutter/scheduler.dart';

/// Delay between source-character randomization starts.
const int textTransitionRandomizeStartStaggerMs = 5;

/// Delay between new target-character expansion starts.
const int textTransitionExpandStaggerMs = 5;

/// Hold time after full randomization before collapse begins.
const int textTransitionPostRandomizeHoldMs = 10;

/// Delay between left-to-right collapse steps.
const int textTransitionCollapseStaggerMs = 10;

/// Approximate refresh interval used for frame-driven updates.
const int textTransitionRefreshMs = 16;

const String _lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
const String _uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String _digits = '0123456789';
const String _symbols = '#%&^+=-';

/// Callback that receives the currently rendered transition string.
typedef TextTransitionUpdate = void Function(String value);

/// Random source used to generate scrambled transition characters.
typedef TextTransitionRandom = double Function();

final math.Random _defaultTextTransitionRandomizer = math.Random();

double _defaultTextTransitionRandom() =>
    _defaultTextTransitionRandomizer.nextDouble();

/// Timing breakdown for a text transition from one string to another.
class TextTransitionTimeline {
  /// Creates a transition timeline.
  const TextTransitionTimeline({
    required this.sourceLength,
    required this.targetLength,
    required this.maxLength,
    required this.lastSourceRandomizeStartMs,
    required this.lastRandomizeStartMs,
    required this.collapseStartMs,
    required this.totalDurationMs,
  });

  /// Length of the source string.
  final int sourceLength;

  /// Length of the target string.
  final int targetLength;

  /// Longest string length used during the transition.
  final int maxLength;

  /// Last stagger time for source-character randomization.
  final int lastSourceRandomizeStartMs;

  /// Last stagger time for any randomization step.
  final int lastRandomizeStartMs;

  /// Time at which collapse into the target text begins.
  final int collapseStartMs;

  /// Total transition duration.
  final int totalDurationMs;
}

/// Handle returned by [runTextTransition].
abstract class TextTransitionController {
  /// Stops the current transition and cancels future frame updates.
  void stop();
}

/// Returns the time at which a given slot starts scrambling.
int? getTextTransitionRandomizeStartMs(
  int index,
  int sourceLength,
  int targetLength,
) {
  if (index < sourceLength) {
    return index * textTransitionRandomizeStartStaggerMs;
  }

  if (index < targetLength) {
    final lastSourceStartMs = sourceLength > 0
        ? (sourceLength - 1) * textTransitionRandomizeStartStaggerMs
        : 0;

    return lastSourceStartMs +
        (index - sourceLength + 1) * textTransitionExpandStaggerMs;
  }

  return null;
}

/// Builds the timeline used to animate from [fromText] to [targetText].
TextTransitionTimeline getTextTransitionTimeline(
  String fromText,
  String targetText,
) {
  final sourceLength = fromText.length;
  final targetLength = targetText.length;
  final maxLength = math.max(sourceLength, targetLength);
  final lastSourceRandomizeStartMs = sourceLength > 0
      ? (sourceLength - 1) * textTransitionRandomizeStartStaggerMs
      : 0;
  final lastRandomizeStartMs = maxLength == 0
      ? 0
      : (getTextTransitionRandomizeStartMs(
            maxLength - 1,
            sourceLength,
            targetLength,
          ) ??
          0);
  final collapseStartMs =
      lastRandomizeStartMs + textTransitionPostRandomizeHoldMs;
  final totalDurationMs = maxLength == 0
      ? 0
      : collapseStartMs + (maxLength - 1) * textTransitionCollapseStaggerMs;

  return TextTransitionTimeline(
    sourceLength: sourceLength,
    targetLength: targetLength,
    maxLength: maxLength,
    lastSourceRandomizeStartMs: lastSourceRandomizeStartMs,
    lastRandomizeStartMs: lastRandomizeStartMs,
    collapseStartMs: collapseStartMs,
    totalDurationMs: totalDurationMs,
  );
}

/// Returns the randomization character set appropriate for [character].
String? getTextTransitionCharset(String character) {
  if (RegExp(r'\s').hasMatch(character)) {
    return null;
  }

  if (RegExp(r'\d').hasMatch(character)) {
    return _digits;
  }

  if (character.toUpperCase() == character &&
      character.toLowerCase() != character) {
    return _uppercaseLetters;
  }

  if (character.toLowerCase() == character &&
      character.toUpperCase() != character) {
    return _lowercaseLetters;
  }

  return _symbols;
}

/// Returns a scrambled replacement character compatible with [character].
String getRandomTransitionCharacter(
  String character, [
  TextTransitionRandom random = _defaultTextTransitionRandom,
]) {
  final charset = getTextTransitionCharset(character);

  if (charset == null) {
    return character;
  }

  final index = math.min(
    charset.length - 1,
    (random() * charset.length).floor(),
  );

  return charset[index];
}

/// Builds the visible transition frame for a given elapsed time.
String buildTextTransitionFrame(
  String fromText,
  String targetText,
  int elapsedMs, [
  TextTransitionRandom random = _defaultTextTransitionRandom,
]) {
  if (fromText.isEmpty) {
    return targetText;
  }

  if (fromText == targetText) {
    return targetText;
  }

  final timeline = getTextTransitionTimeline(fromText, targetText);

  if (elapsedMs >= timeline.totalDurationMs) {
    return targetText;
  }

  return List<String>.generate(timeline.maxLength, (index) {
    final randomizeStartMs = getTextTransitionRandomizeStartMs(
      index,
      timeline.sourceLength,
      timeline.targetLength,
    );
    final collapseMs =
        timeline.collapseStartMs + index * textTransitionCollapseStaggerMs;
    final sourceCharacter = index < fromText.length ? fromText[index] : '';
    final targetCharacter = index < targetText.length ? targetText[index] : '';
    final randomSourceCharacter =
        index >= timeline.sourceLength ? targetCharacter : sourceCharacter;

    if (randomizeStartMs == null || elapsedMs < randomizeStartMs) {
      return sourceCharacter;
    }

    if (elapsedMs >= collapseMs) {
      return targetCharacter;
    }

    return getRandomTransitionCharacter(randomSourceCharacter, random);
  }).join();
}

/// Runs the frame-driven text transition and returns a controller handle.
TextTransitionController runTextTransition({
  required String fromText,
  required String targetText,
  required TextTransitionUpdate onUpdate,
  VoidCallback? onComplete,
  TextTransitionRandom random = _defaultTextTransitionRandom,
}) {
  final timeline = getTextTransitionTimeline(fromText, targetText);

  if (fromText.isEmpty || targetText.isEmpty || fromText == targetText) {
    onUpdate(targetText);
    onComplete?.call();
    return const _NoopTextTransitionController();
  }

  return _FrameTextTransitionController(
    timeline: timeline,
    fromText: fromText,
    targetText: targetText,
    onUpdate: onUpdate,
    onComplete: onComplete,
    random: random,
  )..start();
}

class _FrameTextTransitionController implements TextTransitionController {
  _FrameTextTransitionController({
    required this.timeline,
    required this.fromText,
    required this.targetText,
    required this.onUpdate,
    required this.onComplete,
    required this.random,
  });

  final TextTransitionTimeline timeline;
  final String fromText;
  final String targetText;
  final TextTransitionUpdate onUpdate;
  final VoidCallback? onComplete;
  final TextTransitionRandom random;

  int? _frameCallbackId;
  Duration? _startTimestamp;
  String? _lastPublishedValue;
  bool _stopped = false;

  void start() {
    _scheduleNextFrame();
  }

  @override
  void stop() {
    _stopped = true;
    final callbackId = _frameCallbackId;
    if (callbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(callbackId);
      _frameCallbackId = null;
    }
  }

  void _scheduleNextFrame() {
    if (_stopped) {
      return;
    }

    SchedulerBinding.instance.ensureVisualUpdate();
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _tick(Duration timestamp) {
    if (_stopped) {
      return;
    }

    _startTimestamp ??= timestamp;
    final elapsedMs = math.min(
      timeline.totalDurationMs,
      (timestamp - _startTimestamp!).inMilliseconds,
    );
    final nextValue = buildTextTransitionFrame(
      fromText,
      targetText,
      elapsedMs,
      random,
    );

    if (nextValue != _lastPublishedValue) {
      _lastPublishedValue = nextValue;
      onUpdate(nextValue);
    }

    if (elapsedMs >= timeline.totalDurationMs) {
      _frameCallbackId = null;
      onComplete?.call();
      return;
    }

    _scheduleNextFrame();
  }
}

class _NoopTextTransitionController implements TextTransitionController {
  const _NoopTextTransitionController();

  @override
  void stop() {}
}

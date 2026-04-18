import 'dart:math' as math;

import 'package:flutter/scheduler.dart';

const int textTransitionRandomizeStartStaggerMs = 5;
const int textTransitionExpandStaggerMs = 5;
const int textTransitionPostRandomizeHoldMs = 10;
const int textTransitionCollapseStaggerMs = 10;
const int textTransitionRefreshMs = 16;

const String _lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
const String _uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String _digits = '0123456789';
const String _symbols = '#%&^+=-';

typedef TextTransitionUpdate = void Function(String value);
typedef TextTransitionRandom = double Function();

final math.Random _defaultTextTransitionRandomizer = math.Random();

double _defaultTextTransitionRandom() =>
    _defaultTextTransitionRandomizer.nextDouble();

class TextTransitionTimeline {
  const TextTransitionTimeline({
    required this.sourceLength,
    required this.targetLength,
    required this.maxLength,
    required this.lastSourceRandomizeStartMs,
    required this.lastRandomizeStartMs,
    required this.collapseStartMs,
    required this.totalDurationMs,
  });

  final int sourceLength;
  final int targetLength;
  final int maxLength;
  final int lastSourceRandomizeStartMs;
  final int lastRandomizeStartMs;
  final int collapseStartMs;
  final int totalDurationMs;
}

abstract class TextTransitionController {
  void stop();
}

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

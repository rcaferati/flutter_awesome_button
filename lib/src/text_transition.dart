import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
// Flutter publicly re-exports the grapheme extension from widgets.dart.
import 'package:flutter/widgets.dart' show StringCharacters;

/// Delay between transition-slot starts.
const int textTransitionSlotStaggerMs = 7;

/// Compatibility name for the source-slot stagger.
const int textTransitionRandomizeStartStaggerMs = textTransitionSlotStaggerMs;

/// Compatibility name for the introduced-slot stagger.
const int textTransitionExpandStaggerMs = textTransitionSlotStaggerMs;

/// Hold time after full randomization before collapse begins.
const int textTransitionPostRandomizeHoldMs = 10;

/// Compatibility name for the target-collapse stagger.
const int textTransitionCollapseStaggerMs = textTransitionSlotStaggerMs;

/// Approximate refresh interval used only by tests and documentation.
///
/// Production updates are driven by the native frame clock rather than an
/// interval timer.
const int textTransitionRefreshMs = 16;

const String _lowercaseNarrowLetters = 'iljtfr';
const String _lowercaseAverageLetters = 'acesuvxznhok';
const String _lowercaseWideLetters = 'mwdbpqgy';
const String _uppercaseNarrowLetters = 'ILJTFR';
const String _uppercaseAverageLetters = 'ACESUVXZNHOK';
const String _uppercaseWideLetters = 'MWDBPQGY';
const String _digits = '0123456789';
const String _symbols = '#%&^+=-';

/// Callback that receives a candidate transition string.
typedef TextTransitionUpdate = void Function(String value);

/// Callback that receives monotonic elapsed transition time.
typedef TextTransitionTick = void Function(
  int elapsedMs,
  TextTransitionTimeline timeline,
);

/// Random source used to generate scrambled transition characters.
typedef TextTransitionRandom = double Function();

final math.Random _defaultTextTransitionRandomizer = math.Random();

double _defaultTextTransitionRandom() =>
    _defaultTextTransitionRandomizer.nextDouble();

int _normalizedSlotStagger(int value) => math.max(0, value);

List<String> _graphemes(String value) => value.characters.toList(
      growable: false,
    );

/// Timing breakdown for a text transition from one string to another.
class TextTransitionTimeline {
  /// Creates a transition timeline.
  const TextTransitionTimeline({
    required this.sourceLength,
    required this.targetLength,
    required this.maxLength,
    required this.slotStaggerMs,
    required this.lastSourceRandomizeStartMs,
    required this.lastRandomizeStartMs,
    required this.collapseStartMs,
    required this.totalDurationMs,
  });

  /// Number of source grapheme clusters.
  final int sourceLength;

  /// Number of target grapheme clusters.
  final int targetLength;

  /// Longest grapheme-cluster count used during the transition.
  final int maxLength;

  /// Normalized delay between logical transition slots.
  final int slotStaggerMs;

  /// Last stagger time for source-slot randomization.
  final int lastSourceRandomizeStartMs;

  /// Last stagger time for any randomization step.
  final int lastRandomizeStartMs;

  /// Time at which collapse into the target text begins.
  final int collapseStartMs;

  /// Complete text-transition duration.
  final int totalDurationMs;
}

/// Handle returned by [runTextTransition].
abstract class TextTransitionController {
  /// Stops the current transition and cancels future frame updates.
  void stop();
}

/// Returns the time at which a logical slot starts scrambling.
int? getTextTransitionRandomizeStartMs(
  int index,
  int sourceLength,
  int targetLength, {
  int slotStaggerMs = textTransitionSlotStaggerMs,
}) {
  final maxLength = math.max(sourceLength, targetLength);
  if (index < 0 || index >= maxLength) {
    return null;
  }
  return index * _normalizedSlotStagger(slotStaggerMs);
}

/// Builds the timeline used to animate from [fromText] to [targetText].
TextTransitionTimeline getTextTransitionTimeline(
  String fromText,
  String targetText, {
  int slotStaggerMs = textTransitionSlotStaggerMs,
}) {
  final sourceLength = fromText.characters.length;
  final targetLength = targetText.characters.length;
  final maxLength = math.max(sourceLength, targetLength);
  final stagger = _normalizedSlotStagger(slotStaggerMs);
  final lastSourceRandomizeStartMs =
      sourceLength > 0 ? (sourceLength - 1) * stagger : 0;
  final lastRandomizeStartMs = maxLength > 0 ? (maxLength - 1) * stagger : 0;
  final collapseStartMs =
      lastRandomizeStartMs + textTransitionPostRandomizeHoldMs;
  final totalDurationMs =
      maxLength == 0 ? 0 : collapseStartMs + (maxLength - 1) * stagger;

  return TextTransitionTimeline(
    sourceLength: sourceLength,
    targetLength: targetLength,
    maxLength: maxLength,
    slotStaggerMs: stagger,
    lastSourceRandomizeStartMs: lastSourceRandomizeStartMs,
    lastRandomizeStartMs: lastRandomizeStartMs,
    collapseStartMs: collapseStartMs,
    totalDurationMs: totalDurationMs,
  );
}

bool _isWhitespace(String grapheme) =>
    grapheme.isNotEmpty && RegExp(r'^\s+$', unicode: true).hasMatch(grapheme);

/// Returns the canonical randomization pool for [character].
///
/// Unsupported grapheme clusters return null and therefore remain unchanged.
String? getTextTransitionCharset(String character) {
  if (_isWhitespace(character)) {
    return null;
  }
  if (character.length != 1) {
    return null;
  }
  if (_digits.contains(character)) {
    return _digits;
  }
  if (_symbols.contains(character)) {
    return _symbols;
  }
  if (_lowercaseNarrowLetters.contains(character)) {
    return _lowercaseNarrowLetters;
  }
  if (_lowercaseAverageLetters.contains(character)) {
    return _lowercaseAverageLetters;
  }
  if (_lowercaseWideLetters.contains(character)) {
    return _lowercaseWideLetters;
  }
  if (_uppercaseNarrowLetters.contains(character)) {
    return _uppercaseNarrowLetters;
  }
  if (_uppercaseAverageLetters.contains(character)) {
    return _uppercaseAverageLetters;
  }
  if (_uppercaseWideLetters.contains(character)) {
    return _uppercaseWideLetters;
  }
  return null;
}

/// Returns a scrambled replacement grapheme compatible with [character].
String getRandomTransitionCharacter(
  String character, [
  TextTransitionRandom random = _defaultTextTransitionRandom,
]) {
  final charset = getTextTransitionCharset(character);
  if (charset == null) {
    return character;
  }

  final graphemes = _graphemes(charset);
  final index = math.min(
    graphemes.length - 1,
    math.max(0, (random() * graphemes.length).floor()),
  );
  return graphemes[index];
}

int _collapseOrder(int index, TextTransitionTimeline timeline) {
  if (timeline.targetLength >= timeline.sourceLength) {
    return index;
  }
  if (index >= timeline.targetLength) {
    return timeline.sourceLength - 1 - index;
  }
  return timeline.sourceLength - timeline.targetLength + index;
}

String _buildTextTransitionFrame(
  List<String> source,
  List<String> target,
  TextTransitionTimeline timeline,
  int elapsedMs,
  TextTransitionRandom random,
) {
  if (source.isEmpty || source.join() == target.join()) {
    return target.join();
  }

  final elapsed = math.max(0, elapsedMs);
  if (elapsed >= timeline.totalDurationMs) {
    return target.join();
  }

  return List<String>.generate(timeline.maxLength, (index) {
    final randomizeStartMs = index * timeline.slotStaggerMs;
    final collapseMs = timeline.collapseStartMs +
        _collapseOrder(index, timeline) * timeline.slotStaggerMs;
    final sourceCharacter = index < source.length ? source[index] : '';
    final targetCharacter = index < target.length ? target[index] : '';
    final randomSourceCharacter =
        index < source.length ? sourceCharacter : targetCharacter;

    if (elapsed < randomizeStartMs) {
      return sourceCharacter;
    }
    if (elapsed >= collapseMs) {
      return targetCharacter;
    }
    return getRandomTransitionCharacter(randomSourceCharacter, random);
  }).join();
}

/// Builds the visible transition frame for a given elapsed time.
String buildTextTransitionFrame(
  String fromText,
  String targetText,
  int elapsedMs, [
  TextTransitionRandom random = _defaultTextTransitionRandom,
]) {
  final source = _graphemes(fromText);
  final target = _graphemes(targetText);
  return _buildTextTransitionFrame(
    source,
    target,
    getTextTransitionTimeline(fromText, targetText),
    elapsedMs,
    random,
  );
}

/// Builds a frame with an explicit stagger for deterministic contract tests.
String buildTextTransitionFrameWithStagger({
  required String fromText,
  required String targetText,
  required int elapsedMs,
  required int slotStaggerMs,
  TextTransitionRandom random = _defaultTextTransitionRandom,
}) {
  final source = _graphemes(fromText);
  final target = _graphemes(targetText);
  return _buildTextTransitionFrame(
    source,
    target,
    getTextTransitionTimeline(
      fromText,
      targetText,
      slotStaggerMs: slotStaggerMs,
    ),
    elapsedMs,
    random,
  );
}

/// Runs the frame-driven text transition and returns a controller handle.
TextTransitionController runTextTransition({
  required String fromText,
  required String targetText,
  required TextTransitionUpdate onUpdate,
  VoidCallback? onComplete,
  TextTransitionTick? onTick,
  TextTransitionRandom random = _defaultTextTransitionRandom,
  int slotStaggerMs = textTransitionSlotStaggerMs,
}) {
  final source = _graphemes(fromText);
  final target = _graphemes(targetText);
  final timeline = getTextTransitionTimeline(
    fromText,
    targetText,
    slotStaggerMs: slotStaggerMs,
  );

  if (source.isEmpty || target.isEmpty || fromText == targetText) {
    onUpdate(targetText);
    onComplete?.call();
    return const _NoopTextTransitionController();
  }

  return _FrameTextTransitionController(
    timeline: timeline,
    source: source,
    target: target,
    onUpdate: onUpdate,
    onComplete: onComplete,
    onTick: onTick,
    random: random,
  )..start();
}

class _FrameTextTransitionController implements TextTransitionController {
  _FrameTextTransitionController({
    required this.timeline,
    required this.source,
    required this.target,
    required this.onUpdate,
    required this.onComplete,
    required this.onTick,
    required this.random,
  });

  final TextTransitionTimeline timeline;
  final List<String> source;
  final List<String> target;
  final TextTransitionUpdate onUpdate;
  final VoidCallback? onComplete;
  final TextTransitionTick? onTick;
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
    onTick?.call(elapsedMs, timeline);
    if (_stopped) {
      return;
    }

    final nextValue = _buildTextTransitionFrame(
      source,
      target,
      timeline,
      elapsedMs,
      random,
    );
    if (nextValue != _lastPublishedValue) {
      _lastPublishedValue = nextValue;
      onUpdate(nextValue);
    }

    if (_stopped) {
      return;
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

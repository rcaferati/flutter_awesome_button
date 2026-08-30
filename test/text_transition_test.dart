import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_test/flutter_test.dart';
import 'package:rcaferati_flutter_awesome_button/src/text_transition.dart';

void main() {
  test('canonical Latin pools cover every ASCII letter exactly once', () {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    final lowerPools = <String>{};
    final upperPools = <String>{};
    for (final letter in lowercase.characters) {
      final pool = getTextTransitionCharset(letter);
      expect(pool, isNotNull, reason: 'missing lowercase pool for $letter');
      lowerPools.add(pool!);
    }
    for (final letter in uppercase.characters) {
      final pool = getTextTransitionCharset(letter);
      expect(pool, isNotNull, reason: 'missing uppercase pool for $letter');
      upperPools.add(pool!);
    }

    final lowerCoverage = lowerPools.expand((pool) => pool.characters).toList();
    final upperCoverage = upperPools.expand((pool) => pool.characters).toList();
    expect(lowerCoverage, hasLength(26));
    expect(upperCoverage, hasLength(26));
    expect(lowerCoverage.toSet(), lowercase.characters.toSet());
    expect(upperCoverage.toSet(), uppercase.characters.toSet());
    expect(getTextTransitionCharset('k'), 'acesuvxznhok');
    expect(getTextTransitionCharset('K'), 'ACESUVXZNHOK');
    expect(getTextTransitionCharset('i'), 'iljtfr');
    expect(getTextTransitionCharset('m'), 'mwdbpqgy');
  });

  test('preserves unsupported graphemes and confines supported pools', () {
    expect(getRandomTransitionCharacter(' ', () => 0.9), ' ');
    expect(getRandomTransitionCharacter('\n', () => 0.9), '\n');
    for (final digit in '0123456789'.characters) {
      expect(
        getRandomTransitionCharacter(digit, () => 0.9),
        matches(RegExp(r'[0-9]')),
      );
    }
    for (final symbol in '#%&^+=-'.characters) {
      expect(
        getRandomTransitionCharacter(symbol, () => 0.9),
        matches(RegExp(r'[#%&^+=-]')),
      );
    }

    for (final grapheme in <String>[
      '?',
      'é',
      'e\u0301',
      '界',
      'م',
      'ש',
      '👨‍👩‍👧‍👦',
      '🏳️‍🌈',
    ]) {
      expect(getTextTransitionCharset(grapheme), isNull);
      expect(getRandomTransitionCharacter(grapheme, () => 0.5), grapheme);
    }
  });

  test('uses the neutral growth, shrink, equal, and zero-stagger timelines',
      () {
    final growth =
        getTextTransitionTimeline('Launch', 'View analytics dashboard');
    final shrink =
        getTextTransitionTimeline('View analytics dashboard', 'Launch');
    final equal = getTextTransitionTimeline('Save', 'Open');
    final zero = getTextTransitionTimeline(
      'Save',
      'Open',
      slotStaggerMs: 0,
    );
    final negative = getTextTransitionTimeline(
      'Save',
      'Open',
      slotStaggerMs: -20,
    );

    expect(growth.sourceLength, 6);
    expect(growth.targetLength, 24);
    expect(growth.lastRandomizeStartMs, 161);
    expect(growth.collapseStartMs, 171);
    expect(growth.totalDurationMs, 332);
    expect(shrink.totalDurationMs, 332);
    expect(equal.totalDurationMs, 52);
    expect(zero.collapseStartMs, 10);
    expect(zero.totalDurationMs, 10);
    expect(negative.totalDurationMs, 10);
  });

  test('introduces and resolves growth slots in logical order', () {
    final timeline = getTextTransitionTimeline('hello', 'welcome2');

    expect(timeline.lastSourceRandomizeStartMs, 28);
    expect(timeline.lastRandomizeStartMs, 49);
    expect(timeline.collapseStartMs, 59);
    expect(getTextTransitionRandomizeStartMs(4, 5, 8), 28);
    expect(getTextTransitionRandomizeStartMs(5, 5, 8), 35);
    expect(getTextTransitionRandomizeStartMs(7, 5, 8), 49);

    expect(buildTextTransitionFrame('hello', 'welcome2', 34, () => 0),
        hasLength(5));
    expect(buildTextTransitionFrame('hello', 'welcome2', 35, () => 0),
        hasLength(6));
    expect(buildTextTransitionFrame('hello', 'welcome2', 49, () => 0),
        hasLength(8));
    expect(buildTextTransitionFrame('hello', 'welcome2', 58, () => 0)[0],
        isNot('w'));
    expect(buildTextTransitionFrame('hello', 'welcome2', 59, () => 0)[0], 'w');
  });

  test('removes shrink excess from the logical trailing end first', () {
    final timeline = getTextTransitionTimeline('welcome2', 'go');

    expect(timeline.collapseStartMs, 59);
    expect(
        buildTextTransitionFrame('welcome2', 'go', 58, () => 0), hasLength(8));
    expect(
        buildTextTransitionFrame('welcome2', 'go', 59, () => 0), hasLength(7));
    expect(
        buildTextTransitionFrame('welcome2', 'go', 66, () => 0), hasLength(6));
    expect(
      buildTextTransitionFrame(
        'welcome2',
        'go',
        timeline.totalDurationMs,
        () => 0,
      ),
      'go',
    );
  });

  test('indexes extended grapheme clusters instead of UTF code units', () {
    final timeline =
        getTextTransitionTimeline('A👨‍👩‍👧‍👦e\u0301', 'B🏳️‍🌈é');
    expect(timeline.sourceLength, 3);
    expect(timeline.targetLength, 3);

    final frame = buildTextTransitionFrame(
      'A👨‍👩‍👧‍👦e\u0301',
      'B🏳️‍🌈é',
      8,
      () => 0.5,
    );
    expect(frame.characters.length, 3);
    expect(frame.characters.elementAt(1), '👨‍👩‍👧‍👦');
    expect(frame.characters.elementAt(2), 'e\u0301');
  });

  test('zero stagger safely collapses every slot after the hold', () {
    expect(
      buildTextTransitionFrameWithStagger(
        fromText: 'Save',
        targetText: 'Open',
        elapsedMs: 9,
        slotStaggerMs: 0,
        random: () => 0,
      ),
      isNot('Open'),
    );
    expect(
      buildTextTransitionFrameWithStagger(
        fromText: 'Save',
        targetText: 'Open',
        elapsedMs: 10,
        slotStaggerMs: 0,
        random: () => 0,
      ),
      'Open',
    );
  });

  testWidgets('uses elapsed frame time and stops a running transition',
      (tester) async {
    final updates = <String>[];
    final elapsed = <int>[];
    final transition = runTextTransition(
      fromText: 'hello',
      targetText: 'welcome2',
      onUpdate: updates.add,
      onTick: (value, _) => elapsed.add(value),
      random: () => 0.25,
    );

    await tester.pump(const Duration(milliseconds: 45));
    expect(elapsed, <int>[0]);
    await tester.pump(const Duration(milliseconds: 45));
    expect(elapsed.last, 45);
    expect(updates.length, 2);

    transition.stop();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(updates.length, 2);
  });
}

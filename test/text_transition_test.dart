import 'package:rcaferati_flutter_awesome_button/src/text_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves spaces while scrambling and uses the correct character pools',
      () {
    expect(buildTextTransitionFrame('A a0#', 'B b1?', 20, () => 0.5)[1], ' ');
    expect(getRandomTransitionCharacter('A', () => 0.4),
        matches(RegExp(r'[A-Z]')));
    expect(getRandomTransitionCharacter('z', () => 0.4),
        matches(RegExp(r'[a-z]')));
    expect(getRandomTransitionCharacter('4', () => 0.4),
        matches(RegExp(r'[0-9]')));
    expect(
      getRandomTransitionCharacter('#', () => 0.4),
      matches(RegExp(r'[#%&^+=-]')),
    );
  });

  test('randomizes current slots first, expands, then collapses left-to-right',
      () {
    final timeline = getTextTransitionTimeline('hello', 'welcome2');

    expect(timeline.lastSourceRandomizeStartMs, 20);
    expect(timeline.lastRandomizeStartMs, 35);
    expect(timeline.collapseStartMs, 45);
    expect(getTextTransitionRandomizeStartMs(4, 5, 8), 20);
    expect(getTextTransitionRandomizeStartMs(5, 5, 8), 25);
    expect(getTextTransitionRandomizeStartMs(7, 5, 8), 35);

    expect(buildTextTransitionFrame('hello', 'welcome2', 24, () => 0),
        hasLength(5));
    expect(buildTextTransitionFrame('hello', 'welcome2', 25, () => 0),
        hasLength(6));
    expect(buildTextTransitionFrame('hello', 'welcome2', 35, () => 0),
        hasLength(8));
    expect(buildTextTransitionFrame('hello', 'welcome2', 44, () => 0)[0],
        isNot('w'));
    expect(buildTextTransitionFrame('hello', 'welcome2', 45, () => 0)[0], 'w');
  });

  test('keeps trailing source slots until collapse when the target is shorter',
      () {
    final timeline = getTextTransitionTimeline('welcome2', 'go');

    expect(timeline.collapseStartMs, 45);
    expect(
        buildTextTransitionFrame('welcome2', 'go', 32, () => 0), hasLength(8));
    expect(
        buildTextTransitionFrame('welcome2', 'go', 54, () => 0), hasLength(8));
    expect(
      buildTextTransitionFrame(
          'welcome2', 'go', timeline.totalDurationMs, () => 0),
      'go',
    );
  });

  testWidgets('stops a running transition when interrupted', (tester) async {
    final updates = <String>[];
    final transition = runTextTransition(
      fromText: 'hello',
      targetText: 'welcome2',
      onUpdate: updates.add,
      random: () => 0.25,
    );

    await tester.pump(const Duration(milliseconds: 16));

    transition.stop();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(updates, hasLength(1));
    expect(updates.first, isNot('welcome2'));
  });
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

void main() {
  Widget host(
    Widget child, {
    bool reduceMotion = false,
    double textScale = 1,
    TextDirection direction = TextDirection.ltr,
    TargetPlatform platform = TargetPlatform.iOS,
  }) {
    return MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: direction,
          child: child!,
        ),
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }

  Finder face(Key key) => find.descendant(
        of: find.byKey(key),
        matching: find.byKey(const ValueKey<String>('aws-btn-face')),
      );

  testWidgets('an undispatched release uses the latest committed callback', (
    tester,
  ) async {
    const key = Key('fresh-release');
    late StateSetter update;
    var callback = 'A';
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            final value = callback;
            return AwesomeButton(
              key: key,
              onPress: ([next]) => calls.add(value),
              child: 'Fresh',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => callback = 'B');
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['B']);
  });

  testWidgets('an armed hold uses a direct replacement long callback', (
    tester,
  ) async {
    const key = Key('replace-long');
    late StateSetter update;
    var longVersion = 'A';
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            final version = longVersion;
            return AwesomeButton(
              key: key,
              onPress: ([next]) => calls.add('tap'),
              onLongPress: () => calls.add(version),
              child: 'Hold',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => longVersion = 'B');
    await tester.pump();
    await tester.pump(kLongPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['B']);
  });

  testWidgets('adding a long callback during a hold applies next gesture', (
    tester,
  ) async {
    const key = Key('add-long');
    late StateSetter update;
    VoidCallback? onLongPress;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              onPress: ([next]) => calls.add('tap'),
              onLongPress: onLongPress,
              child: 'Hold',
            );
          },
        ),
      ),
    );

    final first = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => onLongPress = () => calls.add('long'));
    await tester.pump();
    await tester.pump(kLongPressTimeout);
    await first.up();
    await tester.pumpAndSettle();
    expect(calls, ['tap']);

    final second = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump(kLongPressTimeout);
    await second.up();
    await tester.pumpAndSettle();
    expect(calls, ['tap', 'long']);
  });

  testWidgets('a committed nil permanently disarms the current hold', (
    tester,
  ) async {
    const key = Key('disarm-long');
    late StateSetter update;
    VoidCallback? onLongPress;
    final calls = <String>[];
    onLongPress = () => calls.add('A');

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              onPress: ([next]) => calls.add('tap'),
              onLongPress: onLongPress,
              child: 'Hold',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => onLongPress = null);
    await tester.pump();
    update(() => onLongPress = () => calls.add('B'));
    await tester.pump();
    await tester.pump(kLongPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['tap']);
  });

  testWidgets('committed disablement cancels one owned gesture', (
    tester,
  ) async {
    const key = Key('disable-hold');
    late StateSetter update;
    var disabled = false;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              disabled: disabled,
              onPress: ([next]) => calls.add('tap'),
              onLongPress: () => calls.add('long'),
              onPressOut: () => calls.add('out'),
              onPressedOut: () => calls.add('settled'),
              child: 'Cancel',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => disabled = true);
    await tester.pump();
    await tester.pump(kLongPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['out', 'settled']);
  });

  testWidgets('press-in disablement cancels after the update commits', (
    tester,
  ) async {
    const key = Key('disable-from-press-in');
    late StateSetter update;
    var disabled = false;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              disabled: disabled,
              onPressIn: () {
                calls.add('in');
                update(() => disabled = true);
              },
              onPressedIn: () => calls.add('pressed-in'),
              onPressOut: () => calls.add('out'),
              onPressedOut: () => calls.add('settled'),
              onPress: ([next]) => calls.add('press'),
              child: 'Disable',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['in', 'pressed-in', 'out', 'settled']);
  });

  testWidgets('pressed-in removal suppresses all later lifecycle work', (
    tester,
  ) async {
    const key = Key('remove-from-pressed-in');
    late StateSetter update;
    var visible = true;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            if (!visible) {
              return const SizedBox.shrink();
            }
            return AwesomeButton(
              key: key,
              onPressIn: () => calls.add('in'),
              onPressedIn: () {
                calls.add('pressed-in');
                update(() => visible = false);
              },
              onPressOut: () => calls.add('out'),
              onPressedOut: () => calls.add('settled'),
              onPress: ([next]) => calls.add('press'),
              child: 'Remove',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['in', 'pressed-in', 'out']);
  });

  testWidgets('removal during a hold suppresses post-removal completion', (
    tester,
  ) async {
    const key = Key('remove-hold');
    late StateSetter update;
    var visible = true;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            if (!visible) {
              return const SizedBox.shrink();
            }
            return AwesomeButton(
              key: key,
              onPress: ([next]) => calls.add('tap'),
              onLongPress: () => calls.add('long'),
              onPressOut: () => calls.add('out'),
              onPressedOut: () => calls.add('settled'),
              child: 'Remove',
            );
          },
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump();
    update(() => visible = false);
    await tester.pump();
    await tester.pump(kLongPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['out']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a hold without a long handler remains an ordinary tap', (
    tester,
  ) async {
    const key = Key('ordinary-hold');
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          onPress: ([next]) => calls.add('tap'),
          onPressOut: () => calls.add('out'),
          onPressedOut: () => calls.add('settled'),
          child: 'Hold',
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(face(key)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(calls, ['out', 'tap', 'settled']);
  });

  testWidgets('press-out removal takes effect at the commit boundary', (
    tester,
  ) async {
    const key = Key('remove-from-press-out');
    late StateSetter update;
    var visible = true;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            if (!visible) {
              return const SizedBox.shrink();
            }
            return AwesomeButton(
              key: key,
              onPressOut: () {
                calls.add('out');
                update(() => visible = false);
              },
              onPressedOut: () => calls.add('settled'),
              onPress: ([next]) => calls.add('press'),
              child: 'Remove',
            );
          },
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pumpAndSettle();

    expect(calls, ['out', 'press', 'settled']);
  });

  testWidgets('keyboard activation remains atomic', (tester) async {
    const key = Key('keyboard-atomic');
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          autofocus: true,
          onPress: ([next]) => calls.add('press'),
          onPressIn: () => calls.add('in'),
          onPressedIn: () => calls.add('pressed-in'),
          onPressOut: () => calls.add('out'),
          onPressedOut: () => calls.add('pressed-out'),
          child: 'Keyboard',
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(calls, ['press']);
  });

  testWidgets('semantic activation is atomic and fabricates no held lifecycle',
      (
    tester,
  ) async {
    const key = Key('atomic-semantics');
    final calls = <String>[];
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          onPress: ([next]) => calls.add('press'),
          onPressIn: () => calls.add('in'),
          onPressedIn: () => calls.add('pressed-in'),
          onPressOut: () => calls.add('out'),
          onPressedOut: () => calls.add('pressed-out'),
          child: 'Atomic',
        ),
      ),
    );

    tester.semantics.tap(find.semantics.byLabel('Atomic'));
    await tester.pump();

    expect(calls, ['press']);
    semantics.dispose();
  });

  testWidgets(
    'semantic progress remains atomic through completion and rollback',
    (tester) async {
      const key = Key('atomic-progress');
      final calls = <String>[];
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          AwesomeButton(
            key: key,
            progress: true,
            progressLoadingTime: Duration.zero,
            onPress: ([next]) {
              calls.add('press-start');
              next!(() => calls.add('complete'));
              calls.add('press-end');
            },
            onPressIn: () => calls.add('in'),
            onPressedIn: () => calls.add('pressed-in'),
            onPressOut: () => calls.add('out'),
            onPressedOut: () => calls.add('pressed-out'),
            onProgressStart: () => calls.add('progress-start'),
            onProgressEnd: () => calls.add('progress-end'),
            child: 'Atomic progress',
          ),
        ),
      );

      tester.semantics.tap(find.semantics.byLabel('Atomic progress'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(calls, [
        'progress-start',
        'press-start',
        'press-end',
        'complete',
        'progress-end',
      ]);
      semantics.dispose();
    },
  );

  testWidgets('held progress settles release before completion callbacks', (
    tester,
  ) async {
    const key = Key('held-progress-order');
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          progress: true,
          progressLoadingTime: Duration.zero,
          onPress: ([next]) => next!(() => calls.add('complete')),
          onPressOut: () => calls.add('out'),
          onPressedOut: () => calls.add('pressed-out'),
          onProgressEnd: () => calls.add('progress-end'),
          child: 'Held progress',
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pumpAndSettle();

    expect(calls, ['out', 'pressed-out', 'complete', 'progress-end']);
  });

  testWidgets('progress completion is one-shot, deferred, and snapshotted', (
    tester,
  ) async {
    const key = Key('progress-snapshot');
    late StateSetter update;
    late AwesomeButtonNext next;
    var endVersion = 'A';
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            final version = endVersion;
            return AwesomeButton(
              key: key,
              progress: true,
              progressLoadingTime: Duration.zero,
              onPress: ([received]) {
                calls.add('press-start');
                next = received!;
                calls.add('press-end');
              },
              onProgressStart: () => calls.add('progress-start'),
              onProgressEnd: () => calls.add('end-$version'),
              child: 'Progress',
            );
          },
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    expect(calls, ['progress-start', 'press-start', 'press-end']);

    next(() => calls.add('complete'));
    next(() => calls.add('duplicate'));
    update(() => endVersion = 'B');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      calls,
      ['progress-start', 'press-start', 'press-end', 'complete', 'end-A'],
    );
  });

  testWidgets('a progress handle is inert after package-view removal', (
    tester,
  ) async {
    const key = Key('stale-progress-handle');
    AwesomeButtonNext? next;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          progress: true,
          onPress: ([received]) => next = received,
          onProgressEnd: () => calls.add('end'),
          child: 'Progress',
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    expect(next, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    next!(() => calls.add('complete'));
    await tester.pumpAndSettle();

    expect(calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('synchronous progress completion waits for delivery unwind', (
    tester,
  ) async {
    const key = Key('sync-progress');
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          progress: true,
          progressLoadingTime: Duration.zero,
          onPress: ([next]) {
            calls.add('press-start');
            next!(() => calls.add('complete'));
            calls.add('press-end');
          },
          onProgressEnd: () => calls.add('end'),
          child: 'Progress',
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    expect(calls, ['press-start', 'press-end']);
    await tester.pumpAndSettle();
    expect(calls, ['press-start', 'press-end', 'complete', 'end']);
  });

  testWidgets('deferred progress activation reads the latest callback', (
    tester,
  ) async {
    const key = Key('progress-live-callback');
    late StateSetter update;
    var version = 'A';
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            final current = version;
            return AwesomeButton(
              key: key,
              progress: true,
              progressLoadingTime: Duration.zero,
              onProgressStart: () {
                update(() => version = 'B');
              },
              onPress: ([next]) {
                calls.add(current);
                next!();
              },
              child: 'Progress',
            );
          },
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(calls, ['B']);
  });

  testWidgets('progress-start disablement rolls back before activation', (
    tester,
  ) async {
    const key = Key('disable-from-progress-start');
    late StateSetter update;
    var disabled = false;
    final calls = <String>[];

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              disabled: disabled,
              progress: true,
              progressLoadingTime: Duration.zero,
              onPressOut: () => calls.add('out'),
              onPressedOut: () => calls.add('settled'),
              onProgressStart: () {
                calls.add('progress-start');
                update(() => disabled = true);
              },
              onPress: ([next]) => calls.add('press'),
              onProgressEnd: () => calls.add('progress-end'),
              child: 'Disable',
            );
          },
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(calls, ['out', 'progress-start', 'settled', 'progress-end']);
  });

  testWidgets('arbitrary auto-width content follows committed size changes', (
    tester,
  ) async {
    const key = Key('custom-auto-width');
    late StateSetter update;
    var contentWidth = 40.0;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              child: SizedBox(width: contentWidth, height: 20),
            );
          },
        ),
      ),
    );
    final before = tester.getSize(face(key)).width;

    update(() => contentWidth = 140);
    await tester.pumpAndSettle();
    final after = tester.getSize(face(key)).width;

    expect(after - before, closeTo(100, 0.5));
  });

  testWidgets('invalid numeric input normalizes to finite safe geometry', (
    tester,
  ) async {
    const key = Key('normalized-input');

    await tester.pumpWidget(
      host(
        const AwesomeButton(
          key: key,
          width: double.nan,
          height: double.infinity,
          paddingHorizontal: -20,
          paddingTop: double.nan,
          paddingBottom: -4,
          activeOpacity: double.nan,
          debouncedPressTime: Duration(microseconds: -1),
          progressLoadingTime: Duration(microseconds: -1),
          pressInAnimationDuration: Duration(microseconds: -1),
          style: AwesomeButtonStyle(
            raiseAmount: -8,
            borderWidth: double.infinity,
            textSize: -2,
            textLineHeight: double.nan,
            contentGap: -3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(double.nan, -4),
            ),
          ),
          child: 'Safe',
        ),
      ),
    );

    final rect = tester.getRect(face(key));
    expect(rect.width.isFinite, isTrue);
    expect(rect.height, 52);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct style changes use the resolved animation duration', (
    tester,
  ) async {
    const key = Key('direct-style-transition');
    late StateSetter update;
    var background = Colors.black;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AwesomeButton(
              key: key,
              style: AwesomeButtonStyle(
                backgroundColor: background,
                animationDuration: const Duration(milliseconds: 140),
              ),
              child: 'Styled',
            );
          },
        ),
      ),
    );

    update(() => background = Colors.white);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final midpoint = (tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: face(key),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration as BoxDecoration)
        .color;
    expect(midpoint, isNot(Colors.black));
    expect(midpoint, isNot(Colors.white));

    await tester.pump(const Duration(milliseconds: 70));
    final settled = (tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: face(key),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration as BoxDecoration)
        .color;
    expect(settled, Colors.white);
  });

  testWidgets('Reduced Motion preserves logic and uses a static busy layer', (
    tester,
  ) async {
    const key = Key('reduced-progress');
    AwesomeButtonNext? next;
    var pressed = 0;

    await tester.pumpWidget(
      host(
        AwesomeButton(
          key: key,
          progress: true,
          progressLoadingTime: const Duration(seconds: 30),
          onPress: ([value]) {
            pressed += 1;
            next = value;
          },
          child: 'Reduced',
        ),
        reduceMotion: true,
      ),
    );

    await tester.tapAt(tester.getCenter(face(key)));
    await tester.pump();
    expect(pressed, 1);
    final progress = tester.widget<FractionalTranslation>(
      find
          .ancestor(
            of: find.byKey(const ValueKey<String>('aws-btn-progress-fill')),
            matching: find.byType(FractionalTranslation),
          )
          .first,
    );
    expect(progress.translation.dx, 0);
    next!();
    await tester.pumpAndSettle();
  });

  testWidgets('large text grows the face and host minimum targets are honored',
      (
    tester,
  ) async {
    const key = Key('large-target');
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        const AwesomeButton(
          key: key,
          width: 80,
          height: 20,
          onPress: _noop,
          child: 'Large readable label',
        ),
        textScale: 3,
        platform: TargetPlatform.android,
      ),
    );

    expect(tester.getSize(face(key)).height, greaterThan(20));
    final node = tester.getSemantics(find.byKey(key));
    expect(node.rect.width, greaterThanOrEqualTo(48));
    expect(node.rect.height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  testWidgets('RTL keeps logical slot order and mirrors progress travel', (
    tester,
  ) async {
    const key = Key('rtl-progress');

    await tester.pumpWidget(
      host(
        const AwesomeButton(
          key: key,
          width: 260,
          progress: true,
          onPress: _noop,
          before: Text('Before', key: Key('before')),
          after: Text('After', key: Key('after')),
          child: 'Label',
        ),
        direction: TextDirection.rtl,
      ),
    );

    expect(
      tester.getCenter(find.byKey(const Key('before'))).dx,
      greaterThan(tester.getCenter(find.byKey(const Key('after'))).dx),
    );
  });
}

void _noop([AwesomeButtonNext? _]) {}

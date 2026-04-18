import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrapForTest(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  Finder faceFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-face')),
    );
  }

  Finder shellFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-shell')),
    );
  }

  Finder shadowFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-shadow')),
    );
  }

  Finder shadowDecorationFinderFor(Key key) {
    return find.descendant(
      of: shadowFinderFor(key),
      matching: find.byType(DecoratedBox),
    );
  }

  Finder bottomFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-bottom-shell')),
    );
  }

  Finder bottomDecorationFinderFor(Key key) {
    return find.descendant(
      of: bottomFinderFor(key),
      matching: find.byType(DecoratedBox),
    );
  }

  Finder contentOpacityFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-content-opacity')),
    );
  }

  Finder contentTransitionFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching:
          find.byKey(const ValueKey<String>('aws-btn-content-transition')),
    );
  }

  Finder activityOpacityFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-activity-opacity')),
    );
  }

  Finder activityTransitionFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching:
          find.byKey(const ValueKey<String>('aws-btn-activity-transition')),
    );
  }

  Finder progressOverlayFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-progress-overlay')),
    );
  }

  Finder activeBackgroundFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-active-background')),
    );
  }

  Finder progressFillFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-progress-fill')),
    );
  }

  Finder placeholderFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching:
          find.byKey(const ValueKey<String>('aws-btn-content-placeholder')),
    );
  }

  Finder placeholderBarFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(
        const ValueKey<String>('aws-btn-content-placeholder-bar'),
      ),
    );
  }

  Finder pressedOpacityFinderFor(Key key) {
    return find.descendant(
      of: find.byKey(key),
      matching: find.byKey(const ValueKey<String>('aws-btn-pressed-opacity')),
    );
  }

  Color? progressFillColorOf(WidgetTester tester, Key key) {
    return (tester.widget<DecoratedBox>(progressFillFinderFor(key)).decoration
            as BoxDecoration)
        .color;
  }

  double scaleOf(Transform transform) => transform.transform.storage[0];

  Future<void> pumpImmediatePressFrame(WidgetTester tester) {
    return tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> pumpImmediatePressAnimation(WidgetTester tester) async {
    await tester.pump();
    await pumpImmediatePressFrame(tester);
  }

  Future<void> pumpTextTransitionFrames(
    WidgetTester tester, {
    int count = 1,
  }) async {
    for (var index = 0; index < count; index += 1) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  testWidgets('renders child content', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          child: Text('Render me'),
        ),
      ),
    );

    expect(find.text('Render me'), findsOneWidget);
  });

  testWidgets('buttons without handlers still animate press in and out', (
    tester,
  ) async {
    const buttonKey = Key('display-only-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          child: Text('Display'),
        ),
      ),
    );

    final initialTop = tester.getTopLeft(faceFinderFor(buttonKey)).dy;
    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);
    final pressedTop = tester.getTopLeft(faceFinderFor(buttonKey)).dy;
    expect(pressedTop, greaterThan(initialTop));

    await gesture.up();
    await tester.pumpAndSettle();

    final releasedTop = tester.getTopLeft(faceFinderFor(buttonKey)).dy;
    expect(releasedTop, equals(initialTop));
  });

  testWidgets('release animation overshoots upward before settling', (
    tester,
  ) async {
    const buttonKey = Key('bouncy-release-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          onPress: _noop,
          child: Text('Bounce'),
        ),
      ),
    );

    final initialTop = tester.getTopLeft(faceFinderFor(buttonKey)).dy;
    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);
    await gesture.up();

    var minimumTop = double.infinity;
    for (var index = 0; index < 12; index += 1) {
      await tester.pump(const Duration(milliseconds: 16));
      minimumTop = math.min(
        minimumTop,
        tester.getTopLeft(faceFinderFor(buttonKey)).dy,
      );
    }

    expect(minimumTop, lessThan(initialTop));

    await tester.pumpAndSettle();
    final settledTop = tester.getTopLeft(faceFinderFor(buttonKey)).dy;
    expect(settledTop, equals(initialTop));
  });

  testWidgets('renders a placeholder when child is null and omits before/after',
      (
    tester,
  ) async {
    const buttonKey = Key('placeholder-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          before: Icon(Icons.chevron_left_rounded, key: Key('before')),
          after: Icon(Icons.chevron_right_rounded, key: Key('after')),
        ),
      ),
    );

    expect(placeholderFinderFor(buttonKey), findsOneWidget);
    expect(find.byKey(const Key('before')), findsNothing);
    expect(find.byKey(const Key('after')), findsNothing);
  });

  testWidgets('placeholder uses resolved backgroundPlaceholder color', (
    tester,
  ) async {
    const buttonKey = Key('placeholder-color-button');
    const placeholderColor = Color(0xFF334155);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          style: AwesomeButtonStyle(backgroundPlaceholder: placeholderColor),
        ),
      ),
    );

    expect(
      (tester
              .widget<DecoratedBox>(
                find
                    .descendant(
                      of: placeholderFinderFor(buttonKey),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration as BoxDecoration)
          .color,
      placeholderColor,
    );
  });

  testWidgets('renders before, child, after, and extra content', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          before: Icon(Icons.chevron_left_rounded, key: Key('before')),
          after: Icon(Icons.chevron_right_rounded, key: Key('after')),
          extra: SizedBox.expand(
              child: ColoredBox(key: Key('extra'), color: Colors.transparent)),
          child: Text('Layout'),
        ),
      ),
    );

    expect(find.byKey(const Key('before')), findsOneWidget);
    expect(find.byKey(const Key('after')), findsOneWidget);
    expect(find.byKey(const Key('extra')), findsOneWidget);
    expect(find.text('Layout'), findsOneWidget);
  });

  testWidgets('stretch fills the available width', (tester) async {
    const buttonKey = Key('stretch-button');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: AwesomeButton(
                key: buttonKey,
                stretch: true,
                onPress: _noop,
                child: Text('Stretch'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(shellFinderFor(buttonKey)).width, 280);
    expect(tester.getSize(faceFinderFor(buttonKey)).height, 52);
    expect(tester.getSize(bottomFinderFor(buttonKey)).height, 52);
    expect(tester.getSize(shadowFinderFor(buttonKey)).height, 46);

    final shadowRect = tester.getRect(shadowFinderFor(buttonKey));
    final bottomRect = tester.getRect(bottomFinderFor(buttonKey));
    expect(shadowRect.bottom, greaterThan(bottomRect.bottom));
    expect(shadowRect.left, greaterThan(bottomRect.left));
    expect(shadowRect.right, lessThan(bottomRect.right));
  });

  testWidgets(
      'explicit-width buttons keep the raised shell separate from the face', (
    tester,
  ) async {
    const buttonKey = Key('width-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          width: 240,
          height: 64,
          onPress: _noop,
          child: Text('Wide'),
        ),
      ),
    );

    expect(tester.getSize(shellFinderFor(buttonKey)).height, 70);
    expect(tester.getSize(faceFinderFor(buttonKey)).height, 64);
    expect(tester.getSize(bottomFinderFor(buttonKey)).height, 64);
    expect(tester.getSize(shadowFinderFor(buttonKey)).height, 58);

    final shadowRect = tester.getRect(shadowFinderFor(buttonKey));
    final bottomRect = tester.getRect(bottomFinderFor(buttonKey));
    expect(shadowRect.bottom, greaterThan(bottomRect.bottom));
    expect(shadowRect.left, greaterThan(bottomRect.left));
    expect(shadowRect.right, lessThan(bottomRect.right));
  });

  testWidgets('default buttons resolve a neutral translucent shadow plane', (
    tester,
  ) async {
    const buttonKey = Key('default-shadow-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          onPress: _noop,
          child: Text('Default'),
        ),
      ),
    );

    expect(
      (tester
              .widget<DecoratedBox>(shadowDecorationFinderFor(buttonKey))
              .decoration as BoxDecoration)
          .color,
      const Color.fromRGBO(0, 0, 0, 0.15),
    );
    expect(
      (tester
              .widget<DecoratedBox>(bottomDecorationFinderFor(buttonKey))
              .decoration as BoxDecoration)
          .color,
      const Color(0xFF1D4ED8),
    );
  });

  testWidgets('suppresses onPress when disabled', (tester) async {
    var pressed = 0;
    const buttonKey = Key('disabled-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          disabled: true,
          onPress: ([next]) => pressed += 1,
          child: const Text('Disabled'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));

    expect(pressed, 0);
  });

  testWidgets(
      'placeholder buttons suppress onPress and expose disabled semantics', (
    tester,
  ) async {
    var pressed = 0;
    const buttonKey = Key('placeholder-disabled-button');
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          onPress: ([next]) => pressed += 1,
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));

    expect(pressed, 0);
    expect(
      tester.getSemantics(find.byKey(buttonKey)),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );

    handle.dispose();
  });

  testWidgets('placeholder shimmer toggles cleanly with animatedPlaceholder', (
    tester,
  ) async {
    const buttonKey = Key('placeholder-shimmer-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          animatedPlaceholder: false,
        ),
      ),
    );

    expect(placeholderBarFinderFor(buttonKey), findsNothing);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          animatedPlaceholder: true,
        ),
      ),
    );
    await tester.pump();
    expect(placeholderBarFinderFor(buttonKey), findsOneWidget);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          animatedPlaceholder: false,
        ),
      ),
    );
    await tester.pump();
    expect(placeholderBarFinderFor(buttonKey), findsNothing);
  });

  testWidgets('pointer down starts the pressed state immediately',
      (tester) async {
    const buttonKey = Key('immediate-press-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          onPress: _noop,
          child: Text('Immediate'),
        ),
      ),
    );

    final initialRect = tester.getRect(faceFinderFor(buttonKey));
    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);

    final pressedRect = tester.getRect(faceFinderFor(buttonKey));
    expect(pressedRect.top, greaterThan(initialRect.top));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('disabled buttons ignore immediate pointer-down press state', (
    tester,
  ) async {
    const buttonKey = Key('disabled-immediate-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          disabled: true,
          onPress: _noop,
          child: Text('Disabled'),
        ),
      ),
    );

    final initialRect = tester.getRect(faceFinderFor(buttonKey));
    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);

    final pressedRect = tester.getRect(faceFinderFor(buttonKey));
    expect(pressedRect.top, initialRect.top);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('non-progress buttons call onPress without a next callback', (
    tester,
  ) async {
    AwesomeButtonNext? receivedNext;
    const buttonKey = Key('tap-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          onPress: ([next]) => receivedNext = next,
          child: const Text('Tap'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pumpAndSettle();

    expect(receivedNext, isNull);
  });

  testWidgets('activeOpacity reduces non-progress pressed opacity', (
    tester,
  ) async {
    const buttonKey = Key('active-opacity-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          activeOpacity: 0.6,
          onPress: _noop,
          child: Text('Opacity'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));

    expect(
      tester.widget<Opacity>(pressedOpacityFinderFor(buttonKey)).opacity,
      closeTo(0.6, 0.05),
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('progress buttons ignore activeOpacity and stay fully opaque', (
    tester,
  ) async {
    const buttonKey = Key('progress-active-opacity-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          activeOpacity: 0.45,
          progress: true,
          onPress: ([next]) => next?.call(),
          child: const Text('Progress Opacity'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);

    expect(
      tester.widget<Opacity>(pressedOpacityFinderFor(buttonKey)).opacity,
      1,
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('debouncedPressTime suppresses repeated taps inside the window', (
    tester,
  ) async {
    var calls = 0;
    const buttonKey = Key('debounced-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          debouncedPressTime: const Duration(milliseconds: 300),
          onPress: ([next]) => calls += 1,
          child: const Text('Debounce'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pumpAndSettle();

    expect(calls, 1);

    await tester.pump(const Duration(milliseconds: 350));
    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });

  testWidgets('does not animate on initial mount for string textTransition', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Welcome',
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      'Welcome',
    );
  });

  testWidgets(
      'animates on string text changes and expands longer targets before settling',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Go#3',
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Mission#42',
        ),
      ),
    );

    await pumpTextTransitionFrames(tester, count: 3);

    final midText = tester
        .widget<Text>(
          find.byKey(const ValueKey<String>('aws-btn-content-text')),
        )
        .data!;
    expect(midText, isNot('Go#3'));
    expect(midText, isNot('Mission#42'));
    expect(midText, hasLength(7));

    await tester.pumpAndSettle();

    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      'Mission#42',
    );
  });

  testWidgets('does not hard truncate shorter targets before collapse finishes',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Mission#42',
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Go#3',
        ),
      ),
    );

    await pumpTextTransitionFrames(tester, count: 3);

    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      hasLength(10),
    );
  });

  testWidgets(
      'swaps immediately when textTransition is disabled or child is non-string, empty, or null',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Welcome',
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Welcome',
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      'Welcome',
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          child: 'Ready#3',
        ),
      ),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      'Ready#3',
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: Text('Node label'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey<String>('aws-btn-content-text')),
        findsNothing);
    expect(find.text('Node label'), findsOneWidget);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: '',
        ),
      ),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('aws-btn-content-text')),
          )
          .data,
      '',
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
        ),
      ),
    );
    expect(placeholderFinderFor(const Key('missing')), findsNothing);
    expect(find.byKey(const ValueKey<String>('aws-btn-content-placeholder')),
        findsOneWidget);
  });

  testWidgets('cleans up text transition frames on unmount', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Welcome',
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          textTransition: true,
          child: 'Level 2',
        ),
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey<String>('aws-btn-content-text')),
        findsNothing);
  });

  testWidgets('applies custom style values', (tester) async {
    const buttonKey = Key('styled-button');
    const background = Color(0xFF0F172A);
    const depth = Color(0xFF020617);
    const shadow = Color(0xFF030B1D);
    const border = Color(0xFF38BDF8);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          onPress: _noop,
          style: AwesomeButtonStyle(
            backgroundColor: background,
            depthColor: depth,
            shadowColor: shadow,
            borderColor: border,
            borderWidth: 2,
          ),
          child: Text('Styled'),
        ),
      ),
    );

    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(DecoratedBox),
      ),
    );

    expect(
      decoratedBoxes.any(
        (box) => (box.decoration as BoxDecoration).color == background,
      ),
      isTrue,
    );
    expect(
      decoratedBoxes.any(
        (box) => (box.decoration as BoxDecoration).color == depth,
      ),
      isTrue,
    );
    expect(
      (tester
              .widget<DecoratedBox>(shadowDecorationFinderFor(buttonKey))
              .decoration as BoxDecoration)
          .color,
      shadow,
    );
  });

  testWidgets('pressed active background stays inside the face border', (
    tester,
  ) async {
    const buttonKey = Key('bordered-press-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          onPress: _noop,
          style: AwesomeButtonStyle(
            backgroundColor: Color(0xFFE11D48),
            backgroundActive: Color(0xFFBE123C),
            borderColor: Color(0xFFFACC15),
            borderWidth: 2,
          ),
          child: Text('Border'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );
    await pumpImmediatePressAnimation(tester);

    final faceRect = tester.getRect(faceFinderFor(buttonKey));
    final activeRect = tester.getRect(
      find.descendant(
        of: find.byKey(buttonKey),
        matching:
            find.byKey(const ValueKey<String>('aws-btn-active-background')),
      ),
    );

    expect(activeRect.left, greaterThan(faceRect.left));
    expect(activeRect.top, greaterThan(faceRect.top));
    expect(activeRect.right, lessThan(faceRect.right));
    expect(activeRect.bottom, lessThan(faceRect.bottom));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('disabled buttons resolve disabledShadowColor', (tester) async {
    const buttonKey = Key('disabled-shadow-button');
    const disabledShadow = Color(0xFF44556A);

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          disabled: true,
          onPress: _noop,
          style: AwesomeButtonStyle(
            shadowColor: Color(0xFF111827),
            disabledShadowColor: disabledShadow,
          ),
          child: Text('Disabled'),
        ),
      ),
    );

    expect(
      (tester
              .widget<DecoratedBox>(shadowDecorationFinderFor(buttonKey))
              .decoration as BoxDecoration)
          .color,
      disabledShadow,
    );
  });

  testWidgets('default disabled buttons use the neutral disabled shadow color',
      (
    tester,
  ) async {
    const buttonKey = Key('default-disabled-shadow-button');

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: buttonKey,
          disabled: true,
          onPress: _noop,
          child: Text('Disabled'),
        ),
      ),
    );

    expect(
      (tester
              .widget<DecoratedBox>(shadowDecorationFinderFor(buttonKey))
              .decoration as BoxDecoration)
          .color,
      const Color.fromRGBO(0, 0, 0, 0.10),
    );
  });

  testWidgets('default progress fill falls back to the dark RN-style tone', (
    tester,
  ) async {
    const buttonKey = Key('default-progress-fill-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          onPress: ([next]) {},
          child: const Text('Upload'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      progressFillColorOf(tester, buttonKey),
      const Color.fromRGBO(0, 0, 0, 0.15),
    );
  });

  testWidgets(
      'progress buttons call onPress(next) exactly once and become busy', (
    tester,
  ) async {
    var calls = 0;
    AwesomeButtonNext? next;
    const buttonKey = Key('progress-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          progressLoadingTime: const Duration(milliseconds: 600),
          onPress: ([completion]) {
            calls += 1;
            next = completion;
          },
          child: const Text('Upload'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 1);
    expect(next, isNotNull);
    expect(shadowFinderFor(buttonKey), findsOneWidget);
    expect(bottomFinderFor(buttonKey), findsOneWidget);
    expect(
      tester.widget<Opacity>(contentOpacityFinderFor(buttonKey)).opacity,
      lessThan(1),
    );
    expect(
      tester.widget<Opacity>(activityOpacityFinderFor(buttonKey)).opacity,
      greaterThan(0),
    );
    expect(
      scaleOf(tester.widget<Transform>(contentTransitionFinderFor(buttonKey))),
      isNot(1),
    );
    expect(
      scaleOf(tester.widget<Transform>(activityTransitionFinderFor(buttonKey))),
      greaterThan(0),
    );
    expect(
      tester.widget<Opacity>(progressOverlayFinderFor(buttonKey)).opacity,
      1,
    );
    expect(progressFillFinderFor(buttonKey), findsOneWidget);
    Key? childKey(Widget child) {
      return switch (child) {
        final IgnorePointer pointerChild => pointerChild.child?.key,
        _ => child.key,
      };
    }

    final faceStack = tester
        .widgetList<Stack>(
          find.descendant(
            of: faceFinderFor(buttonKey),
            matching: find.byType(Stack),
          ),
        )
        .firstWhere(
          (stack) =>
              stack.children.any(
                (child) =>
                    childKey(child) ==
                    const ValueKey<String>('aws-btn-progress-overlay'),
              ) &&
              stack.children.any(
                (child) =>
                    childKey(child) ==
                    const ValueKey<String>('aws-btn-active-background'),
              ),
        );
    final activeBackgroundIndex = faceStack.children.indexWhere(
      (child) =>
          childKey(child) ==
          const ValueKey<String>('aws-btn-active-background'),
    );
    final progressOverlayIndex = faceStack.children.indexWhere(
      (child) =>
          childKey(child) == const ValueKey<String>('aws-btn-progress-overlay'),
    );
    expect(progressOverlayIndex, greaterThan(activeBackgroundIndex));
    final faceRect = tester.getRect(faceFinderFor(buttonKey));
    final initialProgressRect =
        tester.getRect(progressFillFinderFor(buttonKey));
    expect(initialProgressRect.left, lessThan(faceRect.left));

    await tester.pump(const Duration(milliseconds: 100));
    final midProgressRect = tester.getRect(progressFillFinderFor(buttonKey));
    expect(midProgressRect.left, greaterThan(initialProgressRect.left));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('progress buttons press immediately on pointer down', (
    tester,
  ) async {
    const buttonKey = Key('progress-immediate-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          onPress: ([next]) => next?.call(),
          child: const Text('Progress'),
        ),
      ),
    );

    final initialRect = tester.getRect(faceFinderFor(buttonKey));
    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );

    await pumpImmediatePressAnimation(tester);

    final pressedRect = tester.getRect(faceFinderFor(buttonKey));
    expect(pressedRect.top, greaterThan(initialRect.top));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('showProgressBar false keeps spinner-only progress visuals', (
    tester,
  ) async {
    AwesomeButtonNext? next;
    const buttonKey = Key('spinner-only-progress-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          showProgressBar: false,
          onPress: ([completion]) => next = completion,
          child: const Text('Spinner'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(next, isNotNull);
    expect(progressOverlayFinderFor(buttonKey), findsNothing);
    expect(progressFillFinderFor(buttonKey), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<Opacity>(activeBackgroundFinderFor(buttonKey)).opacity,
      0,
    );

    next?.call();
    await tester.pumpAndSettle();
  });

  testWidgets('repeated taps during progress do not restart the flow', (
    tester,
  ) async {
    var calls = 0;
    const buttonKey = Key('busy-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          progressLoadingTime: const Duration(milliseconds: 600),
          onPress: ([next]) => calls += 1,
          child: const Text('Busy'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 1);
  });

  testWidgets('next completes, releases, and runs the completion callback', (
    tester,
  ) async {
    var calls = 0;
    var completionCalls = 0;
    AwesomeButtonNext? next;
    const buttonKey = Key('complete-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          progressLoadingTime: const Duration(milliseconds: 400),
          onPress: ([completion]) {
            calls += 1;
            next = completion;
          },
          child: const Text('Complete'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    next?.call(() => completionCalls += 1);
    await tester.pump();
    expect(
      tester.widget<Opacity>(progressOverlayFinderFor(buttonKey)).opacity,
      1,
    );
    final beforeCompletionRect =
        tester.getRect(progressFillFinderFor(buttonKey));
    await tester.pump(const Duration(milliseconds: 200));
    final completedRect = tester.getRect(progressFillFinderFor(buttonKey));
    expect(completedRect.left, greaterThan(beforeCompletionRect.left));
    await tester.pump();
    expect(
      tester.widget<Opacity>(progressOverlayFinderFor(buttonKey)).opacity,
      1,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(completionCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 2);
  });

  testWidgets(
      'progress transitions reset cleanly when the widget is removed mid-flow',
      (
    tester,
  ) async {
    const buttonKey = Key('disposed-progress-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          onPress: ([next]) {},
          child: const Text('Dispose'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('press lifecycle callbacks fire in the expected order', (
    tester,
  ) async {
    final events = <String>[];

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: const Key('lifecycle-button'),
          onPressIn: () => events.add('onPressIn'),
          onPressedIn: () => events.add('onPressedIn'),
          onPressOut: () => events.add('onPressOut'),
          onPressedOut: () => events.add('onPressedOut'),
          onPress: ([next]) => events.add('onPress'),
          child: const Text('Lifecycle'),
        ),
      ),
    );

    await tester.tapAt(
      tester.getCenter(faceFinderFor(const Key('lifecycle-button'))),
    );
    await tester.pump(const Duration(milliseconds: 180));
    await tester.pumpAndSettle();

    expect(
      events,
      <String>[
        'onPressIn',
        'onPressedIn',
        'onPressOut',
        'onPress',
        'onPressedOut',
      ],
    );
  });

  testWidgets('progress lifecycle callbacks fire around the next contract', (
    tester,
  ) async {
    final events = <String>[];
    AwesomeButtonNext? next;
    const buttonKey = Key('progress-lifecycle-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          progress: true,
          progressLoadingTime: const Duration(milliseconds: 400),
          onPressIn: () => events.add('onPressIn'),
          onPressOut: () => events.add('onPressOut'),
          onProgressStart: () => events.add('onProgressStart'),
          onProgressEnd: () => events.add('onProgressEnd'),
          onPressedOut: () => events.add('onPressedOut'),
          onPress: ([completion]) {
            events.add('onPress');
            next = completion;
          },
          child: const Text('Progress'),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(faceFinderFor(buttonKey)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    next?.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      events,
      containsAllInOrder(<String>[
        'onPressIn',
        'onPressOut',
        'onProgressStart',
        'onPress',
        'onPressedOut',
        'onProgressEnd',
      ]),
    );
  });

  testWidgets('canceled presses do not dispatch onPress', (tester) async {
    var pressed = 0;
    const buttonKey = Key('cancel-button');

    await tester.pumpWidget(
      wrapForTest(
        AwesomeButton(
          key: buttonKey,
          onPress: ([next]) => pressed += 1,
          child: const Text('Cancel'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(pressed, 0);
  });

  testWidgets('exposes button semantics', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      wrapForTest(
        const AwesomeButton(
          key: Key('semantic-button'),
          onPress: _noop,
          child: Text('Semantic Action'),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(const Key('semantic-button'))),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });
}

void _noop([AwesomeButtonNext? _]) {}

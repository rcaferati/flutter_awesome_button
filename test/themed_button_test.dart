import 'package:flutter/material.dart';
import 'package:flutter_awesome_button/flutter_awesome_button.dart';
import 'package:flutter_awesome_button/src/themed/resolution.dart';
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

  Color? faceColorOf(WidgetTester tester, Key key) {
    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: faceFinderFor(key),
        matching: find.byType(DecoratedBox),
      ),
    );

    return (decoratedBoxes.first.decoration as BoxDecoration).color;
  }

  Color? progressFillColorOf(WidgetTester tester, Key key) {
    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.descendant(
          of: find.byKey(key),
          matching:
              find.byKey(const ValueKey<String>('aws-btn-progress-overlay')),
        ),
        matching: find.byType(DecoratedBox),
      ),
    );

    return (decoratedBoxes.first.decoration as BoxDecoration).color;
  }

  Color? activeBackgroundColorOf(WidgetTester tester, Key key) {
    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.descendant(
          of: find.byKey(key),
          matching: find.byKey(
            const ValueKey<String>('aws-btn-active-background'),
          ),
        ),
        matching: find.byType(DecoratedBox),
      ),
    );

    return (decoratedBoxes.first.decoration as BoxDecoration).color;
  }

  double activeBackgroundOpacityOf(WidgetTester tester, Key key) {
    return tester
        .widget<Opacity>(
          find.descendant(
            of: find.byKey(key),
            matching: find.byKey(
              const ValueKey<String>('aws-btn-active-background'),
            ),
          ),
        )
        .opacity;
  }

  Color? placeholderColorOf(WidgetTester tester, Key key) {
    final decoratedBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.descendant(
          of: find.byKey(key),
          matching: find.byKey(
            const ValueKey<String>('aws-btn-content-placeholder'),
          ),
        ),
        matching: find.byType(DecoratedBox),
      ),
    );

    return (decoratedBoxes.first.decoration as BoxDecoration).color;
  }

  ThemeDefinition buildMinimalTheme({
    Map<ButtonVariant, ThemeButtonStyle>? buttons,
    Map<ButtonSize, ThemeSizeStyle>? size,
  }) {
    return ThemeDefinition(
      title: 'Custom Theme',
      background: const Color(0xFF101828),
      color: Colors.white,
      buttons: buttons ??
          const {
            ButtonVariant.primary: ThemeButtonStyle(
              backgroundColor: Color(0xFF2563EB),
              backgroundDarker: Color(0xFF1D4ED8),
              backgroundProgress: Color(0xFF1E40AF),
              backgroundPlaceholder: Color(0xFF0F172A),
              backgroundActive: Color(0xFF1E3A8A),
              backgroundShadow: Color(0x26000000),
              activityColor: Color(0xFFFACC15),
              textColor: Colors.white,
              textSize: 18,
              textLineHeight: 24,
              textFontFamily: 'ThemedFont',
              raiseLevel: 7,
              borderRadius: 20,
              height: 52,
            ),
            ButtonVariant.secondary: ThemeButtonStyle(
              backgroundColor: Color(0xFFE2E8F0),
              backgroundDarker: Color(0xFFCBD5E1),
              backgroundProgress: Color(0xFF94A3B8),
              backgroundPlaceholder: Color(0xFFCBD5E1),
              backgroundActive: Color(0xFFCBD5E1),
              backgroundShadow: Color(0x1A000000),
              activityColor: Color(0xFF0F172A),
              textColor: Color(0xFF0F172A),
              raiseLevel: 7,
              borderRadius: 20,
              height: 52,
            ),
            ButtonVariant.disabled: ThemeButtonStyle(
              backgroundColor: Color(0xFFCBD5E1),
              backgroundDarker: Color(0xFF94A3B8),
              backgroundPlaceholder: Color(0xFFD6DEEB),
              backgroundShadow: Color(0x14000000),
              textColor: Color(0xFF64748B),
              raiseLevel: 7,
              borderRadius: 20,
              height: 52,
            ),
            ButtonVariant.flat: ThemeButtonStyle(
              backgroundColor: Colors.transparent,
              backgroundDarker: Colors.transparent,
              backgroundShadow: Colors.transparent,
              raiseLevel: 0,
              borderRadius: 0,
            ),
          },
      size: size ??
          const {
            ButtonSize.small: ThemeSizeStyle(
              width: 120,
              height: 44,
              textSize: 12,
              paddingHorizontal: 12,
            ),
            ButtonSize.medium: ThemeSizeStyle(
              width: 200,
              height: 52,
              textSize: 16,
              paddingHorizontal: 20,
            ),
            ButtonSize.large: ThemeSizeStyle(
              width: 250,
              height: 60,
              textSize: 18,
              paddingHorizontal: 24,
            ),
          },
    );
  }

  test('getTheme returns the registered theme by index', () {
    final theme = getTheme(index: 1);

    expect(theme.name, ThemeName.bojack);
    expect(theme.title, 'Bojack Theme');
    expect(theme.prev, isTrue);
    expect(theme.next, isTrue);
  });

  test('getTheme returns the registered theme by name', () {
    final theme = getTheme(name: ThemeName.bruce);

    expect(theme.name, ThemeName.bruce);
    expect(theme.title, 'Bruce Theme');
    expect(theme.prev, isTrue);
    expect(theme.next, isFalse);
  });

  test('getTheme falls back to basic for null and out-of-range indexes', () {
    expect(getTheme(index: null).name, ThemeName.basic);
    expect(getTheme(index: 99).name, ThemeName.basic);
    expect(getTheme(index: -1).name, ThemeName.basic);
  });

  test('themed resolution prioritizes disabled then flat then requested type',
      () {
    final theme = buildMinimalTheme();

    expect(
      resolveButtonType(theme, true, true, ButtonVariant.anchor),
      ButtonVariant.disabled,
    );
    expect(
      resolveButtonType(theme, false, true, ButtonVariant.anchor),
      ButtonVariant.flat,
    );
    expect(
      resolveButtonType(theme, false, false, ButtonVariant.anchor),
      ButtonVariant.primary,
    );
  });

  test('transparent overrides the RN palette fields only', () {
    const base = ThemeButtonStyle(
      backgroundColor: Color(0xFF2563EB),
      backgroundDarker: Color(0xFF1D4ED8),
      backgroundPlaceholder: Color(0xFF0F172A),
      backgroundShadow: Color(0x26000000),
      borderColor: Color(0xFF1E40AF),
      textColor: Colors.white,
      backgroundProgress: Color(0xFF1E3A8A),
    );

    final resolved = base.merge(transparentStyles);

    expect(resolved.backgroundColor, Colors.transparent);
    expect(resolved.backgroundDarker, Colors.transparent);
    expect(resolved.backgroundPlaceholder, Colors.transparent);
    expect(resolved.backgroundShadow, Colors.transparent);
    expect(resolved.borderColor, Colors.transparent);
    expect(resolved.textColor, Colors.white);
    expect(resolved.backgroundProgress, const Color(0xFF1E3A8A));
  });

  test(
      'missing backgroundActive falls back to a derived per-button active color',
      () {
    const backgroundColor = Color(0xFF46C578);
    final expected = Color.alphaBlend(
      const Color(0x14000000),
      backgroundColor,
    );
    final palette = getInterpolatablePalette(
      const ThemeButtonStyle(
        backgroundColor: backgroundColor,
      ),
    );

    expect(palette.backgroundActive, expected);
  });

  testWidgets('built-in themed colors map into the base button renderer', (
    tester,
  ) async {
    const buttonKey = Key('anchor-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.anchor,
          onPress: _noop,
          child: Text('Anchor'),
        ),
      ),
    );

    expect(faceColorOf(tester, buttonKey), const Color(0xFF46C578));
    expect(tester.getSize(shellFinderFor(buttonKey)).width, 200);
  });

  testWidgets('size presets override width, height, and typography', (
    tester,
  ) async {
    const buttonKey = Key('small-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          size: ButtonSize.small,
          onPress: _noop,
          child: Text('Small'),
        ),
      ),
    );

    expect(tester.getSize(shellFinderFor(buttonKey)).width, 120);
    expect(tester.getSize(faceFinderFor(buttonKey)).height, 44);

    final richText = tester.widget<RichText>(
      find
          .descendant(
            of: find.byKey(buttonKey),
            matching: find.byType(RichText),
          )
          .first,
    );
    expect(richText.text.style?.fontSize, 12);
  });

  testWidgets('autoWidth bypasses themed size width presets', (tester) async {
    const buttonKey = Key('auto-width-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        ThemedButton(
          key: buttonKey,
          config: buildMinimalTheme(),
          size: ButtonSize.large,
          autoWidth: true,
          onPress: _noop,
          child: const Text('Auto'),
        ),
      ),
    );

    final renderedWidth = tester.getSize(faceFinderFor(buttonKey)).width;
    expect(renderedWidth, lessThan(250));
    expect(renderedWidth, greaterThan(0));
  });

  testWidgets('caller overrides beat themed size and style defaults', (
    tester,
  ) async {
    const buttonKey = Key('override-themed-button');
    const overrideColor = Color(0xFF111827);

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          size: ButtonSize.small,
          width: 280,
          onPress: _noop,
          style: AwesomeButtonStyle(backgroundColor: overrideColor),
          child: Text('Override'),
        ),
      ),
    );

    expect(tester.getSize(shellFinderFor(buttonKey)).width, 280);
    expect(faceColorOf(tester, buttonKey), overrideColor);
  });

  testWidgets('social variants resolve from the built-in theme set', (
    tester,
  ) async {
    const buttonKey = Key('social-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.github,
          onPress: _noop,
          child: Text('GitHub'),
        ),
      ),
    );

    expect(faceColorOf(tester, buttonKey), const Color(0xFF2C3036));
  });

  testWidgets('same-theme type changes animate palette values', (tester) async {
    const buttonKey = Key('animated-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.primary,
          onPress: _noop,
          child: Text('Animated'),
        ),
      ),
    );

    final initialColor = faceColorOf(tester, buttonKey);

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.secondary,
          onPress: _noop,
          child: Text('Animated'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    final midTransitionColor = faceColorOf(tester, buttonKey);
    expect(midTransitionColor, isNot(initialColor));
    expect(midTransitionColor, isNot(Colors.white));

    await tester.pumpAndSettle();
    expect(faceColorOf(tester, buttonKey), Colors.white);
  });

  testWidgets('initial mount and theme-source changes snap to the new palette',
      (
    tester,
  ) async {
    const buttonKey = Key('theme-source-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.secondary,
          onPress: _noop,
          child: Text('Theme'),
        ),
      ),
    );

    expect(faceColorOf(tester, buttonKey), Colors.white);

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.bojack,
          type: ButtonVariant.primary,
          onPress: _noop,
          child: Text('Theme'),
        ),
      ),
    );

    expect(faceColorOf(tester, buttonKey), const Color(0xFF6678C5));
  });

  testWidgets('transparent changes do not animate the old palette', (
    tester,
  ) async {
    const buttonKey = Key('transparent-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.primary,
          onPress: _noop,
          child: Text('Transparent'),
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          type: ButtonVariant.primary,
          transparent: true,
          onPress: _noop,
          child: Text('Transparent'),
        ),
      ),
    );

    expect(faceColorOf(tester, buttonKey), Colors.transparent);
  });

  testWidgets(
      'themed placeholder uses backgroundPlaceholder and transparent clears it',
      (
    tester,
  ) async {
    const buttonKey = Key('themed-placeholder-button');

    await tester.pumpWidget(
      wrapForTest(
        ThemedButton(
          key: buttonKey,
          config: buildMinimalTheme(),
          onPress: _noop,
        ),
      ),
    );

    expect(placeholderColorOf(tester, buttonKey), const Color(0xFF0F172A));

    await tester.pumpWidget(
      wrapForTest(
        ThemedButton(
          key: buttonKey,
          config: buildMinimalTheme(),
          transparent: true,
          onPress: _noop,
        ),
      ),
    );

    expect(placeholderColorOf(tester, buttonKey), Colors.transparent);
  });

  testWidgets(
      'themed textTransition works for string children and bypasses widget children',
      (
    tester,
  ) async {
    const buttonKey = Key('themed-text-transition-button');

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          textTransition: true,
          child: 'Go#3',
        ),
      ),
    );

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          textTransition: true,
          child: 'Mission#42',
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 48));

    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(buttonKey),
              matching:
                  find.byKey(const ValueKey<String>('aws-btn-content-text')),
            ),
          )
          .data,
      isNot('Mission#42'),
    );

    await tester.pumpWidget(
      wrapForTest(
        const ThemedButton(
          key: buttonKey,
          name: ThemeName.basic,
          textTransition: true,
          child: Text('Widget label'),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byKey(const ValueKey<String>('aws-btn-content-text')),
      ),
      findsNothing,
    );
    expect(find.text('Widget label'), findsOneWidget);
  });

  testWidgets(
      'themed activityColor, progress fill, active background, and typography reach the core renderer',
      (
    tester,
  ) async {
    const buttonKey = Key('integrated-themed-button');
    final customTheme = buildMinimalTheme();

    await tester.pumpWidget(
      wrapForTest(
        ThemedButton(
          key: buttonKey,
          config: customTheme,
          progress: true,
          onPress: ([next]) {},
          child: const Text('Theme'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );
    await tester.pump();

    expect(
      activeBackgroundColorOf(tester, buttonKey),
      const Color(0xFF1E3A8A),
    );

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(progressFillColorOf(tester, buttonKey), const Color(0xFF1E40AF));

    final spinner = tester.widget<CircularProgressIndicator>(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(CircularProgressIndicator),
      ),
    );
    final spinnerColor =
        (spinner.valueColor as AlwaysStoppedAnimation<Color?>).value;
    expect(spinnerColor, const Color(0xFFFACC15));

    final richText = tester.widget<RichText>(
      find
          .descendant(
            of: find.byKey(buttonKey),
            matching: find.byType(RichText),
          )
          .first,
    );
    expect(richText.text.style?.fontSize, 16);
    expect(richText.text.style?.fontFamily, 'ThemedFont');
    expect(richText.text.style?.height, closeTo(24 / 16, 0.001));
  });

  testWidgets(
      'themed showProgressBar false forwards spinner-only progress mode', (
    tester,
  ) async {
    const buttonKey = Key('spinner-only-themed-button');

    await tester.pumpWidget(
      wrapForTest(
        ThemedButton(
          key: buttonKey,
          config: buildMinimalTheme(),
          progress: true,
          showProgressBar: false,
          onPress: ([next]) {},
          child: const Text('Theme'),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(faceFinderFor(buttonKey)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      find.descendant(
        of: find.byKey(buttonKey),
        matching:
            find.byKey(const ValueKey<String>('aws-btn-progress-overlay')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(buttonKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(activeBackgroundOpacityOf(tester, buttonKey), 0);
  });
}

void _noop([AwesomeButtonNext? _]) {}

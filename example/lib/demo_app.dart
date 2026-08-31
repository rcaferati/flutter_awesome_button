import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

part 'demo_icons.dart';

double _performHeavyLoad(int durationMs) {
  final stopwatch = Stopwatch()..start();
  var accumulator = 0.0;
  var iteration = 1;

  while (stopwatch.elapsedMilliseconds < durationMs) {
    final operand = (iteration % 360) + 1;
    accumulator += (operand * operand) / ((iteration % 97) + 1);
    iteration += 1;
  }

  return accumulator;
}

Color _demoButtonForeground(
  RegisteredThemeDefinition theme,
  ButtonVariant variant,
) {
  return theme.buttons[variant]?.textColor ?? theme.color;
}

Widget _navigationDemoIcon(BuildContext context, _DemoIconName name) {
  return _DemoIcon(
    name: name,
    size: 21,
    color: IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Example app used to demonstrate the package gallery and behaviors.
class AwesomeButtonExampleApp extends StatelessWidget {
  /// Creates the example application widget.
  const AwesomeButtonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rcaferati_flutter_awesome_button',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF038CD9)),
      ),
      home: const _DemoShell(),
    );
  }
}

class _DemoShell extends StatefulWidget {
  const _DemoShell();

  @override
  State<_DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<_DemoShell> {
  static const Color _secondaryHeaderColor = Color(0xFF4F6FC4);
  static const Color _secondaryHeaderForeground = Colors.white;

  final GlobalKey<_ThemeTabNavigatorState> _themeTabKey =
      GlobalKey<_ThemeTabNavigatorState>();
  var _selectedTabIndex = 0;
  var _themeIndex = 0;

  void _handleThemeIndexChanged(int index) {
    if (_themeIndex == index) {
      return;
    }

    setState(() {
      _themeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = getTheme(index: _themeIndex);

    return Scaffold(
      appBar: switch (_selectedTabIndex) {
        0 => _AnimatedThemedAppBar(
            theme: theme,
            onPrev: () => _themeTabKey.currentState?.popTheme(),
            onNext: () => _themeTabKey.currentState?.pushNextTheme(),
          ),
        1 => AppBar(
            title: const Text('Progress Buttons'),
            backgroundColor: _secondaryHeaderColor,
            foregroundColor: _secondaryHeaderForeground,
          ),
        2 => AppBar(
            title: const Text('Social Buttons'),
            backgroundColor: _secondaryHeaderColor,
            foregroundColor: _secondaryHeaderForeground,
          ),
        _ => AppBar(
            title: const Text('Size Changes'),
            backgroundColor: _secondaryHeaderColor,
            foregroundColor: _secondaryHeaderForeground,
          ),
      },
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _ThemeTabNavigator(
            key: _themeTabKey,
            onThemeIndexChanged: _handleThemeIndexChanged,
          ),
          const _ProgressScreen(),
          const _SocialScreen(),
          const _SizingScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedTabIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Builder(
                builder: (context) =>
                    _navigationDemoIcon(context, _DemoIconName.paintbrush),
              ),
              label: 'Themed',
            ),
            NavigationDestination(
              icon: Builder(
                builder: (context) =>
                    _navigationDemoIcon(context, _DemoIconName.gauge),
              ),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Builder(
                builder: (context) =>
                    _navigationDemoIcon(context, _DemoIconName.shareNodes),
              ),
              label: 'Social',
            ),
            NavigationDestination(
              icon: Builder(
                builder: (context) =>
                    _navigationDemoIcon(context, _DemoIconName.sizeChanges),
              ),
              label: 'Size Changes',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedThemedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AnimatedThemedAppBar({
    required this.theme,
    required this.onPrev,
    required this.onNext,
  });

  static const Duration _transitionDuration = Duration(milliseconds: 240);
  static const double _headerButtonSlotWidth = 88;

  final RegisteredThemeDefinition theme;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: theme.background),
      duration: _transitionDuration,
      builder: (context, backgroundColor, _) {
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: theme.color),
          duration: _transitionDuration,
          builder: (context, foregroundColor, _) {
            final resolvedBackground = backgroundColor ?? theme.background;
            final resolvedForeground = foregroundColor ?? theme.color;

            return Material(
              color: resolvedBackground,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _headerButtonSlotWidth,
                          child: theme.prev
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: _ThemeHeaderButton(
                                    label: 'Prev',
                                    theme: theme,
                                    foregroundColor: resolvedForeground,
                                    onPress: onPrev,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              theme.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: resolvedForeground),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _headerButtonSlotWidth,
                          child: theme.next
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: _ThemeHeaderButton(
                                    label: 'Next',
                                    theme: theme,
                                    foregroundColor: resolvedForeground,
                                    onPress: onNext,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ThemeHeaderButton extends StatelessWidget {
  const _ThemeHeaderButton({
    required this.label,
    required this.theme,
    required this.foregroundColor,
    required this.onPress,
  });

  final String label;
  final RegisteredThemeDefinition theme;
  final Color foregroundColor;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ThemedButton(
      size: ButtonSize.small,
      config: theme,
      type: ButtonVariant.flat,
      activeOpacity: 0.6,
      debouncedPressTime: const Duration(milliseconds: 875),
      width: 80,
      style: AwesomeButtonStyle(
        foregroundColor: foregroundColor,
        backgroundActive: const Color.fromRGBO(0, 0, 0, 0.05),
      ),
      onPress: ([next]) => onPress(),
      child: label,
    );
  }
}

class _ThemeTabNavigator extends StatefulWidget {
  const _ThemeTabNavigator({super.key, required this.onThemeIndexChanged});

  final ValueChanged<int> onThemeIndexChanged;

  @override
  State<_ThemeTabNavigator> createState() => _ThemeTabNavigatorState();
}

class _ThemeTabNavigatorState extends State<_ThemeTabNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<int> _themeStack = <int>[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onThemeIndexChanged(_themeStack.last);
    });
  }

  void pushNextTheme() {
    final currentTheme = getTheme(index: _themeStack.last);
    if (!currentTheme.next) {
      return;
    }

    setState(() {
      _themeStack.add(_themeStack.last + 1);
    });
    widget.onThemeIndexChanged(_themeStack.last);
  }

  void popTheme() {
    if (_themeStack.length <= 1) {
      return;
    }
    _navigatorKey.currentState?.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      pages: [
        for (final index in _themeStack)
          MaterialPage<void>(
            key: ValueKey<String>('theme-$index'),
            name: 'theme/$index',
            child: _ThemedButtonsScreen(index: index),
          ),
      ],
      onDidRemovePage: (page) {
        if (_themeStack.length > 1) {
          setState(() {
            _themeStack.removeLast();
          });
          widget.onThemeIndexChanged(_themeStack.last);
        }
      },
    );
  }
}

class _ThemedButtonsScreen extends StatefulWidget {
  const _ThemedButtonsScreen({required this.index});

  final int index;

  @override
  State<_ThemedButtonsScreen> createState() => _ThemedButtonsScreenState();
}

class _ThemedButtonsScreenState extends State<_ThemedButtonsScreen> {
  static const List<ButtonVariant> _transitionVariants = <ButtonVariant>[
    ButtonVariant.primary,
    ButtonVariant.secondary,
    ButtonVariant.anchor,
    ButtonVariant.danger,
  ];
  static const List<String> _textTransitionLabels = <String>[
    'welcome',
    'Level 2',
    'Mission#42',
    'Go#3',
  ];
  static const List<String> _sizeTransitionLabels = <String>[
    'Launch',
    'View analytics dashboard',
  ];
  static const Duration _heavyLoadDuration = Duration(milliseconds: 900);

  var _transitionVariantIndex = 0;
  var _textTransitionIndex = 0;
  var _sizeTransitionIndex = 0;

  RegisteredThemeDefinition get _theme => getTheme(index: widget.index);

  ButtonVariant get _transitionVariant =>
      _transitionVariants[_transitionVariantIndex];

  String get _textTransitionLabel =>
      _textTransitionLabels[_textTransitionIndex];

  String get _sizeTransitionLabel =>
      _sizeTransitionLabels[_sizeTransitionIndex];

  void _handleTimeout([AwesomeButtonNext? next]) {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        next?.call();
      }),
    );
  }

  void _handleVariantTransitionPress([AwesomeButtonNext? _]) {
    setState(() {
      _transitionVariantIndex =
          (_transitionVariantIndex + 1) % _transitionVariants.length;
    });
  }

  void _handleTextTransitionPress([AwesomeButtonNext? _]) {
    setState(() {
      _textTransitionIndex =
          (_textTransitionIndex + 1) % _textTransitionLabels.length;
    });
  }

  void _handleSizeTransitionPress([AwesomeButtonNext? _]) {
    setState(() {
      _sizeTransitionIndex =
          (_sizeTransitionIndex + 1) % _sizeTransitionLabels.length;
    });
  }

  void _handleHeavyStretchProgressPress([AwesomeButtonNext? next]) {
    unawaited(_runHeavyStretchProgress(next));
  }

  Future<void> _runHeavyStretchProgress(AwesomeButtonNext? next) async {
    await compute(_performHeavyLoad, _heavyLoadDuration.inMilliseconds);

    if (!mounted) {
      return;
    }

    next?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final primaryColor = theme.buttons[ButtonVariant.primary]?.backgroundColor;
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: ColoredBox(color: pageBackground)),
        _ThemeCharacterOverlay(themeName: theme.name),
        Positioned.fill(
          child: _DemoContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DemoSection(
                  title: 'Common',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                        child: 'Primary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.secondary,
                        child: 'Secondary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.anchor,
                        child: 'Anchor',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.danger,
                        child: 'Danger',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        disabled: true,
                        type: ButtonVariant.primary,
                        child: 'Disabled',
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Progress',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.primary,
                        child: 'Primary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.secondary,
                        child: 'Secondary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.anchor,
                        child: 'Anchor',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.danger,
                        child: 'Danger',
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Variant Transition',
                  children: [
                    _sectionButton(
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ThemedButton(
                            name: theme.name,
                            type: _transitionVariant,
                            child: _transitionVariant.name,
                          ),
                          ThemedButton(
                            name: theme.name,
                            type: ButtonVariant.flat,
                            size: ButtonSize.icon,
                            accessibilityLabel: 'Cycle variant',
                            onPress: _handleVariantTransitionPress,
                            child: _DemoIcon(
                              name: _DemoIconName.rightLeft,
                              size: 18,
                              color: primaryColor ?? theme.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Text Transition',
                  children: [
                    _sectionButton(
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ThemedButton(
                            config: theme,
                            textTransition: true,
                            type: ButtonVariant.primary,
                            child: _textTransitionLabel,
                          ),
                          ThemedButton(
                            config: theme,
                            type: ButtonVariant.flat,
                            size: ButtonSize.icon,
                            accessibilityLabel: 'Cycle text',
                            onPress: _handleTextTransitionPress,
                            child: _DemoIcon(
                              name: _DemoIconName.forwardStep,
                              size: 18,
                              color: primaryColor ?? theme.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Size Transition',
                  children: [
                    _sectionButton(
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ThemedButton(
                            config: theme,
                            autoWidth: true,
                            textTransition: true,
                            type: ButtonVariant.primary,
                            child: _sizeTransitionLabel,
                          ),
                          ThemedButton(
                            config: theme,
                            type: ButtonVariant.flat,
                            size: ButtonSize.icon,
                            accessibilityLabel: 'Cycle size',
                            onPress: _handleSizeTransitionPress,
                            child: _DemoIcon(
                              name: _DemoIconName.forwardStep,
                              size: 18,
                              color: primaryColor ?? theme.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Empty Placeholder',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.secondary,
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.anchor,
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.danger,
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Flat Buttons',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        style: const AwesomeButtonStyle(raiseAmount: 0),
                        activeOpacity: 0.75,
                        type: ButtonVariant.primary,
                        child: 'Primary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        style: const AwesomeButtonStyle(raiseAmount: 0),
                        activeOpacity: 0.75,
                        type: ButtonVariant.secondary,
                        child: 'Secondary',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        style: const AwesomeButtonStyle(raiseAmount: 0),
                        activeOpacity: 0.75,
                        type: ButtonVariant.anchor,
                        child: 'Anchor',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        style: const AwesomeButtonStyle(raiseAmount: 0),
                        activeOpacity: 0.75,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.danger,
                        child: 'Danger',
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'Before / After / Icon',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                        style: const AwesomeButtonStyle(contentGap: 8),
                        before: _DemoIcon(
                          name: _DemoIconName.bars,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.primary,
                          ),
                        ),
                        child: 'Button Icon',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.anchor,
                        style: const AwesomeButtonStyle(contentGap: 8),
                        after: _DemoIcon(
                          name: _DemoIconName.tableCellsLarge,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.anchor,
                          ),
                        ),
                        child: 'Button Icon',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.danger,
                        style: const AwesomeButtonStyle(contentGap: 8),
                        before: _DemoIcon(
                          name: _DemoIconName.trashCan,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.danger,
                          ),
                        ),
                        child: 'Button Icon',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                        size: ButtonSize.icon,
                        accessibilityLabel: 'Add',
                        child: _DemoIcon(
                          name: _DemoIconName.squarePlus,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.primary,
                          ),
                        ),
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.anchor,
                        size: ButtonSize.icon,
                        accessibilityLabel: 'Add user',
                        child: _DemoIcon(
                          name: _DemoIconName.userPlus,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.anchor,
                          ),
                        ),
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        progress: true,
                        onPress: _handleTimeout,
                        type: ButtonVariant.danger,
                        size: ButtonSize.icon,
                        accessibilityLabel: 'Delete',
                        child: _DemoIcon(
                          name: _DemoIconName.trashCan,
                          size: 24,
                          color: _demoButtonForeground(
                            theme,
                            ButtonVariant.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _DemoSection(
                  title: 'With auto and stretch',
                  children: [
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                        autoWidth: true,
                        child: 'Primary Auto',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.secondary,
                        size: ButtonSize.small,
                        autoWidth: true,
                        child: 'Secondary Small Auto',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.anchor,
                        size: ButtonSize.large,
                        autoWidth: true,
                        child: 'Anchor Large Auto',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.danger,
                        size: ButtonSize.large,
                        stretch: true,
                        child: 'Primary Large Stretch',
                      ),
                    ),
                    _sectionButton(
                      ThemedButton(
                        config: theme,
                        type: ButtonVariant.primary,
                        size: ButtonSize.large,
                        progress: true,
                        stretch: true,
                        onPress: _handleHeavyStretchProgressPress,
                        child: 'Stretch Progress + Heavy Load',
                      ),
                    ),
                    Text(
                      'This demo runs CPU-heavy work on a background isolate so the progress UI stays responsive while the task completes.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressScreen extends StatelessWidget {
  const _ProgressScreen();

  void _handleTimeout([AwesomeButtonNext? next]) {
    unawaited(
      Future<void>.delayed(const Duration(seconds: 1), () {
        next?.call();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeName = ThemeName.bojack;
    final theme = getTheme(name: themeName);
    final primaryForeground =
        _demoButtonForeground(theme, ButtonVariant.primary);

    return _DemoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DemoSection(
            title: 'Labeled Buttons',
            children: [
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  width: 200,
                  child: 'Progress',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  width: 200,
                  progressLoadingTime: const Duration(milliseconds: 6000),
                  child: 'Slower',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  showProgressBar: false,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  width: 200,
                  child: 'No Bar',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  width: 200,
                  style: const AwesomeButtonStyle(
                    raiseAmount: 0,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: 'Flat Progress',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  size: ButtonSize.icon,
                  style: const AwesomeButtonStyle(
                    raiseAmount: 6,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  accessibilityLabel: 'Send',
                  child: _DemoIcon(
                    name: _DemoIconName.locationArrow,
                    size: 24,
                    color: primaryForeground,
                  ),
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.primary,
                  size: ButtonSize.icon,
                  style: const AwesomeButtonStyle(
                    raiseAmount: 0,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  accessibilityLabel: 'Facebook',
                  child: _DemoIcon(
                    name: _DemoIconName.facebook,
                    size: 24,
                    color: primaryForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialScreen extends StatelessWidget {
  const _SocialScreen();

  void _handleTimeout([AwesomeButtonNext? next]) {
    unawaited(
      Future<void>.delayed(const Duration(seconds: 1), () {
        next?.call();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    const themeName = ThemeName.bojack;
    final theme = getTheme(name: themeName);

    return _DemoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DemoSection(
            title: 'Labeled Buttons',
            children: [
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.facebook,
                  width: 180,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    raiseAmount: 8,
                    contentGap: 8,
                  ),
                  accessibilityLabel: 'Facebook',
                  before: _DemoIcon(
                    name: _DemoIconName.facebook,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.facebook,
                    ),
                  ),
                  child: 'Facebook',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.x,
                  width: 180,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    raiseAmount: 8,
                    contentGap: 8,
                  ),
                  accessibilityLabel: 'X',
                  before: _DemoIcon(
                    name: _DemoIconName.x,
                    size: 24,
                    color: _demoButtonForeground(theme, ButtonVariant.x),
                  ),
                  child: 'X',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.messenger,
                  width: 180,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.zero,
                    raiseAmount: 6,
                    contentGap: 8,
                  ),
                  accessibilityLabel: 'Messenger',
                  before: _DemoIcon(
                    name: _DemoIconName.messenger,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.messenger,
                    ),
                  ),
                  child: 'Messenger',
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  width: 180,
                  style: const AwesomeButtonStyle(
                    depthColor: Color(0xFFEAAC1E),
                    backgroundActive: Color.fromRGBO(0, 0, 0, 0.15),
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.15),
                    backgroundProgress: Color.fromRGBO(0, 0, 0, 0.15),
                    contentGap: 8,
                  ),
                  extra: const SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4C63D2),
                            Color(0xFFBC3081),
                            Color(0xFFF47133),
                            Color(0xFFFED576),
                          ],
                        ),
                      ),
                    ),
                  ),
                  accessibilityLabel: 'Instagram',
                  before: _DemoIcon(
                    name: _DemoIconName.instagram,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.primary,
                    ),
                  ),
                  child: 'Instagram',
                ),
              ),
            ],
          ),
          _DemoSection(
            title: 'Iconed Buttons',
            children: [
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.whatsapp,
                  width: 60,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.zero,
                    raiseAmount: 0,
                  ),
                  accessibilityLabel: 'WhatsApp',
                  child: _DemoIcon(
                    name: _DemoIconName.whatsapp,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.whatsapp,
                    ),
                  ),
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.youtube,
                  width: 60,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.zero,
                    raiseAmount: 8,
                  ),
                  accessibilityLabel: 'YouTube',
                  child: _DemoIcon(
                    name: _DemoIconName.youtube,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.youtube,
                    ),
                  ),
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.linkedin,
                  width: 60,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    raiseAmount: 8,
                  ),
                  accessibilityLabel: 'LinkedIn',
                  child: _DemoIcon(
                    name: _DemoIconName.linkedin,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.linkedin,
                    ),
                  ),
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: themeName,
                  progress: true,
                  onPress: _handleTimeout,
                  type: ButtonVariant.pinterest,
                  width: 60,
                  height: 60,
                  style: const AwesomeButtonStyle(
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                    raiseAmount: 8,
                  ),
                  accessibilityLabel: 'Pinterest',
                  child: _DemoIcon(
                    name: _DemoIconName.pinterest,
                    size: 24,
                    color: _demoButtonForeground(
                      theme,
                      ButtonVariant.pinterest,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizingScreen extends StatefulWidget {
  const _SizingScreen();

  @override
  State<_SizingScreen> createState() => _SizingScreenState();
}

class _SizingScreenState extends State<_SizingScreen> {
  static const List<ButtonSize> _themeSizes = <ButtonSize>[
    ButtonSize.small,
    ButtonSize.medium,
    ButtonSize.large,
  ];
  static const TextStyle _captionStyle = TextStyle(
    color: Color(0xFF5B6472),
    fontSize: 13,
    height: 20 / 13,
  );
  static const TextStyle _variantLabelStyle = TextStyle(
    color: Color(0xFF6B7280),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  var _isLongLabel = false;
  var _sizeIndex = 1;

  ButtonSize get _currentThemeSize => _themeSizes[_sizeIndex];

  String get _autoWidthLabel =>
      _isLongLabel ? 'View analytics dashboard' : 'Launch';

  String get _currentThemeSizeLabel {
    final name = _currentThemeSize.name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  void _toggleAutoWidthLabel([AwesomeButtonNext? _]) {
    setState(() {
      _isLongLabel = !_isLongLabel;
    });
  }

  void _cycleThemeSize([AwesomeButtonNext? _]) {
    setState(() {
      _sizeIndex = (_sizeIndex + 1) % _themeSizes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _DemoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DemoSection(
            title: 'Auto Width String Change',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Evaluates how the button reacts when a plain string label switches between short and long content.',
                  style: _captionStyle,
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.secondary,
                  size: ButtonSize.small,
                  autoWidth: true,
                  style: const AwesomeButtonStyle(raiseAmount: 0),
                  activeOpacity: 0.6,
                  onPress: _toggleAutoWidthLabel,
                  child: 'Toggle Label Length',
                ),
              ),
              const _SizingVariantLabel('Animated with text transition'),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.anchor,
                  autoWidth: true,
                  textTransition: true,
                  child: _autoWidthLabel,
                ),
              ),
              const _SizingVariantLabel('Animated without text transition'),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.anchor,
                  autoWidth: true,
                  child: _autoWidthLabel,
                ),
              ),
              const _SizingVariantLabel('Instant opt-out'),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.anchor,
                  autoWidth: true,
                  animateSize: false,
                  child: _autoWidthLabel,
                ),
              ),
            ],
          ),
          _DemoSection(
            title: 'Themed Fixed Size Change',
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Evaluates how a themed button behaves when its built-in size preset changes between fixed widths.',
                  style: _captionStyle,
                ),
              ),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.secondary,
                  size: ButtonSize.small,
                  autoWidth: true,
                  style: const AwesomeButtonStyle(raiseAmount: 0),
                  activeOpacity: 0.6,
                  onPress: _cycleThemeSize,
                  child: 'Cycle Theme Size',
                ),
              ),
              const _SizingVariantLabel('Animated with text transition'),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.danger,
                  size: _currentThemeSize,
                  textTransition: true,
                  child: _currentThemeSizeLabel,
                ),
              ),
              const _SizingVariantLabel('Animated without text transition'),
              _sectionButton(
                ThemedButton(
                  name: ThemeName.bruce,
                  type: ButtonVariant.danger,
                  size: _currentThemeSize,
                  child: _currentThemeSizeLabel,
                ),
              ),
              const _SizingVariantLabel('Instant opt-out'),
              _sectionButton(
                ThemedButton(
                  animateSize: false,
                  name: ThemeName.bruce,
                  type: ButtonVariant.danger,
                  size: _currentThemeSize,
                  child: _currentThemeSizeLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizingVariantLabel extends StatelessWidget {
  const _SizingVariantLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: _SizingScreenState._variantLabelStyle,
      ),
    );
  }
}

class _DemoContainer extends StatelessWidget {
  const _DemoContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 30, bottom: 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: child,
        ),
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.6,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF444444), width: 0.5),
                ),
              ),
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF444444),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeCharacterOverlay extends StatefulWidget {
  const _ThemeCharacterOverlay({required this.themeName});

  final ThemeName themeName;

  static const Map<ThemeName, _ThemeCharacterConfig> _characters =
      <ThemeName, _ThemeCharacterConfig>{
    ThemeName.bojack: _ThemeCharacterConfig(
      assetPath: 'assets/characters/bojack.png',
      width: 492 / 2,
      height: 696 / 2,
      x: 42,
      y: 0,
    ),
    ThemeName.rick: _ThemeCharacterConfig(
      assetPath: 'assets/characters/rick.png',
      width: 547 / 2,
      height: 768 / 2,
      x: 90,
      y: 0,
    ),
    ThemeName.c137: _ThemeCharacterConfig(
      assetPath: 'assets/characters/c137.png',
      width: 416 / 2,
      height: 639 / 2,
      x: 40,
      y: 0,
    ),
    ThemeName.cartman: _ThemeCharacterConfig(
      assetPath: 'assets/characters/cartman.png',
      width: 640 / 2,
      height: 590 / 2,
      x: 70,
      y: 0,
    ),
    ThemeName.bruce: _ThemeCharacterConfig(
      assetPath: 'assets/characters/batman.png',
      width: 1280 / 3.5,
      height: 1538 / 3.5,
      x: 90,
      y: -25,
    ),
    ThemeName.mysterion: _ThemeCharacterConfig(
      assetPath: 'assets/characters/mysterion.png',
      width: 640 / 2,
      height: 590 / 2,
      x: 70,
      y: 0,
    ),
    ThemeName.summer: _ThemeCharacterConfig(
      assetPath: 'assets/characters/summer.png',
      width: 395 / 2,
      height: 727 / 2,
      x: 30,
      y: -10,
    ),
  };

  @override
  State<_ThemeCharacterOverlay> createState() => _ThemeCharacterOverlayState();
}

class _ThemeCharacterOverlayState extends State<_ThemeCharacterOverlay>
    with SingleTickerProviderStateMixin {
  static const Duration _enterDelay = Duration(milliseconds: 185);
  static const double _springTension = 100;
  static const double _springFriction = 6.75;
  static const double _initialOffsetX = 200;
  static final SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: _origamiTensionToStiffness(_springTension),
    damping: _origamiFrictionToDamping(_springFriction),
  );

  late final AnimationController _controller;
  Timer? _startTimer;

  _ThemeCharacterConfig? get _config =>
      _ThemeCharacterOverlay._characters[widget.themeName];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: _initialOffsetX,
    );
    _scheduleEnterAnimation();
  }

  @override
  void didUpdateWidget(covariant _ThemeCharacterOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeName == widget.themeName) {
      return;
    }

    _controller.value = _initialOffsetX;
    _scheduleEnterAnimation();
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleEnterAnimation() {
    _startTimer?.cancel();
    final config = _config;
    if (config == null) {
      return;
    }

    _startTimer = Timer(_enterDelay, () {
      if (!mounted) {
        return;
      }

      _controller.animateWith(
        SpringSimulation(
          _spring,
          _controller.value,
          config.x,
          0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    if (config == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: config.y,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_controller.value, 0),
              child: child,
            );
          },
          child: Image.asset(
            key: ValueKey<String>('character-${widget.themeName.name}'),
            config.assetPath,
            width: config.width,
            height: config.height,
          ),
        ),
      ),
    );
  }
}

class _ThemeCharacterConfig {
  const _ThemeCharacterConfig({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
  });

  final String assetPath;
  final double width;
  final double height;
  final double x;
  final double y;
}

double _origamiTensionToStiffness(double tension) {
  return (tension - 30.0) * 3.62 + 194.0;
}

double _origamiFrictionToDamping(double friction) {
  return (friction - 8.0) * 3.0 + 25.0;
}

Widget _sectionButton(Widget child) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: child,
  );
}

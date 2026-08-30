import 'package:flutter/material.dart';

import 'colors.dart';
import 'models.dart';

const _defaultThemeName = ThemeName.basic;
const _themeOrder = <ThemeName>[
  ThemeName.basic,
  ThemeName.bojack,
  ThemeName.cartman,
  ThemeName.mysterion,
  ThemeName.c137,
  ThemeName.rick,
  ThemeName.summer,
  ThemeName.bruce,
];

ThemeButtonStyle _flatStyle() {
  return const ThemeButtonStyle(
    backgroundColor: Colors.transparent,
    backgroundDarker: Colors.transparent,
    backgroundShadow: Colors.transparent,
    raiseLevel: 0,
    borderRadius: 0,
  );
}

Map<ButtonVariant, ThemeButtonStyle> _createSocialTypes(
    ThemeButtonStyle common) {
  return {
    ButtonVariant.x: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF00ACED),
        backgroundDarker: Color(0xFF0096CF),
      ),
    ),
    ButtonVariant.messenger: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF3186F6),
        backgroundDarker: Color(0xFF2566BC),
      ),
    ),
    ButtonVariant.facebook: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF4868AD),
        backgroundDarker: Color(0xFF325194),
      ),
    ),
    ButtonVariant.github: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF2C3036),
        backgroundDarker: Color(0xFF060708),
      ),
    ),
    ButtonVariant.linkedin: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF0077B5),
        backgroundDarker: Color(0xFF005885),
      ),
    ),
    ButtonVariant.whatsapp: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFF25D366),
        backgroundDarker: Color(0xFF14A54B),
      ),
    ),
    ButtonVariant.reddit: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFFFC461E),
        backgroundDarker: Color(0xFFD52802),
      ),
    ),
    ButtonVariant.pinterest: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFFBD091C),
        backgroundDarker: Color(0xFF980313),
      ),
    ),
    ButtonVariant.youtube: common.merge(
      const ThemeButtonStyle(
        backgroundColor: Color(0xFFCC181E),
        backgroundDarker: Color(0xFFAB0D12),
      ),
    ),
  };
}

final _basicTheme = () {
  const common = ThemeButtonStyle(
    borderRadius: 8,
    height: 60,
    raiseLevel: 12,
  );
  final socialTypes = _createSocialTypes(common);
  const primary = Color(0xFF4688C5);
  const anchor = Color(0xFF46C578);
  const danger = Color(0xFFB13A3A);

  return ThemeDefinition(
    title: 'Basic Theme',
    background: const Color(0xFF1775C8),
    color: Colors.white,
    buttons: {
      ButtonVariant.primary: ThemeButtonStyle(
        borderRadius: common.borderRadius,
        height: common.height,
        raiseLevel: common.raiseLevel,
        backgroundColor: primary,
        backgroundDarker: blendColors(-0.5, primary),
        backgroundActive: blendColors(-0.3, primary),
        backgroundProgress: blendColors(-0.65, primary),
        textColor: Colors.white,
        activityColor: const Color(0xFFB3E5E1),
      ),
      ButtonVariant.secondary: ThemeButtonStyle(
        borderRadius: common.borderRadius,
        height: common.height,
        raiseLevel: common.raiseLevel,
        backgroundColor: Colors.white,
        backgroundDarker: blendColors(-0.1, primary),
        backgroundActive: blendColors(0.85, primary),
        backgroundProgress: const Color(0xFFC8E3F5),
        backgroundPlaceholder: const Color(0xFF1E88E5),
        textColor: const Color(0xFF1E88E5),
        borderWidth: 1,
        borderColor: const Color(0xFF1E88E5),
        activityColor: const Color(0xFF1E88E5),
      ),
      ButtonVariant.anchor: ThemeButtonStyle(
        borderRadius: common.borderRadius,
        height: common.height,
        raiseLevel: common.raiseLevel,
        backgroundColor: anchor,
        backgroundDarker: blendColors(-0.5, anchor),
        backgroundProgress: blendColors(-0.65, anchor),
        textColor: Colors.white,
        activityColor: Colors.white,
      ),
      ButtonVariant.danger: ThemeButtonStyle(
        borderRadius: common.borderRadius,
        height: common.height,
        raiseLevel: common.raiseLevel,
        backgroundColor: danger,
        backgroundDarker: blendColors(-0.5, danger),
        backgroundProgress: blendColors(-0.65, danger),
        textColor: Colors.white,
        activityColor: Colors.white,
      ),
      ButtonVariant.disabled: ThemeButtonStyle(
        borderRadius: common.borderRadius,
        height: common.height,
        raiseLevel: common.raiseLevel,
        backgroundColor: const Color(0xFFDFDFDF),
        backgroundDarker: const Color(0xFFCACACA),
        textColor: const Color(0xFFB6B6B6),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 60,
        height: 60,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 44,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 60),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _bojackTheme = () {
  const blue = Color(0xFF6678C5);
  const grey = Color(0xFF848289);
  const pink = Color(0xFFEBA0BD);
  const teal = Color(0xFF3EB7B9);
  const white = Colors.white;
  const common = ThemeButtonStyle(
    borderRadius: 4,
    height: 55,
    activityColor: white,
    textColor: white,
    raiseLevel: 6,
    paddingHorizontal: 20,
  );
  final socialTypes = _createSocialTypes(common);

  return ThemeDefinition(
    title: 'Bojack Theme',
    background: const Color(0xFF4F6FC4),
    color: Colors.white,
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: blue,
          backgroundDarker: blendColors(-0.3, blue),
          backgroundProgress: const Color(0xFF2A4284),
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: grey,
          backgroundDarker: blendColors(-0.3, grey),
          backgroundProgress: const Color(0xFF3F3F3F),
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: teal,
          backgroundDarker: blendColors(-0.3, teal),
          backgroundProgress: blendColors(-0.6, teal),
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: blendColors(-0.1, pink),
          backgroundDarker: blendColors(-0.3, pink),
          backgroundProgress: blendColors(-0.5, pink),
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFDFDFDF),
          backgroundDarker: Color(0xFFCACACA),
          textColor: Color(0xFFB6B6B6),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _cartmanTheme = () {
  const common = ThemeButtonStyle(
    borderRadius: 8,
    height: 55,
    activityColor: Color(0xFFFFE11D),
    raiseLevel: 8,
  );
  final socialTypes = _createSocialTypes(common);
  const blue = Color(0xFF00B8C4);
  const red = Color(0xFFDB4557);
  const yellow = Color(0xFFFDF353);
  const brown = Color(0xFF876753);
  const dark = Color(0xFF2D2D3A);

  return ThemeDefinition(
    title: 'Cartman Theme',
    background: const Color(0xFFEE3253),
    color: yellow,
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: blue,
          backgroundDarker: blendColors(-0.35, yellow),
          textColor: yellow,
          borderWidth: 2,
          borderColor: yellow,
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: red,
          backgroundDarker: blendColors(-0.35, yellow),
          textColor: yellow,
          borderWidth: 2,
          borderColor: blendColors(-0.1, yellow),
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: dark,
          backgroundDarker: blendColors(-0.3, brown),
          textColor: blendColors(0.1, brown),
          backgroundProgress: blendColors(0.025, dark),
          borderWidth: 2,
          borderColor: brown,
          activityColor: blendColors(0.1, brown),
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: blendColors(-0.1, dark),
          backgroundDarker: blendColors(-0.5, red),
          backgroundProgress: blendColors(0.025, dark),
          textColor: red,
          borderColor: red,
          borderWidth: 2,
          activityColor: blendColors(0.1, red),
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFDFDFDF),
          backgroundDarker: Color(0xFFCACACA),
          textColor: Color(0xFFB6B6B6),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _mysterionTheme = () {
  const common = ThemeButtonStyle(
    borderRadius: 24,
    height: 55,
    activityColor: Colors.white,
    raiseLevel: 8,
  );
  final socialTypes = _createSocialTypes(common);
  const primary = Color(0xFF463856);
  const secondary = Color(0xFF9A8C9D);
  const anchor = Color(0xFF749743);
  const anchorBorder = Color(0xFF678A37);
  const danger = Color(0xFFDB4557);
  const yellow = Color(0xFFFDF353);

  return ThemeDefinition(
    title: 'Mysterion Theme',
    background: primary,
    color: Colors.white,
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: primary,
          backgroundDarker: blendColors(-0.85, primary),
          textColor: Colors.white,
          borderWidth: 1,
          borderColor: primary,
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: secondary,
          backgroundDarker: blendColors(-0.6218, secondary),
          textColor: Colors.white,
          borderWidth: 1,
          borderColor: secondary,
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: anchor,
          backgroundDarker: blendColors(-0.6218, anchor),
          textColor: Colors.white,
          borderWidth: 1,
          borderColor: anchorBorder,
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: danger,
          backgroundDarker: blendColors(-0.5, danger),
          backgroundProgress: blendColors(-0.65, danger),
          textColor: yellow,
          activityColor: yellow,
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFDFDFDF),
          backgroundDarker: Color(0xFFCACACA),
          textColor: Color(0xFFB6B6B6),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _c137Theme = () {
  const blue = Color(0xFF49536F);
  const yellow = Color(0xFFFEFC81);
  const green = Color(0xFF3DB64B);
  const skin = Color(0xFFECCAB1);
  const radioactive = Color(0xFFD2E054);
  const brown = Color(0xFF6D4B29);
  const common = ThemeButtonStyle(
    borderRadius: 25,
    height: 55,
    activityColor: Color(0xFFB3E5E1),
    raiseLevel: 6,
  );
  final socialTypes = _createSocialTypes(common);

  return ThemeDefinition(
    title: 'C-137 Theme',
    background: yellow,
    color: const Color(0xFF535015),
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: blue,
          backgroundDarker: blendColors(-0.3, blue),
          backgroundProgress: blendColors(-0.62, blue),
          textColor: blendColors(0.75, blue),
          activityColor: blendColors(0.75, blue),
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: yellow,
          backgroundDarker: blendColors(-0.3, yellow),
          backgroundProgress: blendColors(-0.62, yellow),
          textColor: blendColors(-0.9, yellow),
          activityColor: blendColors(-0.9, yellow),
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: skin,
          backgroundDarker: brown,
          backgroundProgress: blendColors(-0.5, skin),
          textColor: brown,
          activityColor: brown,
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: green,
          backgroundDarker: radioactive,
          backgroundProgress: blendColors(-0.62, green),
          textColor: radioactive,
          borderColor: radioactive,
          activityColor: radioactive,
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFDFDFDF),
          backgroundDarker: Color(0xFFCACACA),
          textColor: Color(0xFFB6B6B6),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _rickTheme = () {
  const green = Color(0xFF3DB64B);
  const radioactive = Color(0xFFD2E054);
  const unityLight = Color(0xFF8B3357);
  const unityDark = Color(0xFF531849);
  const unityEyes = Color(0xFFE4E994);
  const common = ThemeButtonStyle(
    borderRadius: 25,
    height: 55,
    activityColor: Colors.white,
    raiseLevel: 6,
  );
  final socialTypes = _createSocialTypes(common);

  return ThemeDefinition(
    title: 'Rick Theme',
    background: const Color(0xFFAAD3EA),
    color: const Color(0xFF2E84B1),
    buttons: {
      ButtonVariant.primary: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFAAD3EA),
          backgroundDarker: Color(0xFF57A9D4),
          backgroundPlaceholder: Color(0xFF8DBDD9),
          textColor: Color(0xFF2E84B1),
          backgroundProgress: Color(0xFF57A9D4),
        ),
      ),
      ButtonVariant.secondary: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFFAFAFA),
          backgroundDarker: Color(0xFF67CBC3),
          backgroundActive: Color(0xFFE7FCFB),
          backgroundPlaceholder: Color(0xFFB3E5E1),
          textColor: Color(0xFF349890),
          backgroundProgress: Color(0xFFC5ECE8),
          borderWidth: 2,
          borderColor: Color(0xFFB3E5E1),
          activityColor: Color(0xFF349890),
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: green,
          backgroundDarker: radioactive,
          backgroundProgress: blendColors(-0.62, green),
          textColor: radioactive,
          borderColor: radioactive,
          activityColor: radioactive,
          borderWidth: 2,
        ),
      ),
      ButtonVariant.danger: common.merge(
        const ThemeButtonStyle(
          backgroundColor: unityLight,
          backgroundDarker: unityDark,
          backgroundProgress: unityDark,
          textColor: unityEyes,
          borderColor: unityDark,
          borderWidth: 2,
          activityColor: unityEyes,
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFE8FCDA),
          backgroundDarker: Color(0xFFBDE1A2),
          textColor: Color(0xFFC7F2A9),
          borderWidth: 2,
          borderColor: Color(0xFFC7E8AE),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _summerTheme = () {
  const primary = Color(0xFFC77CB4);
  const secondary = Color(0xFFE6913E);
  const anchor = Colors.white;
  const beth = Color(0xFFE36F5E);
  const common = ThemeButtonStyle(
    borderRadius: 24,
    height: 55,
    activityColor: Colors.white,
    raiseLevel: 8,
  );
  final socialTypes = _createSocialTypes(common);

  return ThemeDefinition(
    title: 'Summer Theme',
    background: primary,
    color: Colors.white,
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: primary,
          backgroundDarker: blendColors(-0.38, primary),
          backgroundProgress: blendColors(-0.62, primary),
          textColor: Colors.white,
          borderWidth: 0,
          borderColor: primary,
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: anchor,
          backgroundDarker: blendColors(-0.6, primary),
          textColor: blendColors(-0.3, primary),
          borderWidth: 1,
          borderColor: blendColors(-0.3, primary),
          activityColor: blendColors(-0.3, primary),
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: secondary,
          backgroundDarker: blendColors(-0.62, secondary),
          textColor: Colors.white,
          borderWidth: 0,
          borderColor: secondary,
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: beth,
          backgroundDarker: blendColors(-0.38, beth),
          backgroundProgress: blendColors(-0.62, beth),
          textColor: Colors.white,
          borderWidth: 0,
          borderColor: beth,
        ),
      ),
      ButtonVariant.disabled: common.merge(
        const ThemeButtonStyle(
          backgroundColor: Color(0xFFDFDFDF),
          backgroundDarker: Color(0xFFCACACA),
          textColor: Color(0xFFB6B6B6),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 55,
        height: 55,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 55),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final _bruceTheme = () {
  const dark = Color(0xFF3A3A3A);
  const white = Color(0xFFFBFBFB);
  const purple = Color(0xFF733086);
  const green = Color(0xFF77CD38);
  const yellow = Color(0xFFFFE727);
  const common = ThemeButtonStyle(
    borderRadius: 8,
    height: 62,
    raiseLevel: 10,
    borderWidth: 2,
  );
  final socialTypes = _createSocialTypes(common);

  return ThemeDefinition(
    title: 'Bruce Theme',
    background: const Color(0xFF2F2F2F),
    color: Colors.white,
    buttons: {
      ButtonVariant.primary: common.merge(
        ThemeButtonStyle(
          backgroundColor: dark,
          backgroundDarker: blendColors(-0.38, dark),
          backgroundProgress: blendColors(-0.62, dark),
          borderColor: blendColors(-0.38, dark),
          textColor: white,
          activityColor: white,
        ),
      ),
      ButtonVariant.secondary: common.merge(
        ThemeButtonStyle(
          backgroundColor: white,
          backgroundDarker: dark,
          backgroundProgress: blendColors(-0.38, white),
          backgroundPlaceholder: dark,
          textColor: dark,
          borderColor: blendColors(-0.38, dark),
          activityColor: dark,
        ),
      ),
      ButtonVariant.anchor: common.merge(
        ThemeButtonStyle(
          backgroundColor: yellow,
          backgroundDarker: blendColors(-0.38, dark),
          backgroundProgress: const Color(0xFF404040),
          textColor: blendColors(-0.38, dark),
          borderColor: dark,
          borderWidth: 2,
          activityColor: dark,
        ),
      ),
      ButtonVariant.danger: common.merge(
        ThemeButtonStyle(
          backgroundColor: purple,
          backgroundDarker: blendColors(-0.62, purple),
          backgroundProgress: blendColors(-0.62, purple),
          textColor: green,
          borderColor: blendColors(-0.62, purple),
          activityColor: green,
        ),
      ),
      ButtonVariant.disabled: common.merge(
        ThemeButtonStyle(
          backgroundColor: blendColors(0.38, dark),
          backgroundDarker: blendColors(0.13, dark),
          textColor: blendColors(0.13, dark),
          borderColor: blendColors(0.13, dark),
        ),
      ),
      ButtonVariant.flat: _flatStyle(),
      ...socialTypes,
    },
    size: const {
      ButtonSize.icon: ThemeSizeStyle(
        width: 60,
        height: 60,
        textSize: 12,
        paddingHorizontal: 4,
      ),
      ButtonSize.small: ThemeSizeStyle(
        width: 120,
        height: 42,
        textSize: 12,
      ),
      ButtonSize.medium: ThemeSizeStyle(width: 200, height: 60),
      ButtonSize.large: ThemeSizeStyle(width: 250, height: 60, textSize: 16),
    },
  );
}();

final Map<ThemeName, ThemeDefinition> _themes = {
  ThemeName.basic: _basicTheme,
  ThemeName.bojack: _bojackTheme,
  ThemeName.cartman: _cartmanTheme,
  ThemeName.mysterion: _mysterionTheme,
  ThemeName.c137: _c137Theme,
  ThemeName.rick: _rickTheme,
  ThemeName.summer: _summerTheme,
  ThemeName.bruce: _bruceTheme,
};

RegisteredThemeDefinition _registeredThemeAtIndex(int safeIndex) {
  final themeName = _themeOrder[safeIndex];
  final theme = _themes[themeName] ?? _themes[_defaultThemeName]!;

  return RegisteredThemeDefinition(
    title: theme.title,
    background: theme.background,
    color: theme.color,
    buttons: theme.buttons,
    size: theme.size,
    name: themeName,
    next: safeIndex + 1 < _themeOrder.length,
    prev: safeIndex - 1 >= 0,
  );
}

/// Resolves one of the built-in themes by index or name.
RegisteredThemeDefinition getTheme({
  int? index = 0,
  ThemeName? name,
}) {
  if (name != null) {
    final namedIndex = _themeOrder.indexOf(name);
    return _registeredThemeAtIndex(namedIndex == -1 ? 0 : namedIndex);
  }

  if (index == null || index < 0 || index >= _themeOrder.length) {
    return _registeredThemeAtIndex(0);
  }

  return _registeredThemeAtIndex(index);
}

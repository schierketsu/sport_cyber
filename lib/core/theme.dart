import 'package:flutter/material.dart';

// Единая шкала отступов для всего приложения
const double spacingXs = 4;
const double spacingS = 8;
const double spacingM = 12;
const double spacingL = 16;
const double spacingXl = 24;

const double radiusCard = 12;
const double radiusButton = 12;
const double radiusField = 8;

extension BurnoutColors on ColorScheme {
  Color get burnoutGreen => const Color(0xFF00E676);
  Color get burnoutYellow => const Color(0xFFFFD54F);
  Color get burnoutRed => const Color(0xFFEF5350);
}

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF00FF7F),
    onPrimary: Colors.black87,
    primaryContainer: const Color(0xFF0D4D2B),
    onPrimaryContainer: const Color(0xFFB8FFD9),
    secondary: const Color(0xFF00E676),
    onSecondary: Colors.black87,
    surface: const Color(0xFF121212),
    onSurface: Colors.white,
    surfaceContainerHighest: const Color(0xFF2C2C2C),
    surfaceContainer: const Color(0xFF1E1E1E),
    onSurfaceVariant: Colors.white70,
    error: const Color(0xFFCF6679),
    onError: Colors.black,
    outline: Colors.white24,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(size: 22),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1A1A),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusCard)),
    actionsPadding: const EdgeInsets.fromLTRB(spacingL, 0, spacingL, spacingS),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 14, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 13, color: Colors.white70),
    bodySmall: TextStyle(fontSize: 12, color: Colors.white54),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white54),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      minimumSize: const Size(64, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      minimumSize: const Size(64, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
      minimumSize: const Size(48, 32),
      textStyle: const TextStyle(fontSize: 14),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: const Size(36, 36),
      padding: const EdgeInsets.all(spacingS),
      iconSize: 22,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusField)),
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    labelStyle: const TextStyle(fontSize: 12, color: Colors.white54),
    hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
  ),
  listTileTheme: ListTileThemeData(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: 0),
    minLeadingWidth: 40,
    minVerticalPadding: 8,
    titleTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
    subtitleTextStyle: const TextStyle(fontSize: 12, color: Colors.white54),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFF00FF7F);
      return Colors.white38;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFF00FF7F).withValues(alpha: 0.5);
      return Colors.white12;
    }),
  ),
  sliderTheme: const SliderThemeData(
    thumbColor: Color(0xFF00FF7F),
    activeTrackColor: Color(0xFF00FF7F),
    inactiveTrackColor: Colors.white12,
  ),
);

import 'package:flutter/material.dart';

/// Cineby-style theme: black background, red accent, white/grey text.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color accentRed = Color(0xFFE50914);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color searchBarBg = Color(0xFF2D2D2D);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          surface: background,
          primary: accentRed,
          onPrimary: textPrimary,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
        ),
      );
}

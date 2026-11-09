import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFF59E0B);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7FC),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE5EAF2),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4F7FC),
        foregroundColor: Color(0xFF17233C),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.dark,
      primary: const Color(0xFF8EADFF),
      secondary: accent,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0A1220),
      cardColor: const Color(0xFF111C2E),
      dividerColor: const Color(0xFF25334A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A1220),
        foregroundColor: Color(0xFFEAF0FA),
        elevation: 0,
      ),
    );
  }
}

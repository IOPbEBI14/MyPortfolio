import 'package:flutter/material.dart';

class AppTheme {
  // Цвета для светлой темы
  static const Color _lightPrimary = Color(0xFF2196F3);
  static const Color _lightSecondary = Color(0xFF03A9F4);
  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightSurface = Colors.white;
  static const Color _lightError = Color(0xFFD32F2F);

  // Цвета для темной темы
  static const Color _darkPrimary = Color(0xFF90CAF9);
  static const Color _darkSecondary = Color(0xFF81D4FA);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkError = Color(0xFFEF5350);

  // Светлая тема
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      background: _lightBackground,
      error: _lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _lightBackground,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _lightSurface,
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200],
      selectedColor: _lightPrimary.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.black87),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  // Темная тема
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      background: _darkBackground,
      error: _darkError,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBackground,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _darkSurface,
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: Colors.black,
      elevation: 4,
    ),
    
    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[800],
      selectedColor: _darkPrimary.withOpacity(0.3),
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}

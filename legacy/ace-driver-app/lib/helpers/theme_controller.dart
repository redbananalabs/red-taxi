import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const String _themeKey = "light_mode";

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  /// Load saved theme on app start
  static Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool(_themeKey) ?? true;
    themeNotifier.value = isLight ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> setLightMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, true);
    themeNotifier.value = ThemeMode.light;
  }

  static Future<void> setDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, false);
    themeNotifier.value = ThemeMode.dark;
  }

  // 🔹 LIGHT THEME (SAFE)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFCD1A21),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade300,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFCD1A21),
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      titleSmall: TextStyle(color: Colors.black54),
    ),

    iconTheme: const IconThemeData(
      color: Colors.black,
    ),

    colorScheme: ColorScheme.light(
      primary: Color(0xFFCD1A21),
      secondary: Color(0xFFCD1A21),
    ),
  );

  // 🔹 DARK THEME (🔥 THIS FIXES YOUR ISSUE)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFCD1A21),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey.shade700,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    colorScheme: ColorScheme.dark(
      primary: Color(0xFFCD1A21),
      secondary: Color(0xFFCD1A21),
    ),
  );
}

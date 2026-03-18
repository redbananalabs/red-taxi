import 'package:flutter/material.dart';

/// Brand and semantic colour tokens for the Red Taxi design system.
///
/// Use these constants throughout all Red Taxi apps to ensure visual
/// consistency. Never hard-code hex values in widget files — reference
/// [RedTaxiColors] instead.
abstract class RedTaxiColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Primary brand red — used for CTAs, selected states, and key highlights.
  static const Color brandRed = Color(0xFFFF2D2D);

  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------

  /// Deepest background layer — used for screen scaffolds and modal overlays.
  static const Color backgroundBase = Color(0xFF0F1117);

  /// Elevated surface — cards, bottom sheets, and side drawers.
  static const Color backgroundSurface = Color(0xFF1A1D27);

  /// Card background — individual list items and contained components.
  static const Color backgroundCard = Color(0xFF242736);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  /// High-emphasis body text and headings.
  static const Color textPrimary = Color(0xFFF1F2F4);

  /// Low-emphasis supporting text, captions, and placeholders.
  static const Color textSecondary = Color(0xFF9CA3AF);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  /// Positive states — completed trips, online drivers, successful payments.
  static const Color success = Color(0xFF22C55E);

  /// Cautionary states — approaching limits, delayed trips.
  static const Color warning = Color(0xFFF59E0B);

  /// Destructive or error states — failed payments, offline, cancellations.
  static const Color error = Color(0xFFEF4444);
}

/// Pre-built [ThemeData] for the Red Taxi dark theme.
///
/// Pass [RedTaxiTheme.dark()] to [MaterialApp.theme].
class RedTaxiTheme {
  RedTaxiTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: RedTaxiColors.brandRed,
      onPrimary: RedTaxiColors.textPrimary,
      surface: RedTaxiColors.backgroundSurface,
      onSurface: RedTaxiColors.textPrimary,
      error: RedTaxiColors.error,
      onError: RedTaxiColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RedTaxiColors.backgroundBase,
      cardColor: RedTaxiColors.backgroundCard,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: RedTaxiColors.textPrimary),
        bodyMedium: TextStyle(color: RedTaxiColors.textPrimary),
        bodySmall: TextStyle(color: RedTaxiColors.textSecondary),
        labelSmall: TextStyle(color: RedTaxiColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RedTaxiColors.backgroundSurface,
        foregroundColor: RedTaxiColors.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RedTaxiColors.brandRed,
          foregroundColor: RedTaxiColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary app colors
  static const Color primary = Color(0xFFCD1A21);
  static const Color primaryLight = Color(0xFFE35E5E);
  static const Color secondary = Color(0xFFCD1A21);

  // Background & cards
  static const Color card = Colors.white;
  static const Color scaffoldBackground = Colors.white;
  static const Color greyBackground = Color(0xFFF5F5F5);
  static const Color greyBorder = Color(0xFFE0E0E0);

  // Text & icons
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color textWhite = Colors.white;
  static const Color iconPrimary = Colors.red;
  static const Color iconSecondary = Colors.green;

  // Toggles / Switches
  static const Color switchActive = primary;
  static const Color switchInactive = Colors.grey;

  // Scope colors
  static const Color scopeCash = Colors.green;
  static const Color scopeAccount = Colors.red;
  static const Color scopeRank = Colors.blue;
  static const Color scopeAll = Color(0xFFB0B0B0); // grey.shade400
  static const Color scopeCard = Colors.purple;

  // GPS / Location colors
  static const Color gpsOn = Colors.green;
  static const Color gpsOff = Colors.grey;
  static const Color locationButton = Colors.pinkAccent;

  // Charts
  static const Color chartToDo = Color(0xFF2196F3);
  static const Color chartUpcoming = Color(0xFF4CAF50);
  static const Color chartWeekly = primary;

  // Active Trip
  static const Color activeBorder = primary;
  static const Color activeTag = primary;

  // Divider
  static const Color divider = Colors.grey;

  // Misc
  static const Color snackbarSuccess = Colors.green;
  static const Color snackbarError = Colors.red;
}

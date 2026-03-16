import 'package:flutter/material.dart';

class SnackbarHelper {
  static void show(BuildContext context, String message,
      {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

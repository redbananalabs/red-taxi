import 'package:flutter/material.dart';

class ShiftProvider with ChangeNotifier {
  bool _shiftActive = false;

  bool get isShiftActive => _shiftActive;

  void startShift() {
    _shiftActive = true;
    notifyListeners();
  }

  void stopShift() {
    _shiftActive = false;
    notifyListeners();
  }
}

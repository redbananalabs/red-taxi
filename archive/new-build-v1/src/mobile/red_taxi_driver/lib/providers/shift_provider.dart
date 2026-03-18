import 'dart:async';
import 'package:flutter/foundation.dart';

/// Driver shift states.
enum ShiftStatus { offline, online, onBreak }

/// Manages the driver's shift status and GPS update timer.
class ShiftProvider extends ChangeNotifier {
  ShiftStatus _status = ShiftStatus.offline;
  ShiftStatus get status => _status;

  Timer? _gpsTimer;
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  DateTime? _shiftStartedAt;
  DateTime? get shiftStartedAt => _shiftStartedAt;

  Duration get shiftDuration {
    if (_shiftStartedAt == null) return Duration.zero;
    return DateTime.now().difference(_shiftStartedAt!);
  }

  bool get isOnline => _status == ShiftStatus.online;
  bool get isOffline => _status == ShiftStatus.offline;
  bool get isOnBreak => _status == ShiftStatus.onBreak;

  void goOnline() {
    _status = ShiftStatus.online;
    _shiftStartedAt ??= DateTime.now();
    _startGpsUpdates();
    notifyListeners();
  }

  void goOffline() {
    _status = ShiftStatus.offline;
    _shiftStartedAt = null;
    _stopGpsUpdates();
    notifyListeners();
  }

  void goOnBreak() {
    _status = ShiftStatus.onBreak;
    _stopGpsUpdates();
    notifyListeners();
  }

  void resumeFromBreak() {
    _status = ShiftStatus.online;
    _startGpsUpdates();
    notifyListeners();
  }

  void _startGpsUpdates() {
    _gpsTimer?.cancel();
    // Stub: push GPS every 8 seconds
    _gpsTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      // In production: get real position from Geolocator
      _latitude = 53.4808 + (DateTime.now().second * 0.0001);
      _longitude = -2.2426 + (DateTime.now().second * 0.0001);
      // In production: call apiClient.updateGps(...)
      debugPrint(
          'GPS update: $_latitude, $_longitude');
    });
  }

  void _stopGpsUpdates() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }
}

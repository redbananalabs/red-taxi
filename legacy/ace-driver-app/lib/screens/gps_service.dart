import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:ace_taxis/helpers/api_helper.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';

class LocationTask extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint("🔥 LocationTask onStart");

    _startGps();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // Optional: we already use our own timer
  }

  void _startGps() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      debugPrint("⏱ Timer tick: fetching GPS");

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );

        debugPrint(
          "📍 Position: Lat=${position.latitude}, Lng=${position.longitude}",
        );

        final userData = await SharedPrefHelper.getUser();
        final token = userData?['token'] ?? '';
        final userId = userData?['userId'] ?? 0;

        if (token.isEmpty || userId == 0) {
          debugPrint("❌ No user token or ID");
          return;
        }

        final payload = {
          "userId": userId,
          "longtitude": position.longitude,
          "latitude": position.latitude,
          "speed": double.parse(position.speed.toStringAsFixed(2)),
          "heading": position.heading,
        };

        final response = await ApiHelper.post(
          ApiConstants.updateGpsEndpoint,
          payload,
          headers: {"Authorization": "Bearer $token"},
        );

        FlutterForegroundTask.updateService(
          notificationText:
              "Lat:${position.latitude.toStringAsFixed(4)}, Lng:${position.longitude.toStringAsFixed(4)}",
        );

        debugPrint("📡 GPS SENT: $payload");
        debugPrint("📥 GPS RESPONSE: $response");
      } catch (e) {
        debugPrint("❌ Foreground GPS error: $e");
      }
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print("⏱ Foreground tick");

    _timer?.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }
}

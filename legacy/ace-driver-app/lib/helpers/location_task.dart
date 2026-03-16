// import 'dart:isolate';
// import 'package:ace_taxis/repositories/gps.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:geolocator/geolocator.dart';
// import '../helpers/shared_pref_helper.dart';

// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
// }

// class LocationTaskHandler extends TaskHandler {
//   final GpsRepository _gpsRepository = GpsRepository();

//   @override
//   Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
//     debugPrint("Foreground GPS Service Started at $timestamp");
//   }

//   @override
//   Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation,
//       );

//       final userData = await SharedPrefHelper.getUser();
//       final token = userData?['token'];
//       final userId = userData?['userId'];

//       if (token == null || userId == null) {
//         debugPrint("No user data found. Skipping GPS update.");
//         return;
//       }

//       final speed = double.parse(pos.speed.toStringAsFixed(2));
//       final heading = double.parse(pos.heading.toStringAsFixed(2));

//       // Send GPS using repository
//       final response = await _gpsRepository.sendGpsData(
//         token: token,
//         userId: userId,
//         latitude: pos.latitude,
//         longtitude: pos.longitude,
//         speed: speed,
//         heading: heading,
//       );

//       // Print debug info (UI-friendly)
//       debugPrint(
//         "GPS Updated | Lat: ${pos.latitude.toStringAsFixed(5)}, Long: ${pos.longitude.toStringAsFixed(5)}, Speed: $speed, Heading: $heading",
//       );
//       debugPrint("📡 Server Response: $response");

//       // Update foreground service notification
//       await FlutterForegroundTask.updateService(
//         notificationTitle: 'Ace Taxis',
//         notificationText:
//             'GPS Active (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
//       );
//     } catch (e) {
//       debugPrint("GPS ERROR: $e");
//     }
//   }

//   @override
//   Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

//   @override
//   Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
//     debugPrint("Foreground GPS Service Stopped");
//   }

//   @override
//   Future<void> onButtonPressed(String id) async {
//     if (id == 'stop') {
//       await FlutterForegroundTask.stopService();
//       debugPrint("Foreground task stop button pressed.");
//     }
//   }
// }

import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint("Foreground GPS Service Started at $timestamp");
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    try {
      // Get current position (optional if you want live coordinates)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      // Debug output only
      debugPrint(
        "Foreground Service Running | Lat: ${pos.latitude.toStringAsFixed(5)}, Long: ${pos.longitude.toStringAsFixed(5)}, Speed: ${pos.speed.toStringAsFixed(2)}, Heading: ${pos.heading.toStringAsFixed(2)}",
      );

      // Update foreground notification
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Ace Taxis',
        notificationText:
            'GPS Active (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
      );
    } catch (e) {
      debugPrint("GPS ERROR (No API Call): $e");
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    debugPrint("Foreground GPS Service Stopped");
  }

  @override
  Future<void> onButtonPressed(String id) async {
    if (id == 'stop') {
      await FlutterForegroundTask.stopService();
      debugPrint("Foreground task stop button pressed.");
    }
  }
}

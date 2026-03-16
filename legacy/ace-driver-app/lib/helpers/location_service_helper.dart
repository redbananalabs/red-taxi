// import 'dart:async';
// import 'package:ace_taxis/helpers/location_task.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationServiceHelper {
//   static StreamSubscription<Position>? _positionStream;

//   static Future<bool> startLocationService() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       debugPrint("Location services are disabled.");
//       return false;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         debugPrint("Location permission denied");
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       debugPrint("Location permissions are permanently denied");
//       return false;
//     }

//     // Start Foreground Service
//     await FlutterForegroundTask.startService(
//       notificationTitle: 'Ace Driver',
//       notificationText: 'Location Service Running',
//       callback: startCallback,
//     );

//     // Start listening to location
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: 50,
//       ),
//     ).listen((Position position) {
//       debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
//     });

//     return true;
//   }

//   static Future<void> stopLocationService() async {
//     await _positionStream?.cancel();
//     _positionStream = null;
//     await FlutterForegroundTask.stopService();
//     debugPrint("Location service stopped");
//   }
// }

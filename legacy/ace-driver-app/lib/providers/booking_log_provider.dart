import 'package:flutter/material.dart';
import '../models/create_booking_model.dart';

class BookingLogProvider with ChangeNotifier {
  final List<CreateBookingModel> _logs = [];

  List<CreateBookingModel> get logs => List.unmodifiable(_logs);

  void addLog(CreateBookingModel booking) {
    _logs.add(booking);

    // ✅ Console log
    debugPrint("========= BOOKING LOG =========");
    debugPrint(booking.toJson().toString());
    debugPrint("================================");

    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}

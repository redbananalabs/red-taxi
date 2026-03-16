import 'package:flutter/material.dart';

class CreateBookingModel {
  final String pickup;
  final String pickupPostcode;
  final String destination;
  final String destinationPostcode;
  final String name;
  final double mileage;
  final String mileageText;
  final int durationMinutes;
  final String durationText;
  final double price;
  final DateTime? date;
  final TimeOfDay? time;

  CreateBookingModel({
    required this.pickup,
    required this.pickupPostcode,
    required this.destination,
    required this.destinationPostcode,
    required this.name,
    required this.mileage,
    required this.mileageText,
    required this.durationMinutes,
    required this.durationText,
    required this.price,
    this.date,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "pickup": pickup,
      "pickupPostcode": pickupPostcode,
      "destination": destination,
      "destinationPostcode": destinationPostcode,
      "name": name,
      "mileage": mileage,
      "mileageText": mileageText,
      "durationMinutes": durationMinutes,
      "durationText": durationText,
      "price": price,
      "date": date?.toIso8601String(),
      "time": time != null ? "${time!.hour}:${time!.minute}" : null,
    };
  }
}

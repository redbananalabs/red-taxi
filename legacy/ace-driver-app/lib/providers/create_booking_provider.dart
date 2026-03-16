import 'package:flutter/material.dart';
import '../repositories/create_booking_repository.dart';

class CreateBookingProvider with ChangeNotifier {
  final CreateBookingRepository _createBookingRepository =
      CreateBookingRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> createBooking({
    required String pickup,
    required String pickupPostcode,
    required String destination,
    required String destinationPostcode,
    required String name,
    required double mileage,
    required String mileageText,
    required double price,
    required int durationMinutes,
    required String durationText,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _createBookingRepository.createBooking(
        pickup: pickup,
        pickupPostcode: pickupPostcode,
        destination: destination,
        destinationPostcode: destinationPostcode,
        name: name,
        mileage: mileage,
        mileageText: mileageText,
        price: price,
        durationMinutes: durationMinutes,
        durationText: durationText,
      );

      return result;
    } catch (e) {
      debugPrint("Create booking error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

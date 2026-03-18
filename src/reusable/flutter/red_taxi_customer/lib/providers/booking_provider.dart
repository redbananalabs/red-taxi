import 'package:flutter/foundation.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Manages booking state for the customer app.
class BookingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Booking> _bookings = [];
  Booking? _activeBooking;
  String? _pickupAddress;
  String? _destinationAddress;
  DateTime? _scheduledDateTime;
  int _passengerCount = 1;
  String _vehicleType = 'standard';
  double? _priceEstimate;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Booking> get bookings => _bookings;
  Booking? get activeBooking => _activeBooking;
  String? get pickupAddress => _pickupAddress;
  String? get destinationAddress => _destinationAddress;
  DateTime? get scheduledDateTime => _scheduledDateTime;
  int get passengerCount => _passengerCount;
  String get vehicleType => _vehicleType;
  double? get priceEstimate => _priceEstimate;

  void setPickup(String address) {
    _pickupAddress = address;
    _calculateEstimate();
    notifyListeners();
  }

  void setDestination(String address) {
    _destinationAddress = address;
    _calculateEstimate();
    notifyListeners();
  }

  void setScheduledDateTime(DateTime? dt) {
    _scheduledDateTime = dt;
    notifyListeners();
  }

  void setPassengerCount(int count) {
    _passengerCount = count;
    notifyListeners();
  }

  void setVehicleType(String type) {
    _vehicleType = type;
    _calculateEstimate();
    notifyListeners();
  }

  void _calculateEstimate() {
    if (_pickupAddress != null && _destinationAddress != null) {
      // Simulated price estimate
      _priceEstimate = _vehicleType == 'premium' ? 24.50 : 14.50;
    }
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: call API
      await Future.delayed(const Duration(seconds: 1));
      _bookings = [];
    } catch (e) {
      _errorMessage = 'Failed to load bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: call API
      await Future.delayed(const Duration(seconds: 1));
      _activeBooking = Booking(
        id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'user_001',
        pickupAddress: _pickupAddress ?? '',
        destinationAddress: _destinationAddress ?? '',
        pickupLatitude: 0,
        pickupLongitude: 0,
        destinationLatitude: 0,
        destinationLongitude: 0,
        pickupDateTime: _scheduledDateTime ?? DateTime.now(),
        status: BookingStatus.pending,
        price: _priceEstimate ?? 14.50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create booking.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearBookingForm() {
    _pickupAddress = null;
    _destinationAddress = null;
    _scheduledDateTime = null;
    _passengerCount = 1;
    _vehicleType = 'standard';
    _priceEstimate = null;
    notifyListeners();
  }

  void rateTrip(int stars, String? comment) {
    // TODO: call API
    _activeBooking = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Job status progression for the active trip.
enum ActiveJobPhase { none, onRoute, arrived, passengerOnBoard, completing }

/// Manages bookings, schedule, offers, and active job state.
class BookingProvider extends ChangeNotifier {
  // ---- Schedule bookings ----
  List<Booking> _scheduledBookings = [];
  List<Booking> get scheduledBookings => _scheduledBookings;

  // ---- Job offers ----
  List<Booking> _pendingOffers = [];
  List<Booking> get pendingOffers => _pendingOffers;
  Booking? _incomingOffer;
  Booking? get incomingOffer => _incomingOffer;

  // ---- Active job ----
  Booking? _activeBooking;
  Booking? get activeBooking => _activeBooking;
  ActiveJobPhase _phase = ActiveJobPhase.none;
  ActiveJobPhase get phase => _phase;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  BookingProvider() {
    _loadStubData();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Booking> get bookingsForSelectedDate {
    return _scheduledBookings.where((b) {
      return b.pickupDateTime.year == _selectedDate.year &&
          b.pickupDateTime.month == _selectedDate.month &&
          b.pickupDateTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.pickupDateTime.compareTo(b.pickupDateTime));
  }

  // ---- Offer actions ----

  void simulateIncomingOffer() {
    final now = DateTime.now();
    _incomingOffer = Booking(
      id: 'offer_${now.millisecondsSinceEpoch}',
      customerId: 'cust_042',
      pickupAddress: '15 High Street, Manchester M1 1AD',
      destinationAddress: 'Manchester Airport Terminal 2',
      pickupLatitude: 53.4808,
      pickupLongitude: -2.2426,
      destinationLatitude: 53.3537,
      destinationLongitude: -2.2750,
      pickupDateTime: now.add(const Duration(minutes: 10)),
      status: BookingStatus.pending,
      price: 32.50,
      createdAt: now,
      updatedAt: now,
    );
    notifyListeners();
  }

  void acceptOffer() {
    if (_incomingOffer == null) return;
    _activeBooking = _incomingOffer!.copyWith(
      status: BookingStatus.accepted,
      driverId: 'driver_001',
    );
    _phase = ActiveJobPhase.onRoute;
    _pendingOffers.removeWhere((b) => b.id == _incomingOffer!.id);
    _incomingOffer = null;
    notifyListeners();
  }

  void rejectOffer() {
    if (_incomingOffer == null) return;
    _pendingOffers.removeWhere((b) => b.id == _incomingOffer!.id);
    _incomingOffer = null;
    notifyListeners();
  }

  // ---- Active job progression ----

  void progressJob() {
    switch (_phase) {
      case ActiveJobPhase.onRoute:
        _phase = ActiveJobPhase.arrived;
        _activeBooking = _activeBooking?.copyWith(status: BookingStatus.arrived);
        // In production: send SMS to customer here
      case ActiveJobPhase.arrived:
        _phase = ActiveJobPhase.passengerOnBoard;
        _activeBooking =
            _activeBooking?.copyWith(status: BookingStatus.inProgress);
      case ActiveJobPhase.passengerOnBoard:
        _phase = ActiveJobPhase.completing;
      default:
        break;
    }
    notifyListeners();
  }

  void completeJob({
    int waitingMinutes = 0,
    double parkingCharge = 0,
    double driverPrice = 0,
    double tip = 0,
  }) {
    _activeBooking =
        _activeBooking?.copyWith(status: BookingStatus.completed);
    _scheduledBookings = _scheduledBookings.map((b) {
      if (b.id == _activeBooking?.id) return _activeBooking!;
      return b;
    }).toList();
    _activeBooking = null;
    _phase = ActiveJobPhase.none;
    notifyListeners();
  }

  void cancelActiveJob() {
    _activeBooking = null;
    _phase = ActiveJobPhase.none;
    notifyListeners();
  }

  // ---- Stub data ----

  void _loadStubData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _scheduledBookings = [
      Booking(
        id: 'bk_001',
        customerId: 'cust_001',
        driverId: 'driver_001',
        pickupAddress: '42 Deansgate, Manchester M3 2EG',
        destinationAddress: 'Piccadilly Station, Manchester M1 2GH',
        pickupLatitude: 53.4794,
        pickupLongitude: -2.2491,
        destinationLatitude: 53.4774,
        destinationLongitude: -2.2309,
        pickupDateTime: today.add(const Duration(hours: 8, minutes: 30)),
        status: BookingStatus.accepted,
        price: 8.50,
        createdAt: today,
        updatedAt: today,
      ),
      Booking(
        id: 'bk_002',
        customerId: 'cust_002',
        driverId: 'driver_001',
        pickupAddress: '10 Oxford Road, Manchester M1 5QA',
        destinationAddress: 'Trafford Centre, Manchester M17 8AA',
        pickupLatitude: 53.4722,
        pickupLongitude: -2.2388,
        destinationLatitude: 53.4661,
        destinationLongitude: -2.3479,
        pickupDateTime: today.add(const Duration(hours: 10)),
        status: BookingStatus.accepted,
        price: 14.00,
        createdAt: today,
        updatedAt: today,
      ),
      Booking(
        id: 'bk_003',
        customerId: 'cust_003',
        driverId: 'driver_001',
        pickupAddress: 'Northern Quarter, Manchester M1 1JR',
        destinationAddress: 'Old Trafford, Manchester M16 0RA',
        pickupLatitude: 53.4841,
        pickupLongitude: -2.2364,
        destinationLatitude: 53.4631,
        destinationLongitude: -2.2913,
        pickupDateTime: today.add(const Duration(hours: 14, minutes: 15)),
        status: BookingStatus.accepted,
        price: 11.00,
        createdAt: today,
        updatedAt: today,
      ),
      Booking(
        id: 'bk_004',
        customerId: 'cust_004',
        driverId: 'driver_001',
        pickupAddress: 'Spinningfields, Manchester M3 3EB',
        destinationAddress: 'Manchester Airport T1',
        pickupLatitude: 53.4802,
        pickupLongitude: -2.2527,
        destinationLatitude: 53.3537,
        destinationLongitude: -2.2750,
        pickupDateTime:
            today.add(const Duration(days: 1, hours: 6, minutes: 0)),
        status: BookingStatus.pending,
        price: 30.00,
        createdAt: today,
        updatedAt: today,
      ),
    ];

    _pendingOffers = [
      Booking(
        id: 'offer_001',
        customerId: 'cust_010',
        pickupAddress: '5 Peter Street, Manchester M2 5QR',
        destinationAddress: 'Salford Quays, Manchester M50 3AZ',
        pickupLatitude: 53.4785,
        pickupLongitude: -2.2465,
        destinationLatitude: 53.4725,
        destinationLongitude: -2.2963,
        pickupDateTime: now.add(const Duration(minutes: 15)),
        status: BookingStatus.pending,
        price: 9.50,
        createdAt: now,
        updatedAt: now,
      ),
      Booking(
        id: 'offer_002',
        customerId: 'cust_011',
        pickupAddress: 'Victoria Station, Manchester M3 1WY',
        destinationAddress: 'MediaCityUK, Salford M50 2EQ',
        pickupLatitude: 53.4878,
        pickupLongitude: -2.2421,
        destinationLatitude: 53.4726,
        destinationLongitude: -2.2975,
        pickupDateTime: now.add(const Duration(minutes: 25)),
        status: BookingStatus.pending,
        price: 12.00,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> refresh() async {
    // Stub: in production, fetch from API
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}

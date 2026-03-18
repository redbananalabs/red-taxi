/// Represents the lifecycle status of a booking.
enum BookingStatus {
  pending,
  accepted,
  driverEnRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

/// Core booking model shared across all Red Taxi apps.
class Booking {
  final String id;
  final String customerId;
  final String? driverId;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final DateTime pickupDateTime;
  final BookingStatus status;
  final double price;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleRegistration;
  final String? vehicleModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.pickupDateTime,
    required this.status,
    required this.price,
    this.driverName,
    this.driverPhone,
    this.vehicleRegistration,
    this.vehicleModel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      driverId: json['driver_id'] as String?,
      pickupAddress: json['pickup_address'] as String,
      destinationAddress: json['destination_address'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      destinationLatitude: (json['destination_latitude'] as num).toDouble(),
      destinationLongitude: (json['destination_longitude'] as num).toDouble(),
      pickupDateTime: DateTime.parse(json['pickup_datetime'] as String),
      status: BookingStatus.values.byName(json['status'] as String),
      price: (json['price'] as num).toDouble(),
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      vehicleRegistration: json['vehicle_registration'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'pickup_datetime': pickupDateTime.toIso8601String(),
      'status': status.name,
      'price': price,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_registration': vehicleRegistration,
      'vehicle_model': vehicleModel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? customerId,
    String? driverId,
    String? pickupAddress,
    String? destinationAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? pickupDateTime,
    BookingStatus? status,
    double? price,
    String? driverName,
    String? driverPhone,
    String? vehicleRegistration,
    String? vehicleModel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      status: status ?? this.status,
      price: price ?? this.price,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Booking(id: $id, status: ${status.name}, price: $price)';
}

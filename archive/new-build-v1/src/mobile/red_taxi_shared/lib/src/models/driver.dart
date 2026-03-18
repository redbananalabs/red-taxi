/// Status of a driver in the fleet.
enum DriverStatus {
  available,
  busy,
  offline,
  onTrip,
}

/// Driver model shared across all Red Taxi apps.
class Driver {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String vehicleModel;
  final String vehicleRegistration;
  final String vehicleColor;
  final DriverStatus status;
  final double rating;
  final int totalTrips;
  final double? latitude;
  final double? longitude;
  final double? heading;
  final DateTime createdAt;

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    required this.vehicleModel,
    required this.vehicleRegistration,
    required this.vehicleColor,
    required this.status,
    required this.rating,
    required this.totalTrips,
    this.latitude,
    this.longitude,
    this.heading,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      vehicleModel: json['vehicle_model'] as String,
      vehicleRegistration: json['vehicle_registration'] as String,
      vehicleColor: json['vehicle_color'] as String,
      status: DriverStatus.values.byName(json['status'] as String),
      rating: (json['rating'] as num).toDouble(),
      totalTrips: json['total_trips'] as int,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photo_url': photoUrl,
      'vehicle_model': vehicleModel,
      'vehicle_registration': vehicleRegistration,
      'vehicle_color': vehicleColor,
      'status': status.name,
      'rating': rating,
      'total_trips': totalTrips,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Driver(id: $id, name: $name, status: ${status.name})';
}

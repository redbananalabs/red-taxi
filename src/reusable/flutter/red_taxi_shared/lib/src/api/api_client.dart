import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for all Red Taxi backend API calls.
///
/// Instantiate with [baseUrl] and an optional [authToken].
/// Call [setAuthToken] after login to attach the bearer token to requests.
class RedTaxiApiClient {
  final String baseUrl;
  String? _authToken;
  final http.Client _http;

  RedTaxiApiClient({
    required this.baseUrl,
    String? authToken,
    http.Client? httpClient,
  })  : _authToken = authToken,
        _http = httpClient ?? http.Client();

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Uri _uri(String path, [Map<String, String>? queryParams]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, String>? query]) async {
    final response = await _http.get(_uri(path, query), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _patch(
      String path, Map<String, dynamic> body) async {
    final response = await _http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] as String? ?? response.reasonPhrase ?? 'Error',
    );
  }

  // ---------------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------------

  /// Returns a list of bookings for the authenticated user.
  Future<List<Booking>> getBookings({String? status}) async {
    final query = status != null ? {'status': status} : null;
    final data = await _get('/api/v1/bookings', query);
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns a single booking by [id].
  Future<Booking> getBookingById(String id) async {
    final data = await _get('/api/v1/bookings/$id');
    return Booking.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Creates a new booking with the provided details.
  Future<Booking> createBooking(Map<String, dynamic> payload) async {
    final data = await _post('/api/v1/bookings', payload);
    return Booking.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Updates the status of a booking (e.g. accepted, in_progress, completed).
  Future<Booking> updateBookingStatus(String id, String status) async {
    final data = await _patch('/api/v1/bookings/$id/status', {'status': status});
    return Booking.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  /// Returns the authenticated user's profile.
  Future<Map<String, dynamic>> getProfile() async {
    final data = await _get('/api/v1/profile');
    return data['data'] as Map<String, dynamic>;
  }

  /// Updates the authenticated user's profile fields.
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> payload) async {
    final data = await _patch('/api/v1/profile', payload);
    return data['data'] as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // GPS / Location
  // ---------------------------------------------------------------------------

  /// Pushes the driver's current GPS coordinates to the backend.
  Future<void> updateGps({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    await _post('/api/v1/drivers/$driverId/location', {
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    });
  }

  // ---------------------------------------------------------------------------
  // Drivers (operator / admin use)
  // ---------------------------------------------------------------------------

  /// Returns a list of all drivers (operator role required).
  Future<List<Map<String, dynamic>>> getDrivers({String? status}) async {
    final query = status != null ? {'status': status} : null;
    final data = await _get('/api/v1/drivers', query);
    return (data['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Returns live GPS positions for all active drivers.
  Future<List<Map<String, dynamic>>> getActiveDriverLocations() async {
    final data = await _get('/api/v1/drivers/locations');
    return (data['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  void dispose() => _http.close();
}

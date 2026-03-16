import 'dart:convert';
import '../helpers/api_constants.dart';
import '../helpers/api_helper.dart';

class GpsRepository {
  ///  Send live GPS data
  Future<Map<String, dynamic>> sendGpsData({
    required String token,
    required int userId,
    required double latitude,
    required double longtitude,
    required double speed,
    required double heading,
  }) async {
    if (token.isEmpty) {
      throw Exception("Token is empty. Please login again.");
    }

    final String url = ApiConstants.updateGpsEndpoint;

    final gpsPayload = {
      "userId": userId,
      "latitude": latitude,
      "longtitude": longtitude,
      "speed": speed,
      "heading": double.parse(heading.toStringAsFixed(3)),
      // "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      final response = await ApiHelper.post(
        url,
        gpsPayload,
        headers: {"Authorization": "Bearer $token"},
      );

      // 🔹 Log both payload and API response together
      print("GPS UPDATE LOG START");
      print(
        "Payload Sent: ${const JsonEncoder.withIndent('  ').convert(gpsPayload)}",
      );
      print("API Response Received:");
      print("Status Code: ${response['statusCode']}");
      print(
        "Body       : ${const JsonEncoder.withIndent('  ').convert(response['body'])}",
      );
      print("GPS UPDATE LOG END\n");

      return response;
    } catch (e) {
      print("GPS SEND ERROR: $e");
      rethrow;
    }
  }
}

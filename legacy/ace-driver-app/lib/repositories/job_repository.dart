import 'dart:convert';
import '../helpers/api_helper.dart'; // Your GET/POST wrapper
import '../helpers/api_constants.dart'; // Contains base URLs and endpoints

class JobRepository {
  /// 🔹 Get job details by booking ID
  static Future<Map<String, dynamic>?> getJobById(
    String bookingId, {
    required String token,
  }) async {
    final url = "${ApiConstants.baseUrl}/Bookings/FindById?bookingId=$bookingId";

    try {
      print("📡 Calling GET → $url");

      final response = await ApiHelper.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response == null) return null;

      if (response is Map<String, dynamic>) return response;

      if (response is String) {
        try {
          return jsonDecode(response);
        } catch (e) {
          print("⚠️ JSON decode failed: $e");
          return null;
        }
      }

      print("⚠️ Unknown response type: ${response.runtimeType}");
      return null;
    } catch (e) {
      print("🚨 Error fetching job by ID: $e");
      return null;
    }
  }

  /// 🔹 Get job offer details by GUID (GET version)
  static Future<Map<String, dynamic>?> retrieveJobOffer(
    String guid, {
    required String token,
  }) async {
    // Assuming RETRIEVEJOBOFFER is a GET endpoint with ?guid= param
    final url = "${ApiConstants.retrieveJobOfferEndpoint}?guid=$guid";

    try {
      print("📡 Calling GET → $url");

      final response = await ApiHelper.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response == null) return null;

      if (response is Map<String, dynamic>) return response;

      if (response is String) {
        try {
          return jsonDecode(response);
        } catch (e) {
          print("⚠️ JSON decode failed: $e");
          return null;
        }
      }

      print("⚠️ Unknown response type: ${response.runtimeType}");
      return null;
    } catch (e) {
      print("🚨 Error fetching job offer: $e");
      return null;
    }
  }
}

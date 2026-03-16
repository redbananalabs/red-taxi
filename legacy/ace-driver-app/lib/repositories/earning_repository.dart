import '../helpers/api_constants.dart';
import '../helpers/api_helper.dart';

class EarningRepository {
  /// Fetch earnings report by date range (GET request with Authorization header)
  Future<List<Map<String, dynamic>>> fetchEarnings({
    required String token,
    required String from,
    required String to,
  }) async {
    if (token.isEmpty) {
      throw Exception("Token is empty. Please login again.");
    }

    final String url = "${ApiConstants.earningsEndpoint}?from=$from&to=$to";

    print("🔹 Fetching earnings with URL: $url");
    print("🔹 Using token: $token");

    try {
      final response = await ApiHelper.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      // ✅ ADD THESE LINES — will print full server response in your Flutter console
      print("==================================================");
      print("🔸 RAW API RESPONSE (earnings):");
      print(response);
      print("==================================================");

      if (response == null) {
        throw Exception("No response from server");
      }

      // Handle response
      if (response is List) {
        print("✅ Response is a LIST with ${response.length} items");
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response['data'] != null) {
        print("✅ Response is a MAP containing 'data' with ${(response['data'] as List).length} items");
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        print("⚠️ Unexpected response format: $response");
        throw Exception("Unexpected response format: $response");
      }
    } catch (e) {
      print("🚨 Error fetching earnings: $e");
      rethrow;
    }
  }
}

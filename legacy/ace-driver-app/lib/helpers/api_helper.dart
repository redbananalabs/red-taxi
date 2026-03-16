import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiHelper {
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
    print("🔹 Auth Token set: $_authToken");
  }

  // ---------------- POST request ----------------
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json", ...?headers},
      );

      // Try to decode body safely
      dynamic decodedBody = {};
      if (response.body.isNotEmpty) {
        try {
          decodedBody = jsonDecode(response.body);
        } catch (_) {
          decodedBody = {"message": response.body}; // fallback
        }
      }

      // Return actual status code and body regardless of 200/400/422 etc
      return {"statusCode": response.statusCode, "body": decodedBody};
    } catch (e) {
      // Only network/connection exceptions land here
      return {
        "statusCode": 500,
        "body": {"error": "Network error: ${e.toString()}"},
      };
    }
  }

  // ---------------- GET request ----------------
  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken",
          ...?headers,
        },
      );

      print("✅ GET URL: $url");
      print("✅ Response Status: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      // -------------------------
      // FIX: handle 200 and 204
      // -------------------------
      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      if (response.statusCode == 204) {
        print("ℹ️ No Content (204), returning null");
        return null;
      }

      // OTHER ERRORS
      try {
        final decoded = jsonDecode(response.body);
        final msg =
            decoded['message'] ??
            decoded['errors']?.toString() ??
            'Unknown error';
        throw Exception("Error ${response.statusCode}: $msg");
      } catch (_) {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ GET request failed: $e");
      rethrow;
    }
  }

  /// ✅ RAW FILE DOWNLOAD
  static Future<Uint8List> getRaw(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("File download failed: ${response.statusCode}");
    }
  }
}

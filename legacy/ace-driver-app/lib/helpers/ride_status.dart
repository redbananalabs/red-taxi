import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'shared_pref_helper.dart';

// ------------------- ENUM -------------------
enum AppJobStatus {
  OnRoute,
  AtPickup,
  PassengerOnBoard,
  SoonToClear,
  Clear,
  NoJob,
}

const Map<AppJobStatus, int> jobStatusCodes = {
  AppJobStatus.OnRoute: 3003,
  AppJobStatus.AtPickup: 3004,
  AppJobStatus.PassengerOnBoard: 3005,
  AppJobStatus.SoonToClear: 3006,
  // AppJobStatus.Clear: 3007,
  AppJobStatus.NoJob: 3008,
};

// ------------------- JOB STATUS HELPER -------------------
class JobStatusReplyHelper {
  static const String _baseUrl =
      // "https://dev.ace-api.1soft.co.uk/api/DriverApp";
  "https://ace-server.1soft.co.uk/api/DriverApp";

  /// Sends ride/job status update
  static Future<bool> send({
    required int bookingId,
    required AppJobStatus status,
  }) async {
    debugPrint("➡️ Preparing to send JobStatusReply...");

    // Get token from shared preferences
    final token = await SharedPrefHelper.getToken();
    debugPrint("🔑 Retrieved token: ${token ?? 'null'}");

    if (token == null || token.isEmpty) {
      debugPrint("❌ Token not found, aborting request");
      return false;
    }

    final int statusCode = jobStatusCodes[status] ?? 3008;
    debugPrint("🎯 JobStatus: $status | StatusCode: $statusCode");
    debugPrint("📌 BookingId: $bookingId");

    final Uri url = Uri.parse(
      "$_baseUrl/JobStatusReply?jobno=$bookingId&status=$statusCode",
    );
    debugPrint("🌐 URL: $url");

    try {
      debugPrint("📡 Sending HTTP GET request...");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ JobStatusReply Success");
        return true;
      } else {
        debugPrint(
          "❌ JobStatusReply Failed | StatusCode: ${response.statusCode}",
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint("⚠️ Exception sending JobStatusReply: $e");
      debugPrint(stack.toString());
      return false;
    }
  }

  /// Shows snack bar with result
  static void showResult(BuildContext context, bool success) {
    debugPrint("📝 Showing result SnackBar | Success: $success");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Ride status updated successfully ✅"
              : "Failed to update ride status ❌",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

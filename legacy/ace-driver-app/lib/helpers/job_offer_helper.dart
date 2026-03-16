import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/api_constants.dart';
import '../helpers/shared_pref_helper.dart';

class JobOfferHelper {
  static const int acceptCode = 2000;
  static const int rejectCode = 2001;
  static const int timedOutCode = 2002;
  static bool _userHasResponded = false;
  static void markResponded() {
    _userHasResponded = true;
    print('JobOfferHelper: user marked as responded');
  }

  static void resetResponded() {
    _userHasResponded = false;
    print('JobOfferHelper: responded flag reset');
  }

  static bool get hasResponded => _userHasResponded;
  static Future<bool> sendJobOfferReply({
    required int bookingId,
    required String guid,
    required int replyType,
  }) async {
    final token = await SharedPrefHelper.getToken();

    if (token == null || token.isEmpty) return false;
    if (guid.isEmpty) return false;

    final url = Uri.parse(
      "${ApiConstants.jobOfferReplyEndpoint}"
      "?jobno=$bookingId"
      "&guid=$guid"
      "&response=$replyType",
    );

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  static Future<bool> acceptJob({
    required int bookingId,
    required String guid,
  }) async {
    markResponded();
    return await sendJobOfferReply(
      bookingId: bookingId,
      guid: guid,
      replyType: acceptCode,
    );
  }

  static Future<bool> rejectJob({
    required int bookingId,
    required String guid,
  }) async {
    markResponded();
    return await sendJobOfferReply(
      bookingId: bookingId,
      guid: guid,
      replyType: rejectCode,
    );
  }

  static Future<Map<String, dynamic>?> retrieveJobOffer(
    String guid, {
    required String token,
  }) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/DriverApp/RetrieveJobOffer?guid=$guid",
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint("RetrieveJobOffer failed: ${response.body}");
      return null;
    }
  }
}

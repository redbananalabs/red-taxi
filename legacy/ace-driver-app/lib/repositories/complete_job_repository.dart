import 'dart:convert';

import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompleteJobRepository {
  Future<http.Response> completeJob({
    required int bookingId,
    required int waitingTime,
    required int parkingCharge,
    required double driverPrice,
    required double accountPrice,
    required double tip,
  }) async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final url = Uri.parse(ApiConstants.completeJobEndpoint);

    final body = jsonEncode({
      "bookingId": bookingId,
      "waitingTime": waitingTime,
      "parkingCharge": parkingCharge,
      "driverPrice": driverPrice,
      "accountPrice": accountPrice,
      "tip": tip,
    });

    debugPrint("POST CompleteJob to URL: $url");
    debugPrint("POST CompleteJob body: $body");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    debugPrint("CompleteJob API response code: ${response.statusCode}");
    debugPrint("CompleteJob API response body: ${response.body}");

    return response; // ← MUST RETURN THIS
  }
}

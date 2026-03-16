import 'dart:convert';
import 'package:ace_taxis/models/driver_availiblities_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../helpers/api_helper.dart';
import '../helpers/api_constants.dart';
import '../helpers/shared_pref_helper.dart';
import '../models/availability_model.dart';

class AvailabilityRepository {
  // 🔥 ALWAYS get real token dynamically
  Future<String> _getToken() async {
    final token = await SharedPrefHelper.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Unauthorized: Token missing");
    }
    return token;
  }

  // ---------------------- FETCH MY AVAILABILITIES ----------------------
  Future<List<Availability>> fetchAvailabilities() async {
    final token = await _getToken();

    final response = await ApiHelper.get(
      ApiConstants.availabilitiesEndpoint,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    // Your API returns either: { drivers: [] } OR []
    if (response is Map && response.containsKey("drivers")) {
      final List drivers = response["drivers"] ?? [];
      return drivers
          .map((e) => Availability.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response is List) {
      return response
          .map((e) => Availability.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected response format in fetchAvailabilities");
  }

  // ---------------------- FETCH ALL DRIVERS ----------------------
  Future<List<DriverAvailability>> fetchAllDriversAvailability(
    DateTime date,
  ) async {
    final token = await _getToken();
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final response = await ApiHelper.get(
      "${ApiConstants.generalEndpoint}?date=$dateString",
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response is List) {
      return response
          .map((e) => DriverAvailability.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected response format for drivers");
  }

  // ---------------------- SET AVAILABILITY ----------------------
  Future<Map<String, dynamic>> setAvailability({
    required int userId,
    required DateTime date,
    required String from,
    required String to,
    required bool giveOrTake,
    required int type,
    required String note,
  }) async {
    final token = await _getToken();

    final body = {
      "userId": userId,
      "date": date.toIso8601String(),
      "from": from,
      "to": to,
      "giveOrTake": giveOrTake,
      "type": type,
      "note": note,
    };

    final response = await ApiHelper.post(
      ApiConstants.setAvailabilityEndpoint,
      body,
      headers: {"Authorization": "Bearer $token"},
    );

    // Return full response with statusCode and body
    return {"statusCode": response["statusCode"], "body": response["body"]};
  }

  // ---------------------- DELETE AVAILABILITY ----------------------
  Future<void> deleteAvailability(int id) async {
    final token = await _getToken();

    final url = Uri.parse(
      // 'https://dev.ace-api.1soft.co.uk/api/DriverApp/DeleteAvailability?id=$id',
      'https://ace-server.1soft.co.uk/api/DriverApp/DeleteAvailability?id=$id',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == '""') return;

      final data = json.decode(response.body);
      if (data['success'] == true) return;
    }

    throw Exception("Failed to delete availability (${response.statusCode})");
  }
}

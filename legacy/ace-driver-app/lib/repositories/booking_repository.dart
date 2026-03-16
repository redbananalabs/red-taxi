import 'package:flutter/material.dart';

import '../helpers/api_helper.dart';
import '../helpers/api_constants.dart';
import '../helpers/shared_pref_helper.dart';
import '../models/booking.dart';

class BookingRepository {

  Future<List<Bookings>> getTodaysJobs() async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final response = await ApiHelper.get(
      ApiConstants.todaysJobsEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response == null) return [];

    final bookingsList = response['bookings'] ?? [];
    return (bookingsList as List)
        .map((e) => Bookings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Bookings>> getFutureJobs() async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final response = await ApiHelper.get(
      ApiConstants.futureJobsEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response == null) return [];

    final bookingsList = response['bookings'] ?? [];
    return (bookingsList as List)
        .map((e) => Bookings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Bookings>> getCompletedJobs() async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final response = await ApiHelper.get(
      ApiConstants.completedJobsEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response == null) return [];

    return (response as List)
        .map((e) => Bookings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> setActiveJobs(int bookingId) async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final url = "${ApiConstants.setActiveJobEndpoint}?bookingId=$bookingId";
    print("🔗 FULL API URL: $url");

    final response = await ApiHelper.post(
      url,
      {},
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response == null) {
      print("ℹ️ Active job set (204 No content)");
      return;
    }

    print("🟢 Active job set response: $response");
  }

  // -------------------------
  // FIX: ACTIVE JOBS HANDLING
  // -------------------------
  Future<List<Bookings>> getActiveJobs() async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final response = await ApiHelper.get(
      ApiConstants.getActiveJobEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    // FIX: 204 → no active job
    if (response == null) {
      print("ℹ️ No active job available (204)");
      return [];
    }

    if (response is List) {
      return response
          .map((e) => Bookings.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response is int) {
      return [Bookings(bookingId: response)];
    }

    throw Exception("Unexpected response for Active Jobs");
  }

  Future<Bookings?> getBookingById(int bookingId) async {
    final token = await SharedPrefHelper.getToken();
    if (token == null) throw Exception("Unauthorized");

    final url = "${ApiConstants.findByIdEndpoint}?bookingId=$bookingId";

    final response = await ApiHelper.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response == null) return null;

    return Bookings.fromJson(response);
  }

Future<Bookings?> getArrivedById(int bookingId) async {
  final token = await SharedPrefHelper.getToken();
  if (token == null) throw Exception("Unauthorized");

  final url = "${ApiConstants.findByArrivedEndpoint}?bookingId=$bookingId";

  final response = await ApiHelper.get(
    url,
    headers: {"Authorization": "Bearer $token"},
  );

  if (response == null) return null;

  return Bookings.fromJson(response);

}

Future<List<Bookings>> getJobOffers() async {
  final token = await SharedPrefHelper.getToken();
  if (token == null) throw Exception("Unauthorized");

  final response = await ApiHelper.get(
    ApiConstants.getJobOffersEndpoint,
    headers: {"Authorization": "Bearer $token"},
  );

  if (response == null) return [];

  // API returns DIRECT LIST (not wrapped)
  if (response is List) {
    return response
        .map((e) => Bookings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  throw Exception("Unexpected response for Job Offers");
}


}

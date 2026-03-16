import 'dart:convert';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:http/http.dart' as http;
import '../helpers/shared_pref_helper.dart';

class CreateBookingRepository {
  Future<bool> createBooking({
    required String pickup,
    required String pickupPostcode,
    required String destination,
    required String destinationPostcode,
    required String name,
    required double mileage,
    required String mileageText,
    required double price,
    required int durationMinutes,
    required String durationText,
  }) async {
    try {
      final userData = await SharedPrefHelper.getUser();
      if (userData == null) throw Exception("User not logged in");

      final token = userData['token'];
      final userId = userData['userId'];

      final uri = Uri.parse(ApiConstants.createBookingEndpoint);

      final body = {
        "pickup": pickup,
        "pickupPostcode": pickupPostcode,
        "destination": destination,
        "destinationPostcode": destinationPostcode,
        "name": name,
        "userid": userId,
        "durationMinutes": durationMinutes,
        "mileage": mileage,
        "mileageText": mileageText,
        "durationText": durationText,
        "price": price,
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Create Booking successful");
        return true;
      } else {
        print("❌ Create Booking failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error in CreateBookingRepository: $e");
      return false;
    }
  }
}

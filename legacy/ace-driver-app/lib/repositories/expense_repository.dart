import 'dart:convert';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:http/http.dart' as http;
import '../helpers/shared_pref_helper.dart';

class ExpenseRepository {
  Future<bool> addExpense({
    required DateTime date,
    required String category,
    required String description,
    required double amount,
  }) async {
    try {
      final userData = await SharedPrefHelper.getUser();
      if (userData == null) {
        print("User not found in SharedPreferences");
        return false;
      }

      final userId = userData["userId"];
      final token = userData["token"];

      final Map<String, dynamic> requestBody = {
        "userId": userId,
        "date": date.toIso8601String(),
        "category": _mapCategoryToInt(category),
        "description": description,
        "amount": amount,
      };

      print("Request Body: $requestBody");

      final response = await http.post(
        Uri.parse(ApiConstants.addExpenseEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Response Status: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Expense added successfully!");
        return true;
      } else {
        print("Failed to add expense. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding expense: $e");
      return false;
    }
  }

  int _mapCategoryToInt(String category) {
    if (category == "Fuel") {
      return 0;
    } else if (category == "Parking/ULEZ") {
      return 1;
    } else if (category == "Insurance") {
      return 2;
    } else if (category == "MOT") {
      return 3;
    } else if (category == "DBS") {
      return 4;
    } else if (category == "Vehicle Badge") {
      return 5;
    } else if (category == "Maintenance") {
      return 6;
    } else if (category == "Certification") {
      return 7;
    } else if (category == "Other") {
      return 8;
    } else {
      return -1;
    }
  }
}

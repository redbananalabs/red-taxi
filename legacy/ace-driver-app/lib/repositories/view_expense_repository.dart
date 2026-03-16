import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/shared_pref_helper.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  // final String baseUrl = "https://dev.ace-api.1soft.co.uk/api/DriverApp";
  final String baseUrl = "https://ace-server.1soft.co.uk/api/DriverApp";

  Future<List<ExpenseModel>> getExpenses({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final uri = Uri.parse(
        "$baseUrl/GetExpenses?UserId=$userId&From=${from.toIso8601String()}&To=${to.toIso8601String()}",
      );

      print("GET URL: $uri");
      print("Token: $token");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => ExpenseModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch expenses");
      }
    } catch (e) {
      print("Error fetching expenses: $e");
      rethrow;
    }
  }
}

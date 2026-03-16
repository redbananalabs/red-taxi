import 'package:flutter/material.dart';
import '../models/earning_model.dart';
import '../repositories/earning_repository.dart';
import '../helpers/shared_pref_helper.dart'; // Assuming you store the token here

class EarningProvider extends ChangeNotifier {
  List<EarningModel> earnings = [];
  bool loading = false;

  final EarningRepository _repository = EarningRepository();

   double get totalAmount =>
      earnings.fold(0.0, (sum, e) => sum + e.netTotal);

 Future<void> fetchEarnings({
  required DateTime from,
  required DateTime to,
}) async {
  print("📢 EarningProvider → fetchEarnings() called!");
  print("📅 From: $from   To: $to");

  try {
    loading = true;
    notifyListeners();

    final token = await SharedPrefHelper.getToken();
    print("🔑 Token fetched: $token");

    if (token == null || token.isEmpty) {
      print("🚨 No token found in storage.");
      earnings = [];
      loading = false;
      notifyListeners();
      return;
    }

    final data = await _repository.fetchEarnings(
      token: token,
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );

    print("✅ Data fetched from repository: ${data.length} records");

    earnings = data.map((json) => EarningModel.fromJson(json)).toList();
  } catch (e) {
    print("🚨 Error fetching earnings in provider: $e");
    earnings = [];
  } finally {
    loading = false;
    notifyListeners();
  }
}

}

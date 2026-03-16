import 'package:flutter/material.dart';
import '../models/dash_total.dart';
import '../repositories/dash_total_repository.dart';

class DashTotalProvider extends ChangeNotifier {
  final DashTotalRepository _repository = DashTotalRepository();

  bool isLoading = false;
  DashTotal? dashTotal;

  Future<void> loadDashTotals(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.fetchDashTotals(token);
      dashTotal = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("❌ Dash Totals Error: $e");
    }
  }

  List<int> get earningsList {
    if (dashTotal?.totals == null) return [0, 0, 0, 0, 0, 0, 0];
    return [
      dashTotal!.totals!["Mon"] ?? 0,
      dashTotal!.totals!["Tue"] ?? 0,
      dashTotal!.totals!["Wed"] ?? 0,
      dashTotal!.totals!["Thu"] ?? 0,
      dashTotal!.totals!["Fri"] ?? 0,
      dashTotal!.totals!["Sat"] ?? 0,
      dashTotal!.totals!["Sun"] ?? 0,
    ];
  }
}

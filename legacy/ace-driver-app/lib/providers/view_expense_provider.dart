import 'package:ace_taxis/repositories/view_expense_repository.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ViewExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExpenses({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(
        userId: userId,
        from: from,
        to: to,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

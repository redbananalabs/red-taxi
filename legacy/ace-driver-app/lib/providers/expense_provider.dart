import 'package:flutter/material.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> addExpense({
    required DateTime date,
    required String category,
    required String description,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _expenseRepository.addExpense(
      date: date,
      category: category,
      description: description,
      amount: amount,
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }
}

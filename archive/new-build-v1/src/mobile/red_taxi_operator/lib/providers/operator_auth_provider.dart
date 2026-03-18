import 'package:flutter/foundation.dart';

/// Authentication state for the operator app.
class OperatorAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userId;
  String? _userName;
  String? _tenantId;
  String? _tenantName;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get tenantId => _tenantId;
  String? get tenantName => _tenantName;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: call API
      await Future.delayed(const Duration(seconds: 1));
      _isAuthenticated = true;
      _userId = 'op_001';
      _userName = 'Operator Admin';
      _tenantId = 't1';
      _tenantName = 'City Cabs';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed. Check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}

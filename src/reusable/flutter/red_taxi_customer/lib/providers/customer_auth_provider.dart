import 'package:flutter/foundation.dart';

/// Authentication state for the customer app.
class CustomerAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _phoneNumber;
  String? _userId;
  String? _userName;
  String? _email;
  String? _tenantId;
  String? _tenantName;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get phoneNumber => _phoneNumber;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get email => _email;
  String? get tenantId => _tenantId;
  String? get tenantName => _tenantName;
  String? get errorMessage => _errorMessage;

  void selectTenant(String id, String name) {
    _tenantId = id;
    _tenantName = name;
    notifyListeners();
  }

  Future<void> requestOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: call API to send OTP
      await Future.delayed(const Duration(seconds: 1));
      _phoneNumber = phone;
    } catch (e) {
      _errorMessage = 'Failed to send OTP. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: call API to verify OTP
      await Future.delayed(const Duration(seconds: 1));
      _isAuthenticated = true;
      _userId = 'user_001';
      _userName = 'Customer';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid OTP. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _phoneNumber = null;
    _userId = null;
    _userName = null;
    _email = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? email}) {
    if (name != null) _userName = name;
    if (email != null) _email = email;
    notifyListeners();
  }
}

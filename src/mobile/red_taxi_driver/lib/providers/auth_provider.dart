import 'package:flutter/foundation.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages authentication state for the driver app.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _token;
  String? _userId;
  String? _driverName;
  String? _email;

  AuthStatus get status => _status;
  String? get token => _token;
  String? get userId => _userId;
  String? get driverName => _driverName;
  String? get email => _email;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Check for an existing session on app launch.
  Future<void> checkAuthState() async {
    // Stub: in production, read from secure storage
    await Future.delayed(const Duration(seconds: 2));
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Attempt login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Stub: in production, call AuthService.login()
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success for any non-empty credentials
      if (email.isNotEmpty && password.isNotEmpty) {
        _token = 'stub_token_${DateTime.now().millisecondsSinceEpoch}';
        _userId = 'driver_001';
        _driverName = 'John Driver';
        _email = email;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Log out and clear credentials.
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _driverName = null;
    _email = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

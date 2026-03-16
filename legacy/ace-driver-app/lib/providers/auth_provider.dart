import 'package:flutter/material.dart';
import '../models/login.dart';
import '../repositories/auth_repository.dart';
import '../helpers/shared_pref_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool isLoading = false;
  Login? user;

  Future<String?> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _repository.loginUser(username, password);
      isLoading = false;
      notifyListeners();

      print("✅ Login Success: ${user?.toJson()}");

      if (user?.success == true && user?.token != null) {
        // Save to SharedPreferences
        await SharedPrefHelper.saveUser(
            token: user!.token!, fullName: user!.fullName ?? "", userId: user!.userId!);
        return null;
      } else {
        return user?.message ?? "Login failed";
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("❌ Login Error: $e");
      return e.toString();
    }
  }

  // Check if user already logged in
  Future<bool> isLoggedIn() async {
    final token = await SharedPrefHelper.getToken();
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    await SharedPrefHelper.clearUser();
    user = null;
    notifyListeners();
  }
}

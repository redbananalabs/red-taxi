import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool isLoading = false;
  bool isFetching = false;  // New: For getProfile loading state
  Profile? profile;

  // Future<bool> updateProfile(Profile updatedProfile) async {
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     final result = await _repository.updateProfile(updatedProfile);
  //     profile = result;
  //     isLoading = false;
  //     notifyListeners();

  //     debugPrint("✅ Profile Updated: ${result.toJson()}");
  //     return result.success ?? false;
  //   } catch (e) {
  //     isLoading = false;
  //     notifyListeners();
  //     debugPrint("❌ Update Profile Error: $e");
  //     return false;
  //   }
  // }

  Future<void> fetchProfile() async {
    isFetching = true;
    notifyListeners();

    try {
      final fetchedProfile = await _repository.getProfile();
      profile = fetchedProfile;
      isFetching = false;
      notifyListeners();

      debugPrint("✅ Profile Fetched: ${fetchedProfile.toJson()}");
    } catch (e) {
      isFetching = false;
      notifyListeners();
      debugPrint("❌ Fetch Profile Error: $e");
    }
  }
}

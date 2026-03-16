import '../helpers/api_helper.dart';
import '../helpers/api_constants.dart';
import '../helpers/shared_pref_helper.dart';
import '../models/profile.dart';

class ProfileRepository {
  Future<Profile> getProfile() async {
    final token = await SharedPrefHelper.getToken();

    if (token == null) {
      throw Exception("Unauthorized: No token found. Please login again.");
    }

    final response = await ApiHelper.get(
      ApiConstants.getProfileEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    return Profile.fromJson(response);
  }
}

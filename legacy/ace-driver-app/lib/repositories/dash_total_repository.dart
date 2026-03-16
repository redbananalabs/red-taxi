import '../helpers/api_constants.dart';
import '../helpers/api_helper.dart';
import '../models/dash_total.dart';

class DashTotalRepository {
  Future<DashTotal> fetchDashTotals(String token) async {
    final response = await ApiHelper.get(
      ApiConstants.dashTotalEndpoint,
      headers: {"Authorization": "Bearer $token"},
    );

    return DashTotal.fromJson(response);
  }
}

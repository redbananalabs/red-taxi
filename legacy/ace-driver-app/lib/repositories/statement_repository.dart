import 'dart:typed_data';

import '../helpers/api_constants.dart';
import '../helpers/api_helper.dart';

class StatementRepository {
  /// Fetch statements list
  Future<List<Map<String, dynamic>>> fetchStatements({
    required String token,
  }) async {
    if (token.isEmpty) {
      throw Exception("Token is empty. Please login again.");
    }

    final String url = ApiConstants.statementEndpoint;

    try {
      final response = await ApiHelper.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response == null) {
        throw Exception("No response from server");
      }

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ DOWNLOAD STATEMENT FILE
  Future<Uint8List> downloadStatement({
    required String token,
    required int statementId,
  }) async {
    if (token.isEmpty) {
      throw Exception("Token is empty. Please login again.");
    }

    final String url =
        "${ApiConstants.getDownloadStatementEndpoint}?statementId=$statementId";

    try {
      final response = await ApiHelper.getRaw(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response == null) {
        throw Exception("Failed to download statement");
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}

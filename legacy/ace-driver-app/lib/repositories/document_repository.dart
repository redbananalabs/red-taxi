import 'dart:io';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:dio/dio.dart';
import '../helpers/shared_pref_helper.dart';

class DocumentRepository {
  final Dio _dio = Dio();

  Future<void> uploadDocument({required int type, required File file}) async {
    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null)
        throw Exception("Token not found. Please login again.");

      final url = "${ApiConstants.uploadDocumentEndpoint}?type=$type";

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Upload failed with code: ${response.statusCode}");
      }

      print("Uploaded successfully → ${response.data}");
    } catch (e) {
      print("❌ Upload error: $e");
      rethrow;
    }
  }
}

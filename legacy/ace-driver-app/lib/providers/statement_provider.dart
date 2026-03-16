import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

import '../models/statement_model.dart';
import '../repositories/statement_repository.dart';
import '../helpers/shared_pref_helper.dart';

class StatementProvider extends ChangeNotifier {
  final StatementRepository _repository = StatementRepository();

  List<StatementModel> statements = [];
  bool loading = false;

  double get totalAmount => statements.fold(0.0, (sum, e) => sum + e.totalEarned);

  // ================= FETCH STATEMENTS =================
  Future<void> fetchStatements() async {
    loading = true;
    notifyListeners();

    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null || token.isEmpty) {
        statements = [];
        return;
      }

      final data = await _repository.fetchStatements(token: token);
      statements = data.map((e) => StatementModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching statements: $e");
      statements = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================= DOWNLOAD & SAVE TO FILES =================
  Future<void> downloadStatementFile(int statementId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null || token.isEmpty) throw Exception("User not authenticated");

      // 1️⃣ Request storage permission for Android <= 12
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) throw Exception("Storage permission denied");
      }

      // 2️⃣ Download PDF bytes
      final bytes = await _repository.downloadStatement(token: token, statementId: statementId);

      // 3️⃣ Determine folder
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!; // app folder
        final downloadDir = Directory("${dir.path}/Download");
        if (!await downloadDir.exists()) await downloadDir.create(recursive: true);
        dir = downloadDir;
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Unsupported platform");
      }

      // 4️⃣ Write file
      final filePath = "${dir.path}/statement_$statementId.pdf";
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      debugPrint("PDF saved at: $filePath");

      // 5️⃣ Open the file
      await OpenFilex.open(filePath);

    } catch (e) {
      debugPrint("Download statement error: $e");
      rethrow;
    }
  }
}

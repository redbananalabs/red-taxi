import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;

import '../models/log_request.dart';


class LogHelperLaravel {
  // Singleton Setup
  static final LogHelperLaravel _instance = LogHelperLaravel._internal();
  factory LogHelperLaravel() => _instance;
  LogHelperLaravel._internal();

  static const String _apiUrl = "https://acetaxislogger.backendcodersindia.com/api/logs";
  static const int _maxRetries = 3;

  /// Send log to Backend with Retry Logic
  Future<void> _sendLogToBackend(LogRequest logRequest, String tag, int retryCount) async {
    // Local Console Log
    debugPrint("[$tag] Sending log to backend: type=${logRequest.type}, message=${logRequest.message}");

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(logRequest.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ [$tag] Log sent successfully");
      } else {
        debugPrint("❌ [$tag] Failed to send log: HTTP ${response.statusCode}, Body: ${response.body}");
        _handleRetry(logRequest, tag, retryCount);
      }
    } catch (e) {
      debugPrint("❌ [$tag] Failed to send log: $e");
      _handleRetry(logRequest, tag, retryCount);
    }
  }

  void _handleRetry(LogRequest logRequest, String tag, int retryCount) {
    if (retryCount < _maxRetries) {
      debugPrint("🔄 [$tag] Retrying log send, attempt ${retryCount + 1}");
      // Add a small delay before retrying
      Future.delayed(const Duration(seconds: 2), () {
        _sendLogToBackend(logRequest, tag, retryCount + 1);
      });
    }
  }

  // --- Public Methods ---

  /// Error Log
  void e(String tag, String message) {
    debugPrint("ERR: [$tag] $message");
    final request = LogRequest(type: "error", message: message, source: tag);
    _sendLogToBackend(request, tag, 0);
  }

  /// Warning / Debug Log
  void d(String tag, String message) {
    debugPrint("DEBUG: [$tag] $message");
    final request = LogRequest(type: "warn", message: message, source: tag);
    _sendLogToBackend(request, tag, 0);
  }

  /// Info Log
  void i(String tag, String message) {
    debugPrint("INFO: [$tag] $message");
    final request = LogRequest(type: "info", message: message, source: tag);
    _sendLogToBackend(request, tag, 0);
  }
}
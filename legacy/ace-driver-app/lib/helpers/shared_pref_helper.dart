import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // Keys
  static const String _keyToken = "user_token";
  static const String _keyUserFullName = "user_fullName";
  static const String _keyUserId = "user_id";
  static const String _keyJobs = "jobs_list";
  static const String _keyFcmToken = "fcm_token";
  static const String _keyLastGuid = "last_guid";
  static const String _keyLastNavId = "last_nav_id";
  static const String _keyGpsLogs = "gps_logs";

  static const String _keyRawMessages = "saved_raw_messages";
  static const String _keyUploadedDocuments = "uploaded_documents";

  // ---------------------- SHIFT STATE ----------------------
  static const String _keyShiftActive = "shift_active";

  /// Save shift state
  static Future<void> setShiftActive(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShiftActive, isActive);
  }

  /// Get shift state
  static Future<bool> isShiftActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShiftActive) ?? false;
  }

  // ---------------------- USER DATA ----------------------
  static Future<void> saveUser({
    required String token,
    required String fullName,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserFullName, fullName);
    await prefs.setInt(_keyUserId, userId);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final fullName = prefs.getString(_keyUserFullName);
    final userId = prefs.getInt(_keyUserId);

    if (token != null && fullName != null && userId != null) {
      return {"token": token, "fullName": fullName, "userId": userId};
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserFullName);
    await prefs.remove(_keyUserId);
  }

  // ---------------------- FCM TOKEN ----------------------
  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  // ---------------------- JOBS ----------------------
  static Future<void> saveJobs(List<Map<String, dynamic>> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJobs, jsonEncode(jobs));
  }

  static Future<List<Map<String, dynamic>>> getJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jobsString = prefs.getString(_keyJobs);

    if (jobsString != null) {
      final jobsList = jsonDecode(jobsString);
      return List<Map<String, dynamic>>.from(
        jobsList.map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return [];
  }

  static Future<void> addOrUpdateJob(Map<String, dynamic> job) async {
    final jobs = await getJobs();
    final index = jobs.indexWhere((j) => j['jobId'] == job['jobId']);

    if (index != -1) {
      jobs[index] = job;
    } else {
      jobs.add(job);
    }

    await saveJobs(jobs);
  }

  static Future<void> clearJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJobs);
  }

  // ---------------------- NAVID & GUID ----------------------
  static Future<void> saveLastGuid(String guid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastGuid, guid);
  }

  static Future<void> saveLastNavId(String navId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastNavId, navId);
  }

  static Future<String?> getLastGuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastGuid);
  }

  static Future<String?> getLastNavId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastNavId);
  }

  /// Save uploaded document info
  static Future<void> saveUploadedDocument({
    required int docIndex,
    required String filePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> allDocs = {};

    final raw = prefs.getString(_keyUploadedDocuments);
    if (raw != null) {
      allDocs = jsonDecode(raw);
    }

    allDocs[docIndex.toString()] = {
      "filePath": filePath,
      "uploadedAt": DateTime.now().toIso8601String(),
    };

    await prefs.setString(_keyUploadedDocuments, jsonEncode(allDocs));
  }

  /// Get all uploaded documents
  static Future<Map<int, Map<String, dynamic>>> getUploadedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUploadedDocuments);

    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    return decoded.map(
      (key, value) =>
          MapEntry(int.parse(key), Map<String, dynamic>.from(value)),
    );
  }

  /// Clear document storage (optional)
  static Future<void> clearUploadedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUploadedDocuments);
  }

  // =======================================================
  //          ACTIVE JOB PERSISTENCE ADDED HERE
  // =======================================================

  static const String _keyActiveJobId = "active_job_id";

  /// Save active job id
  static Future<void> saveActiveJobId(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActiveJobId, jobId);
  }

  /// Get active job id
  static Future<int?> getActiveJobId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyActiveJobId);
  }

  /// Clear active job id
  static Future<void> clearActiveJobId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveJobId);
  }

  /// Save a new message to local list
  static Future<void> saveRawMessage(Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> current = prefs.getStringList(_keyRawMessages) ?? [];

    current.add(jsonEncode(message));

    await prefs.setStringList(_keyRawMessages, current);
  }

  /// Load all saved messages
  static Future<List<Map<String, dynamic>>> getRawMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keyRawMessages) ?? [];

    return saved
        .map((msg) => jsonDecode(msg))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> deleteRawMessageAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keyRawMessages) ?? [];

    if (index >= 0 && index < saved.length) {
      saved.removeAt(index);
      await prefs.setStringList(_keyRawMessages, saved);
    }
  }

  // =======================================================
  //               LIVE GPS LOGS STORAGE
  // =======================================================

  /// Save one GPS log (newest on top)
  static Future<void> saveGpsLog(Map<String, dynamic> log) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> logs = prefs.getStringList(_keyGpsLogs) ?? [];

    logs.insert(0, jsonEncode(log)); // newest first

    // Optional: limit logs to last 100 entries
    if (logs.length > 100) {
      logs = logs.sublist(0, 100);
    }

    await prefs.setStringList(_keyGpsLogs, logs);
  }

  /// Save a list of GPS logs
  static Future<void> saveGpsLogs(List<Map<String, dynamic>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsStringList = logs.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_keyGpsLogs, logsStringList);
  }

  /// Delete a GPS log at a specific index
  static Future<void> deleteGpsLogAt(int index) async {
    final logs = await getGpsLogs();
    if (index >= 0 && index < logs.length) {
      logs.removeAt(index);
      await saveGpsLogs(logs); // ✅ Save the updated list
    }
  }

  /// Load all GPS logs
  static Future<List<Map<String, dynamic>>> getGpsLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_keyGpsLogs) ?? [];

    return logs.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Clear all GPS logs
  static Future<void> clearGpsLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGpsLogs);
  }
}

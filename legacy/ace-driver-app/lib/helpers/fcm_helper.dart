import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/helpers/api_helper.dart';
import 'package:ace_taxis/helpers/api_constants.dart';

class FCMHelper {
  static final FCMHelper _instance = FCMHelper._internal();
  factory FCMHelper() => _instance;
  FCMHelper._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM token and update server
  Future<void> initFCM(String userId) async {
    try {
      // 1️⃣ Get FCM token from Firebase
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        print("⚠️ Failed to get FCM token from Firebase");
        return;
      }

      print("🔹 FCM Token: $fcmToken");

      // 2️⃣ Save token locally
      await SharedPrefHelper.saveFcmToken(fcmToken);

      // 3️⃣ Get Authorization token
      String? authToken = await SharedPrefHelper.getToken();
      if (authToken == null) {
        print("⚠️ No auth token found. User might not be logged in yet.");
        return;
      }

      // 4️⃣ Send FCM token to server
      await ApiHelper.post(
        ApiConstants.updateFcmTotalEndpoint,
        {
          "fcm": fcmToken,
        },
        headers: {
          "Authorization": "Bearer $authToken",
        },
      );

      print("✅ FCM token sent to server for user ID: $userId");
    } catch (e, s) {
      print("❌ Failed to update FCM token: $e\n$s");
    }
  }
}

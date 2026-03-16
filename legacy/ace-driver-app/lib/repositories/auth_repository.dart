// import 'dart:convert';
// import '../helpers/api_helper.dart';
// import '../helpers/api_constants.dart';
// import '../helpers/shared_pref_helper.dart';
// import '../helpers/firebase_helper.dart';
// import '../models/login.dart';

// class AuthRepository {
//   Future<Login> loginUser(String username, String password) async {
//     final body = {
//       "username": username,
//       "password": password,
//     };

//     print("✅ API URL: ${ApiConstants.loginEndpoint}");
//     print("✅ Request Body: $body");

//     final response = await ApiHelper.post(ApiConstants.loginEndpoint, body);
//     print("✅ Response Body: $response");

//     final loginData = Login.fromJson(response);

//     if (loginData.success == true && loginData.token != null) {
//       print("✅ Login Success: ${jsonEncode(response)}");

//       // ✅ Step 1: Save user details in SharedPreferences
//       await SharedPrefHelper.saveUser(
//         token: loginData.token!,
//         fullName: loginData.fullName ?? '',
//         userId: loginData.userId ?? 0,
//       );

//       // ✅ Step 2: Fetch stored FCM token (from prepareFirebase)
//       final fcmToken = await SharedPrefHelper.getFcmToken();

//       // ✅ Step 3: Upload FCM token to server if available
//       if (fcmToken != null && fcmToken.isNotEmpty) {
//         print("🚀 Uploading FCM token after login...");
//         await FirebaseHelper().updateFcmTokenToServer(fcmToken);
//       } else {
//         print("⚠️ FCM token not found locally — skipping update.");
//       }
//     } else {
//       print("❌ Login failed or no token returned.");
//     }

//     return loginData;
//   }
// }




import 'dart:convert';
import '../helpers/api_helper.dart';
import '../helpers/api_constants.dart';
import '../helpers/shared_pref_helper.dart';
import '../helpers/firebase_helper.dart';
import '../models/login.dart';

class AuthRepository {
  Future<Login> loginUser(String username, String password) async {
    final body = {
      "username": username,
      "password": password,
    };

    print("========================================");
    print("🔐 LOGIN REQUEST");
    print("➡️ API URL: ${ApiConstants.loginEndpoint}");
    print("➡️ Request Body: $body");
    print("========================================");

    // 🔥 Call API
    final response = await ApiHelper.post(ApiConstants.loginEndpoint, body);

    print("📥 RAW API RESPONSE: $response");

    // 🔥 FIX: Parse *only* the API body
    final loginData = Login.fromJson(response["body"] ?? {});

    print("📦 Parsed Login Data: ${jsonEncode(loginData.toJson())}");

    // 🔥 Check login success
    if (loginData.success == true && loginData.token != null) {
      print("✅ LOGIN SUCCESS!");
      print("🔑 Token: ${loginData.token}");
      print("👤 UserId: ${loginData.userId}");

      // 🔥 Save User Details
      await SharedPrefHelper.saveUser(
        token: loginData.token!,
        fullName: loginData.fullName ?? '',
        userId: loginData.userId ?? 0,
      );

      // 🔥 Load stored FCM token
      final fcmToken = await SharedPrefHelper.getFcmToken();

      // 🔥 Upload FCM token to server
      if (fcmToken != null && fcmToken.isNotEmpty) {
        print("🚀 Uploading FCM token to server...");
        await FirebaseHelper().updateFcmTokenToServer(fcmToken);
      } else {
        print("⚠️ No FCM token found — skipping update.");
      }
    } else {
      print("❌ LOGIN FAILED — API returned failure or missing token.");
    }

    print("========================================");

    return loginData;
  }
}

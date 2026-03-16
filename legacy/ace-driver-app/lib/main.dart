import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ace_taxis/helpers/firebase_helper.dart';
import 'package:ace_taxis/providers/app_providers.dart';
import 'package:ace_taxis/screens/splash_screen.dart';
import 'package:ace_taxis/helpers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully.");
  } catch (e, s) {
    print("⚠️ Firebase init failed: $e\n$s");
  }

  // Ask for notification permission
  try {
    final status = await Permission.notification.request();
    print("🔔 Notification permission: $status");
  } catch (e) {
    print("⚠️ Notification permission request failed: $e");
  }

  // 🔹 Load saved theme before app start
  await ThemeController.loadSavedTheme();

  // Initialize Firebase messaging (no context required)
  await FirebaseHelper().initializeFirebaseWithoutContext();

  runApp(AppProviders.init(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        try {
          await FirebaseHelper().initFirebase(ctx);
          print("✅ Firebase messaging listeners attached safely.");
        } catch (e, s) {
          print("🚨 Firebase listener init failed: $e\n$s");
        }
      } else {
        print("⚠️ navigatorKey context unavailable after frame build.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'Ace Taxi Driver',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,

          restorationScopeId: null, // ⛔ DISABLE Android route restore

          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:ace_taxis/helpers/colors_helper.dart';
import 'package:ace_taxis/helpers/log_helper_laravel.dart';
import 'package:ace_taxis/screens/job_offer_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../repositories/job_repository.dart';
import '../helpers/shared_pref_helper.dart';
import '../helpers/api_constants.dart';
import '../models/booking.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  factory FirebaseHelper() => _instance;
  FirebaseHelper._internal();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  bool _isNotificationPluginReady = false;
  final LogHelperLaravel _logger = LogHelperLaravel();
  final String _logTag = "FirebaseHelper";

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Driver Notifications',
    description: 'Driver job notifications',
    importance: Importance.high,
  );

  String? _fcmToken;
  final FlutterTts _tts = FlutterTts();
  bool unallocatedDialogOpen = false;
  bool cancelDialogOpen = false;
  bool rawNotificationDialogOpen = false;
  bool specialDialogOpen = false;
  Timer? _globalDialogTimer;
  DateTime? _lastTtsTime;
  String? _lastTtsMessage;
  bool _isTerminatedApp = false;
  bool _openedFromTerminatedNotification = false;
  bool _lastHandledGuidWasExpired = false;
  String? _lastHandledGuid;
  bool _notificationHandledOnce = false;
  bool _anyDialogOpen = false;
  bool _fullScreenJobOpen = false;
  Bookings? _currentFullScreenBooking;

  // --- INITIALIZATION ---

  Future<void> initializeFirebaseWithoutContext() async {
    _messaging ??= FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin ??= FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    try {
      await _flutterLocalNotificationsPlugin!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) async {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _logger.i(_logTag, "Notification clicked via Local Notification. Payload: ${response.payload}");
            _handleNotificationClick(navigatorKey.currentContext, response.payload!);
          }
        },
      );

      await _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      _isNotificationPluginReady = true;
      _logger.i(_logTag, "Firebase & Local Notifications initialized successfully.");
    } catch (e) {
      _logger.e(_logTag, "Local Notification init failed: $e");
    }

    await _messaging!.requestPermission(alert: true, badge: true, sound: true);

    _fcmToken = await _messaging!.getToken();
    if (_fcmToken != null) {
      _logger.i(_logTag, "FCM Token retrieved: $_fcmToken");
      await SharedPrefHelper.saveFcmToken(_fcmToken!);
      await updateFcmTokenToServer(_fcmToken!);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _logger.i(_logTag, "FCM Token refreshed by system.");
      await SharedPrefHelper.saveFcmToken(newToken);
      await updateFcmTokenToServer(newToken);
    });
  }

  Future<void> initFirebase(BuildContext context) async {
    _messaging ??= FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _logger.i(_logTag, "Foreground Notification Received: ${message.data['navid']}");
      _notificationHandledOnce = false;
      _lastHandledGuid = null;
      await _handleNotificationPayload(context, message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _logger.i(_logTag, "Notification clicked from Background state.");
      _openedFromTerminatedNotification = true;
      _isTerminatedApp = true;
      if (navigatorKey.currentContext != null) {
        await _handleNotificationPayload(navigatorKey.currentContext!, message.data);
      }
      _isTerminatedApp = false;
      _openedFromTerminatedNotification = false;
    });

    final initialMessage = await _messaging!.getInitialMessage();
    if (initialMessage != null) {
      _logger.i(_logTag, "App launched from Terminated state via Notification tap.");
      _isTerminatedApp = true;
      _openedFromTerminatedNotification = true;
      if (navigatorKey.currentContext != null) {
        await _handleNotificationPayload(navigatorKey.currentContext!, initialMessage.data);
      }
      _isTerminatedApp = false;
      _openedFromTerminatedNotification = false;
    }
  }

  // --- PAYLOAD HANDLING ---

  Future<void> _handleNotificationPayload(BuildContext context, Map<String, dynamic> data) async {
    final tag = "NotificationPayload";
    try {
      final normalizedData = <String, dynamic>{};
      data.forEach((key, value) => normalizedData[key.toLowerCase()] = value);

      final navId = int.tryParse(normalizedData['navid']?.toString() ?? '0') ?? 0;
      final guid = normalizedData['guid']?.toString() ?? '';
      final bookingId = normalizedData['bookingid']?.toString() ?? '';

      if (guid.isNotEmpty && _lastHandledGuid == guid && _notificationHandledOnce) {
        _logger.d(tag, "Duplicate Notification Blocked. GUID: $guid");
        return;
      }

      _lastHandledGuid = guid;
      _notificationHandledOnce = true;

      _logger.i(tag, "Processing Payload -> NavID: $navId, GUID: $guid");

      final speakText = switch (navId) {
        1 => "New job received",
        2 => "Your job is unallocated",
        3 => "Your job has been amended",
        4 => "Your job has been cancelled",
        5 => "New message received",
        _ => "New message received",
      };

      if (!_openedFromTerminatedNotification) speakNotification(speakText);

      if (guid.isNotEmpty) await SharedPrefHelper.saveLastGuid(guid);
      await SharedPrefHelper.saveLastNavId(navId.toString());

      if (navId == 5) {
        _logger.i(tag, "Routing to Message Dialog (NavID 5)");
        _showRawNotificationDialog(context, data);
        _notificationHandledOnce = false;
        return;
      }

      if (guid.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _fetchAndShowJobOfferWithFullDetails(context, guid, navId);
      } else if (bookingId.isNotEmpty) {
        await _handleNotificationClick(context, bookingId, navId: navId);
      }
      _notificationHandledOnce = false;
    } catch (e) {
      _logger.e(tag, "Error parsing payload: $e");
      _notificationHandledOnce = false;
    }
  }

  // --- JOB FETCHING LOGIC ---

  Future<void> _fetchAndShowJobOfferWithFullDetails(BuildContext context, String guid, int navId) async {
    final tag = "JobDetailFetch";
    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null) return;

      final response = await http.get(Uri.parse("${ApiConstants.retrieveJobOfferEndpoint}?guid=$guid"), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final basicBooking = Bookings.fromJson(data);
        final bookingId = basicBooking.bookingId?.toString();

        if (_fullScreenJobOpen && _currentFullScreenBooking?.bookingId != bookingId && navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
          _fullScreenJobOpen = false;
        }

        if (bookingId != null && bookingId.isNotEmpty) {
          final fullData = await JobRepository.getJobById(bookingId, token: token);
          if (fullData != null && fullData.isNotEmpty) {
            final fullBooking = Bookings.fromJson(fullData);
            navId == 1 && !_isTerminatedApp ? navigateToFullScreenJobOffer(context, fullBooking, guid: guid) : _showJobDialog(context, fullBooking, navId);
          } else {
            navId == 1 ? navigateToFullScreenJobOffer(context, basicBooking, guid: guid) : _showJobDialog(context, basicBooking, navId);
          }
        } else {
          navId == 1 ? navigateToFullScreenJobOffer(context, basicBooking, guid: guid) : _showJobDialog(context, basicBooking, navId);
        }
      } else {
        _logger.d(tag, "Job API 404 for GUID: $guid");
        if (_fullScreenJobOpen && navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
          _fullScreenJobOpen = false;
        }
        // _showJobExpiredDialog(context);
      }
    } catch (e) { _logger.e(tag, "Fetch Error: $e"); }
  }

  // --- UI DIALOGS ---

  void _showRawNotificationDialog(BuildContext context, Map<String, dynamic> rawData) {
    final String message = rawData['message']?.toString() ?? ' ';
    final String sentBy = rawData['sentBy']?.toString() ?? ' ';
    String formattedDateTime = '';
    final String rawDateTime = rawData['datetime']?.toString().trim() ?? '';

    if (rawDateTime.isNotEmpty) {
      try {
        final DateTime parsedTime = DateFormat('dd/MM/yyyy HH:mm').parse(rawDateTime);
        formattedDateTime = formatDate(parsedTime); // Restored use of formatDate
      } catch (e) { _logger.e("RawDialog", "Date parse error: $e"); }
    }

    safeShowDialog(
      context: context,
      dialogFlag: rawNotificationDialogOpen,
      setFlag: (v) => rawNotificationDialogOpen = v,
      autoDismiss: true,
      dismissSeconds: 10,
      builder: (ctx) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.98,
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                      child: Row(
                        children: [
                          const Icon(Icons.message_outlined, color: Colors.white, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(child: Text("Message", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19))),
                          Text(formattedDateTime, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("From: $sentBy", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 12),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showJobExpiredDialog(BuildContext context, {String message = "This job has expired"}) {
    final tag = "JobExpiredDialog";
    if (_lastHandledGuidWasExpired && _lastHandledGuid != null) return;
    if (!context.mounted && (navigatorKey.currentContext == null || !navigatorKey.currentContext!.mounted)) return;

    _lastHandledGuidWasExpired = true;
    safeShowDialog(
      context: navigatorKey.currentContext ?? context,
      dialogFlag: false,
      setFlag: (_) {},
      autoDismiss: true,
      dismissSeconds: 5,
      builder: (ctx) => _buildExpiredDialog(ctx, message),
    );
  }

  Widget _buildExpiredDialog(BuildContext ctx, String message) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.98,
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  child: const Row(children: [Icon(Icons.error_outline, color: Colors.white, size: 24), SizedBox(width: 10), Text("Job Expired", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19))]),
                ),
                Padding(padding: const EdgeInsets.all(16), child: Text(message, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary))),
                Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(right: 16), child: ElevatedButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  String formatDate(DateTime? date) {
    if (date == null) return "--/--/---- --:--";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> safeShowDialog({
    required BuildContext context,
    required bool dialogFlag,
    required Function(bool) setFlag,
    required WidgetBuilder builder,
    bool autoDismiss = false,
    int dismissSeconds = 5,
  }) async {
    if (_anyDialogOpen || dialogFlag) return;
    _anyDialogOpen = true;
    setFlag(true);
    _globalDialogTimer?.cancel();

    showDialog(
      context: navigatorKey.currentContext ?? context,
      barrierDismissible: false,
      builder: (ctx) {
        if (autoDismiss) {
          _globalDialogTimer = Timer(Duration(seconds: dismissSeconds), () {
            if (ctx.mounted) Navigator.of(ctx, rootNavigator: true).pop();
          });
        }
        return builder(ctx);
      },
    ).then((_) {
      _globalDialogTimer?.cancel();
      setFlag(false);
      _anyDialogOpen = false;
    });
  }

  Future<void> speakNotification(String message) async {
    final now = DateTime.now();
    if (_lastTtsTime != null && now.difference(_lastTtsTime!).inSeconds < 4 && _lastTtsMessage == message) return;
    _lastTtsTime = now;
    _lastTtsMessage = message;
    _logger.i(_logTag, "TTS: $message");
    await _tts.stop();
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(message);
  }

  Future<void> _handleNotificationClick(BuildContext? context, String bookingId, {int navId = 0}) async {
    if (context == null || !context.mounted) return;
    if (_openedFromTerminatedNotification && navId == 1) return;
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null) return;
      final jobData = await JobRepository.getJobById(bookingId, token: token);
      if (jobData != null && jobData.isNotEmpty) _showJobDialog(context, Bookings.fromJson(jobData), navId);
    } catch (e) { _logger.e(_logTag, "Click Error: $e"); }
  }

  void _showJobDialog(BuildContext context, Bookings booking, int navId) {
    if (!context.mounted) return;
    _lastHandledGuidWasExpired = false;
    if (navId == 2) { showUnallocatedDialog(context, booking); return; }
    if (navId == 3) { _showSpecialDialog(context, booking); return; }
    if (navId == 4) { _showCancelDialog(context, booking); return; }
    if (navId == 1) { navigateToFullScreenJobOffer(context, booking); return; }
  }

  void _showCancelDialog(BuildContext context, Bookings booking) {
    safeShowDialog(context: context, dialogFlag: cancelDialogOpen, setFlag: (v) => cancelDialogOpen = v, autoDismiss: true, dismissSeconds: 8, builder: (ctx) {
      final dt = booking.pickupDateTime != null ? DateFormat('dd MMM yyyy | HH:mm').format(DateTime.parse(booking.pickupDateTime!)) : "--";
      return _buildNotificationDialog(ctx, "Job Cancelled (${booking.passengerName ?? '---'})", dt, "Your booking (${booking.bookingId}) has been cancelled.");
    });
  }

  void _showSpecialDialog(BuildContext context, Bookings booking) {
    safeShowDialog(context: context, dialogFlag: specialDialogOpen, setFlag: (v) => specialDialogOpen = v, autoDismiss: true, dismissSeconds: 8, builder: (ctx) {
      final dt = booking.pickupDateTime != null ? DateFormat('dd MMM yyyy | HH:mm').format(DateTime.parse(booking.pickupDateTime!)) : "--";
      return _buildNotificationDialog(ctx, "Job Amended (${booking.passengerName ?? '---'})", dt, "Your booking (${booking.bookingId}) has been amended.");
    });
  }

  void showUnallocatedDialog(BuildContext context, Bookings booking) {
    safeShowDialog(context: context, dialogFlag: unallocatedDialogOpen, setFlag: (v) => unallocatedDialogOpen = v, autoDismiss: true, dismissSeconds: 8, builder: (ctx) {
      final dt = booking.pickupDateTime != null ? DateFormat('dd MMM yyyy | HH:mm').format(DateTime.parse(booking.pickupDateTime!)) : "--";
      return _buildNotificationDialog(ctx, "Job Unallocated (${booking.passengerName ?? '---'})", dt, "Your booking (${booking.bookingId}) has been unallocated.");
    });
  }

  Widget _buildNotificationDialog(BuildContext ctx, String title, String dt, String body) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.98,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  child: Row(children: [Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))), Text(dt, style: const TextStyle(color: Colors.white70, fontSize: 13))]),
                ),
                Padding(padding: const EdgeInsets.all(20), child: Text(body, style: const TextStyle(fontSize: 17, color: AppColors.textPrimary))),
                Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(right: 16, bottom: 12), child: ElevatedButton(onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToFullScreenJobOffer(BuildContext context, Bookings booking, {String? guid}) {
    if (_fullScreenJobOpen && _currentFullScreenBooking?.bookingId == booking.bookingId) return;
    _fullScreenJobOpen = true;
    _currentFullScreenBooking = booking;
    Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenJobOffer(booking: booking))).then((_) {
      _fullScreenJobOpen = false;
      _currentFullScreenBooking = null;
    });
  }

  Future<void> updateFcmTokenToServer(String fcmToken) async {
    try {
      final token = await SharedPrefHelper.getToken();
      if (token == null || token.isEmpty) return;
      final response = await http.post(Uri.parse(ApiConstants.updateFcmTotalEndpoint), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode({"fcm": fcmToken}));
      if (response.statusCode == 200) _logger.i(_logTag, "FCM Token updated.");
    } catch (e) { _logger.e(_logTag, "FCM Error: $e"); }
  }
}
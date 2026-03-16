import 'dart:async';
import 'dart:convert';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:ace_taxis/helpers/location_task.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/models/booking.dart';
import 'package:ace_taxis/providers/dash_total_provider.dart';
import 'package:ace_taxis/providers/booking_provider.dart';
import 'package:ace_taxis/repositories/count_booking_provider.dart';
import 'package:ace_taxis/screens/booking_screen.dart';
import 'package:ace_taxis/screens/trip_details_screen.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  String selectedFilter = "Daily";
  String selectedTrip = "Job Offers Pending";
  bool isLocationOn = false;
  bool isToggleOn = true;
  Timer? _locationTimer;
  Timer? _jobAutoTimer;
  String token = "";
  BuildContext? _dialogContext;
  Timer? _autoRefreshTimer;

  bool _shiftActive = false;
  bool _isSendingShift = false;
  Bookings? bookingDetails;
  int _tickCount = 0;
  bool _gpsLoopRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTokenAndData();
    isToggleOn = true;
    _checkLocationOnStart();
    _loadActiveBooking();
    _jobAutoTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autoRefreshActiveBooking(),
    );
  }

  Future<void> init() async {
    _shiftActive = await SharedPrefHelper.isShiftActive();
    if (isToggleOn) await _startLiveLocationLogs();
  }

  Future<void> _loadTokenAndData() async {
    final userData = await SharedPrefHelper.getUser();
    token = userData?['token'] ?? '';
    final provider = Provider.of<DashTotalProvider>(context, listen: false);
    provider.loadDashTotals(token);
    final countProvider = Provider.of<CountBookingProvider>(
      context,
      listen: false,
    );
    countProvider.loadBookingCounts();
  }

  Future<void> _loadActiveBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.fetchActiveJob();
  }

  @override
  void dispose() {
    // _locationTimer?.cancel();
    _jobAutoTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _jobAutoTimer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _jobAutoTimer ??= Timer.periodic(
        const Duration(seconds: 5),
        (_) => _autoRefreshActiveBooking(),
      );
    }
  }

  Future<void> _autoRefreshActiveBooking() async {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      await bookingProvider.fetchActiveJob();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Auto refresh error: $e");
    }
  }

  // ------------------- LOCATION -------------------
  Future<void> _checkLocationOnStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(context);
    } else {
      setState(() => isLocationOn = true);
      if (isToggleOn) _startLiveLocationLogs();
    }
  }


  Future<void> _startLiveLocationLogs() async {
    if (_gpsLoopRunning) {
      debugPrint("GPS loop already running");
      return;
    }

    _gpsLoopRunning = true;
    debugPrint("GPS loop started");

    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint("Location service disabled");
      _gpsLoopRunning = false;
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Permission denied forever");
      _gpsLoopRunning = false;
      return;
    }

    await _startForegroundService();

    while (_gpsLoopRunning) {
      final cycleWatch = Stopwatch()..start();

      try {
        if (!isToggleOn) {
          debugPrint("Toggle OFF → skip GPS");
        } else {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
          ).timeout(const Duration(seconds: 10));

          final userData = await SharedPrefHelper.getUser();
          final token = userData?['token'] ?? '';
          final userId = userData?['userId'] ?? 0;

          if (token.isNotEmpty && userId != 0) {
            final speed = double.parse((position.speed * 2.23694).toStringAsFixed(2));

            final apiWatch = Stopwatch()..start();

            final http.Response rawResponse = await http.post(
              Uri.parse(ApiConstants.updateGpsEndpoint),
              headers: {
                "Authorization": "Bearer $token",
                "Content-Type": "application/json",
              },
              body: jsonEncode({
                "userId": userId,
                "longtitude": position.longitude,
                "latitude": position.latitude,
                "speed": speed,
                "heading": position.heading,
              }),
            );

            final statusCode = rawResponse.statusCode;
            debugPrint("📡 API STATUS → $statusCode");

            await SharedPrefHelper.saveGpsLog({
              "time": DateTime.now().toIso8601String(),
              "latitude": position.latitude,
              "longtitude": position.longitude,
              "speed": speed,
              "heading": position.heading,
              "status": statusCode,
            });

            apiWatch.stop();

            debugPrint(
              "GPS updated → ${position.latitude}, ${position.longitude}",
            );
            debugPrint("📡 API STATUS → $statusCode");
            debugPrint(
              "⏱ API time → ${apiWatch.elapsedMilliseconds} ms "
                  "(${(apiWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} sec)",
            );
          } else {
            debugPrint("Invalid token or userId");
          }
        }
      } catch (e) {
        debugPrint("GPS error: $e");
      }

      cycleWatch.stop();
      debugPrint("Total loop time → ${cycleWatch.elapsedMilliseconds} ms");

      await Future.delayed(const Duration(seconds: 10));
    }

    debugPrint("GPS loop stopped");
  }


  Future<void> sendDriverShift(int shiftStatus) async {
    if (_isSendingShift) return;
    _isSendingShift = true;
    try {
      final userData = await SharedPrefHelper.getUser();
      final token = userData?['token'] ?? '';
      final userId = userData?['userId'] ?? 0;
      if (token.isEmpty || userId == 0) return;

      final shiftDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());
      final uri = Uri.parse(ApiConstants.driverShiftEndpoint).replace(
        queryParameters: {
          "userid": userId.toString(),
          "status": shiftStatus.toString(),
          "shiftDate": shiftDate,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _shiftActive = shiftStatus == 1000;
        await SharedPrefHelper.setShiftActive(_shiftActive);
      }
    } catch (e) {
      debugPrint("Shift update error: $e");
    } finally {
      _isSendingShift = false;
    }
  }

  Future<void> stopLiveLocation() async {
    await FlutterForegroundTask.stopService();
    if (_shiftActive) await sendDriverShift(1001);
  }

  Future<void> _startForegroundService() async {
    LocationPermission permission = await Geolocator.requestPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        !serviceEnabled) {
      _showLocationDialog(context);
      return;
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_channel',
        channelName: 'Location Tracking',
        channelDescription: 'Live GPS tracking for Ace Taxis',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'ic_launcher',
        ),
        buttons: const [NotificationButton(id: 'stop', text: 'STOP')],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10000,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Ace Taxis - Live GPS',
        notificationText: 'Tracking location in background...',
        callback: startCallback,
      );
    }
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _dialogContext = context;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "For a better experience, your device will need to use Location Accuracy",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "The following settings should be on:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.pinkAccent,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Device location",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.gps_fixed, color: Colors.pinkAccent, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Location Accuracy, which provides more accurate location for apps and services.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "You can change this at any time in location settings. Manage settings or learn more",
                  style: TextStyle(fontSize: 13, color: Colors.purpleAccent),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white38,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "No, thanks",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await AppSettings.openAppSettings(
                            type: AppSettingsType.location,
                          );
                          Timer.periodic(const Duration(seconds: 2), (
                            timer,
                          ) async {
                            if (await Geolocator.isLocationServiceEnabled()) {
                              timer.cancel();
                              _dismissLocationDialog();
                              _startLiveLocationLogs();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Turn on",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dismissLocationDialog() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!, rootNavigator: true).pop();
      _dialogContext = null;
    }
  }

  Widget _buildLocationToggle() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        title: Text(
          isToggleOn ? "Send Location ON" : "Send Location OFF",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Switch(
          value: isToggleOn,
          activeColor: Colors.red,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: (val) {
            setState(() => isToggleOn = val);
            if (val) {
              _startLiveLocationLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Live GPS updates started"),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              stopLiveLocation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Live GPS updates stopped"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeFilter(DashTotalProvider provider) {
    final filters = ["Daily", "Weekly", "Monthly"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedFilter = filter);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFCD1A21) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFCD1A21)
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsCard(DashTotalProvider provider) {
    final dash = provider.dashTotal;
    if (dash == null) return const SizedBox();

    double earnings = 0;
    int jobCount = 0;

    switch (selectedFilter) {
      case "Daily":
        earnings = (dash.earningsTotalToday ?? 0).toDouble();
        jobCount = dash.totalJobCountToday ?? 0;
        break;
      case "Weekly":
        earnings = (dash.earningsTotalWeek ?? 0).toDouble();
        jobCount = dash.totalJobCountWeek ?? 0;
        break;
      case "Monthly":
        earnings = (dash.earningsTotalMonth ?? 0).toDouble();
        jobCount = dash.totalJobCountMonth ?? 0;
        break;
    }

    final progress = (earnings / 1000).clamp(0.0, 1.0);
    final statusMessage = "Total Jobs: $jobCount";

    return _whiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildTimeFilter(provider),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(190, 190),
                      painter: _CircularArcPainter(value),
                    ),
                    Column(
                      children: [
                        Text(
                          selectedFilter,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: earnings),
                          duration: const Duration(seconds: 2),
                          builder: (context, animatedValue, _) {
                            return Text(
                              "£${animatedValue.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          statusMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Card _whiteCard({required Widget child}) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: child,
    );
  }

  String getScopeText(int? scope) {
    switch (scope) {
      case 0:
        return "Cash";
      case 1:
        return "Account";
      case 2:
        return "Rank";
      case 3:
        return "All";
      case 4:
        return "Card";
      default:
        return "Scope";
    }
  }

  Color getScopeColor(int? scope) {
    switch (scope) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.grey.shade400;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildActiveTrip(BuildContext context, Bookings booking) {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final theme = Theme.of(context);

    final bool isActive = bookingProvider.activeBookingId == booking.bookingId;

    // Format date
    String formattedDate = "--";
    if (booking.dateCreated != null) {
      try {
        final dt = DateTime.parse(booking.pickupDateTime!);
        formattedDate = DateFormat("d MMM yyyy, HH:mm").format(dt);
      } catch (_) {}
    }

    Future<void> openMap(BuildContext context, String? address) async {
      if (address == null || address.trim().isEmpty) return;

      try {
        final encodedAddress = Uri.encodeComponent(address);
        final Uri googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedAddress",
        );

        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open Google Maps")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Map Error: $e")));
      }
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor, // dynamic card color
            border: Border.all(
              color: isActive
                  ? Colors.red
                  : theme.dividerColor, // keep red for active
              width: 2,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- HEADER (Passenger + Price) --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            theme.dividerColor, // dynamic background
                        child: const Icon(
                          Icons.person,
                          color: Colors.red, // keep red
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.passengerName ?? "Passenger",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    booking.price != null
                        ? "£${booking.price!.toStringAsFixed(2)}"
                        : "--",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // keep green
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(color: theme.dividerColor, thickness: 1),
              const SizedBox(height: 12),

              // -------- PICKUP ADDRESS --------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 24,
                  ), // keep green
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final postcode = booking.pickupPostCode;
                        if (postcode != null && postcode.trim().isNotEmpty) {
                          openMap(context, postcode);
                        }
                      },
                      child: Text(
                        [
                          booking.pickupAddress ?? "Pickup Address",
                          booking.pickupPostCode,
                        ].where((e) => e != null && e.isNotEmpty).join(", "),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // -------- DROP ADDRESS --------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 24,
                  ), // keep red
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final postcode = booking.destinationPostCode;
                        if (postcode != null && postcode.trim().isNotEmpty) {
                          openMap(context, postcode);
                        }
                      },
                      child: Text(
                        [
                          booking.destinationAddress ?? "Drop Address",
                          booking.destinationPostCode,
                        ].where((e) => e != null && e.isNotEmpty).join(", "),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: theme.dividerColor, height: 28),

              // -------- SCOPE + DETAILS BUTTON --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getScopeColor(booking.scope),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getScopeText(booking.scope),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(booking: booking),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "Details",
                          style: TextStyle(
                            color: Colors.red, // keep red
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.red, // keep red
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // -------- ACTIVE TAG --------
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red, // keep red
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                "ACTIVE",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconForLabel(String label) {
    switch (label) {
      case "Job Upcoming":
        return Icons.schedule;
      case "Job Completed":
        return Icons.check_circle_outline;
        // case "Job Rejected":
        return Icons.cancel_outlined;
      default:
        return Icons.mail_outline;
    }
  }

// 1. Updated _jobStatusCard to accept the dynamic label
  Widget _jobStatusCard(String label, String value) {
    final bool isSelected = selectedTrip == label;
    final theme = Theme.of(context);

    // Define color constants
    final Color selectedColor = const Color(0xFFCD1A21);
    final Color cardColor = isSelected ? selectedColor : theme.cardColor;
    final Color textColor = isSelected ? Colors.white : theme.textTheme.bodyLarge!.color!;
    final Color iconColor = isSelected ? Colors.white : selectedColor;

    return GestureDetector(
      onTap: () {
        setState(() => selectedTrip = label);

        // Mapping labels to tab names for navigation
        final String targetTab = switch (label) {
          "Job Offers Pending" => "Job offers",
          "To Do" => "To do",
          "Job Upcoming" => "Future",
          "Jobs Completed Today" || "Total Jobs Today" => "Completed", // Handle both labels
          _ => "Job offers",
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(initialTabName: targetTab),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isSelected ? 6 : 3,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconForLabel(label), size: 28, color: iconColor),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 2. Updated _buildJobCounts with the conditional label logic
  Widget _buildJobCounts() {
    return Consumer<CountBookingProvider>(
      builder: (context, countProvider, _) {
        return Consumer<DashTotalProvider>(
          builder: (context, dashProvider, _) {
            final theme = Theme.of(context);

            // Logic for dynamic label based on stats
            final int completedCount = dashProvider.dashTotal?.totalJobCountToday ?? 0;
            final String completedLabel = (completedCount == 0)
                ? "Total Jobs Today"
                : "Jobs Completed Today";

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                // ... shadows logic ...
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _jobStatusCard(
                          "Job Offers Pending",
                          countProvider.jobOffersCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _jobStatusCard(
                          "To Do",
                          countProvider.jobReceivedCount.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _jobStatusCard(
                          "Job Upcoming",
                          countProvider.jobUpcomingCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _jobStatusCard(
                          completedLabel, // Use the dynamic label here
                          completedCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildEarningsChart(BuildContext context) {
    return Consumer<CountBookingProvider>(
      builder: (context, countProvider, _) {
        return Consumer<DashTotalProvider>(
          builder: (context, dashProvider, _) {
            final data = [
              {
                "label": "To Do",
                "value": countProvider.totalReceivedPrice,
                "color": const Color(0xFF2196F3),
              },
              {
                "label": "Upcoming",
                "value": countProvider.totalUpcomingPrice,
                "color": const Color(0xFF4CAF50),
              },
              {
                "label": "Earnings this week",
                "value": dashProvider.dashTotal?.earningsTotalWeek ?? 0.0,
                "color": const Color(0xFFCD1A21),
              },
            ];

            double maxValue = data
                .map((e) => e["value"] as double)
                .fold(0.0, (prev, element) => prev > element ? prev : element);

            if (maxValue == 0) {
              maxValue = 1.0;
            }

            return _whiteCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " Job Amount by Status (£)",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: data.map((item) {
                          final double value = item["value"] as double;
                          final double barHeight = (value / maxValue) * 150;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                width: 36,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: item["color"] as Color,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (item["color"] as Color)
                                          .withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              /// 💷 PRICE (THEME BASED)
                              Text(
                                "£${value.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),

                              const SizedBox(height: 4),

                              /// 🏷 LABEL (THEME BASED)
                              Text(
                                item["label"] as String,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.6),
                                    ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWalletAndHistory() {
    return _whiteCard(
      child: Consumer<DashTotalProvider>(
        builder: (context, provider, _) {
          final dash = provider.dashTotal;
          final theme = Theme.of(context);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text(
              "Earning since 1st of month",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
              ), // replaces grey
            ),
            subtitle: Text(
              "£${(dash?.earningsTotalMonth ?? 0).toStringAsFixed(2)}",
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ), // replaces black
            ),
          );
        },
      ),
    );
  }

  Widget _simpleListTile(String title, {VoidCallback? onTap}) {
    final theme = Theme.of(context);

    return _whiteCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        title: Text(title, style: theme.textTheme.bodySmall),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashTotalProvider = context.watch<DashTotalProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildLocationToggle(),
            const SizedBox(height: 20),

            // ✅ Updated to use DashTotalProvider
            dashTotalProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _buildEarningsCard(dashTotalProvider),

            const SizedBox(height: 20),
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                final activeBooking = bookingProvider.activeBooking;
                return FutureBuilder<Map<String, dynamic>?>(
                  future: SharedPrefHelper.getUser(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final loggedInUserId = snapshot.data!['userId'] as int;
                    if (activeBooking != null &&
                        (activeBooking.userId == loggedInUserId ||
                            activeBooking.userId == 0)) {
                      return _buildActiveTrip(context, activeBooking);
                    }
                    return const SizedBox(height: 20);
                  },
                );
              },
            ),

            const SizedBox(height: 20),
            _buildJobCounts(),
            const SizedBox(height: 20),
            _buildEarningsChart(context),
            const SizedBox(height: 20),
            _buildWalletAndHistory(),
            const SizedBox(height: 20),
            _simpleListTile(
              "Job History",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularArcPainter extends CustomPainter {
  final double progress;
  _CircularArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final Paint fg = Paint()
      ..shader =
          const SweepGradient(
            colors: [Color(0xFFCD1A21), Color(0xFFE35E5E)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1416 / 2,
      2 * 3.1416 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}

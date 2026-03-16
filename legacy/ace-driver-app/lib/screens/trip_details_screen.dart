import 'package:ace_taxis/helpers/log_helper_laravel.dart';
import 'package:ace_taxis/screens/booking_screen.dart';
import 'package:ace_taxis/screens/completed_job_screen.dart';
import 'package:ace_taxis/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';

enum BookingStatus {
  None,
  AcceptedJob,
  RejectedJob,
  Complete,
  RejectedJobTimeout,
}

class TripDetailsScreen extends StatefulWidget {
  final Bookings booking;
  const TripDetailsScreen({super.key, required this.booking});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool isArrived = false;
  bool showCompleteButton = false;
  bool isTodayBooking = false;
  bool _isLoading = false;
  BookingStatus status = BookingStatus.None;
  Bookings? currentBooking;
  final LogHelperLaravel _logger = LogHelperLaravel();

  @override
  void initState() {
    super.initState();
    currentBooking = widget.booking;
    _initializeStatus();
    checkIfTodayBooking();

    // ✅ AUTO-SYNC ON LOAD: Wait for first frame then check server status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfAlreadyActive();
    });
  }

  // --- CONFIRMATION DIALOG HELPER ---
  void _confirmAction({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        content: Text(message, style: const TextStyle(fontSize: 18)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: title.contains("Start") ? Colors.green : Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> refreshBooking() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    _logger.i("TripDetails", "Manual refresh for ID: ${widget.booking.bookingId}");
    final updated = await provider.getBookingById(widget.booking.bookingId!);
    if (updated != null) {
      setState(() {
        currentBooking = updated;
      });
      _initializeStatus();
      checkIfAlreadyActive();
      checkIfTodayBooking();
    }
  }

  void checkIfTodayBooking() {
    if (currentBooking!.pickupDateTime == null) return;
    DateTime? pickup = DateTime.tryParse(currentBooking!.pickupDateTime!);
    if (pickup == null) return;
    DateTime now = DateTime.now();
    isTodayBooking = pickup.year == now.year &&
        pickup.month == now.month &&
        pickup.day == now.day;
    setState(() {});
  }

  void _initializeStatus() {
    int rawStatus = currentBooking!.status ?? 0;
    switch (rawStatus) {
      case 1: status = BookingStatus.AcceptedJob; break;
      case 2: status = BookingStatus.RejectedJob; break;
      case 3: status = BookingStatus.Complete; break;
      case 4: status = BookingStatus.RejectedJobTimeout; break;
      default: status = BookingStatus.None;
    }
  }

  Map<String, dynamic>? getPaymentModeData(int? scope) {
    switch (scope) {
      case 0: return {"text": "Cash", "color": Colors.green};
      case 1: return {"text": "Account", "color": Colors.red};
      case 2: return {"text": "Rank", "color": const Color(0xFF03599F)};
      case 3: return {"text": "All", "color": Colors.orange};
      case 4: return {"text": "Card", "color": Colors.purple};
      default: return {"text": "NA", "color": Colors.grey};
    }
  }

  Map<String, dynamic> getPaymentStatusData(dynamic status) {
    int parsed = (status is int) ? status : int.tryParse(status?.toString() ?? '0') ?? 0;
    switch (parsed) {
      case 2: return {"text": "Paid", "color": Colors.green};
      case 3: return {"text": "Awaiting Payment", "color": Colors.orange};
      default: return {"text": "None", "color": Colors.red};
    }
  }

  // ✅ SYNC LOGIC: Checks if job is already active/arrived on server
  Future<void> checkIfAlreadyActive() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final tag = "TripDetails_Sync";
    setState(() => _isLoading = true);

    try {
      await provider.fetchActiveJob();
      if (provider.activeBooking?.bookingId == currentBooking!.bookingId) {
        int bookingStatus = provider.activeBooking!.status ?? 0;
        _logger.i(tag, "Sync: Job ${currentBooking!.bookingId} is active. Status: $bookingStatus");

        setState(() {
          currentBooking = provider.activeBooking;
          isArrived = (bookingStatus == 5);
          showCompleteButton = true;
        });
      }
    } catch (e) {
      _logger.e(tag, "Sync Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- START LOGIC ---
  Future<void> handleStart() async {
    if (_isLoading) return;
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final bookingId = currentBooking!.bookingId!;

    setState(() => _isLoading = true);
    try {
      await provider.fetchActiveJob();
      setState(() => _isLoading = false);

      if (provider.activeBooking != null && provider.activeBooking!.bookingId != bookingId) {
        _showConflictDialog(context, provider, provider.activeBooking!, bookingId);
      } else {
        _confirmAction(
          title: "Start Job",
          message: "Are you sure you want to start this job now?",
          onConfirm: () => _performStart(provider, bookingId),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performStart(BookingProvider provider, int id) async {
    setState(() => _isLoading = true);
    try {
      await provider.setActiveBooking(id);
      _logger.i("TripDetails_API", "Job $id started successfully.");

      if (mounted) {
        setState(() {
          isArrived = false;
          showCompleteButton = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job Started successfully!", style: TextStyle(fontSize: 16)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _logger.e("TripDetails_API", "Start API Failed: $e");
    }
  }


  // --- ARRIVED LOGIC ---
  Future<void> handleArrived() async {
    if (_isLoading || isArrived) return;

    _confirmAction(
      title: "Confirm Arrival",
      message: "Have you arrived at the pickup location?",
      onConfirm: () async {
        final bId = currentBooking!.bookingId!;
        final provider = Provider.of<BookingProvider>(context, listen: false);

        setState(() => _isLoading = true);
        try {
          final response = await provider.getArrivedById(bId);
          _logger.i("TripDetails_Arrived", "API Success for $bId");

          if (mounted) {
            setState(() {
              isArrived = true;
              showCompleteButton = true;
              _isLoading = false;
            });

            // ✅ Proper SnackBar implementation
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Arrival marked successfully!"),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error marking arrival."), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }

  void _showConflictDialog(BuildContext context, BookingProvider provider, Bookings active, int newId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Active Job Exists", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text("Job ${active.bookingId} is already active. What would you like to do?"),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); _performStart(provider, newId); },
            child: const Text("START ANYWAYS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => CompleteJobScreen(bookingId: active.bookingId!, price: active.price ?? 0.0)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("COMPLETE ACTIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    final showButtons = !(status == BookingStatus.Complete || status == BookingStatus.RejectedJob || status == BookingStatus.RejectedJobTimeout);
    if (!showButtons || !isTodayBooking) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : (!showCompleteButton ? handleStart : (isArrived ? null : handleArrived)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isArrived ? Colors.blue : (showCompleteButton ? Colors.orange : Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(!showCompleteButton ? "START" : "ARRIVED", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          if (showCompleteButton) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompleteJobScreen(bookingId: currentBooking!.bookingId!, price: currentBooking!.price ?? 0.0))),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("COMPLETE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = currentBooking!;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingScreen()))),
        title: const Text("Job Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshBooking,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Column(children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person, size: 28, color: theme.colorScheme.primary), const SizedBox(width: 8), Text("${na(booking.passengerName)} (${na(booking.bookingId)})", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 6),
                        Text(formatDateTime(booking.pickupDateTime), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    _paymentStatusRow(booking),
                    const SizedBox(height: 12),
                    _locationCard(context, "Pickup", "${na(booking.pickupAddress)}, ${na(booking.pickupPostCode)}", theme.colorScheme.primary, () => openMap(context, na(booking.pickupPostCode)), extra: (booking.isASAP ?? false) ? "ASAP" : null),
                    if (booking.vias != null) ...booking.vias!.asMap().entries.map((e) => _viaCard(e.key + 1, na(e.value is Map ? e.value['address'] : e.value))),
                    _locationCard(context, "Drop", "${na(booking.destinationAddress)}, ${na(booking.destinationPostCode)}", theme.colorScheme.error, () => openMap(context, na(booking.destinationPostCode)), extra: na(formatTime(booking.arriveBy)).isNotEmpty ? "By ${formatTime(booking.arriveBy)}" : null),
                    const SizedBox(height: 24),
                    _passengerInfoCard(booking),
                    const SizedBox(height: 12),
                    _detailsCard(booking),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _paymentStatusRow(Bookings booking) {
    final theme = Theme.of(context);
    Map<String, dynamic>? mode = getPaymentModeData(booking.scope);
    Color pCol = (booking.scope == 4) ? getPaymentStatusData(booking.paymentStatus)["color"] : mode!["color"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(Icons.payment, size: 24, color: theme.colorScheme.primary), const SizedBox(width: 8), Text("Payment Type", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22))]),
          Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14), decoration: BoxDecoration(color: pCol, borderRadius: BorderRadius.circular(20)), child: Text(mode?["text"] ?? "NA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
        ]),
        const Divider(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Journey Price", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
          Text("£${(booking.price ?? 0.0).toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
        ]),
      ]),
    );
  }

  Widget _viaCard(int index, String address) {
    return Container(
      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20), const SizedBox(width: 12), Expanded(child: Text("Via $index: $address", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)))]),
    );
  }

  Widget _passengerInfoCard(Bookings booking) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [
        Row(children: [Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), const Text("Passenger Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        const Divider(height: 24),
        _detailRow("Name", na(booking.passengerName)),
        _detailRow("Phone", na(booking.phoneNumber), isPhone: true),
        _detailRow("Count", na(booking.passengers)),
      ]),
    );
  }

  Widget _detailsCard(Bookings booking) {
    String time = (booking.durationMinutes != null) ? "${booking.durationMinutes! ~/ 60}h ${booking.durationMinutes! % 60}m" : "N/A";
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), const Text("Journey Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        const Divider(height: 24),
        _detailRow("Journey Price", "£${(booking.price ?? 0.0).toStringAsFixed(2)}"),
        _detailRow("Details", na(booking.details)),
        _detailRow("Duration", time),
        _detailRow("Distance", na(booking.mileageText)),
      ]),
    );
  }

  Widget _detailRow(String title, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(width: 10),
        Expanded(child: InkWell(
          onTap: isPhone ? () => launchUrl(Uri.parse("tel:${value.replaceAll(RegExp(r'[^0-9+]'), '')}"), mode: LaunchMode.externalApplication) : null,
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w500, color: isPhone ? Colors.blue : Colors.black, decoration: isPhone ? TextDecoration.underline : null)),
        )),
      ]),
    );
  }

  Widget _locationCard(BuildContext context, String title, String address, Color color, Function() onTap, {String? extra}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)), if (extra != null) Text(extra, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
          const SizedBox(height: 8),
          Row(children: [Icon(Icons.location_pin, color: color), const SizedBox(width: 12), Expanded(child: Text(address, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)))]),
        ]),
      ),
    );
  }
}

// --- GLOBAL HELPERS ---
String formatDateTime(String? date) => (date == null) ? "" : DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(date));
String formatTime(String? date) => (date == null) ? "" : DateFormat('HH:mm').format(DateTime.parse(date));
String na(dynamic value) => (value == null || value.toString().trim().isEmpty) ? "" : value.toString();

Future<void> openMap(BuildContext context, String? address) async {
  if (address == null || address.isEmpty) return;
  final String encodedAddress = Uri.encodeComponent(address);
  final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedAddress");
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
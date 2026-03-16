import 'dart:async';
import 'package:ace_taxis/helpers/colors_helper.dart';
import 'package:ace_taxis/helpers/firebase_helper.dart';
import 'package:ace_taxis/helpers/job_offer_helper.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/models/booking.dart';
import 'package:ace_taxis/screens/booking_screen.dart';
import 'package:ace_taxis/screens/trip_details_screen.dart';
import 'package:flutter/material.dart';

class FullScreenJobOffer extends StatefulWidget {
  final Bookings booking;
  final String? overrideGuid;

  const FullScreenJobOffer({
    super.key,
    required this.booking,
    this.overrideGuid,
  });
  @override
  State<FullScreenJobOffer> createState() => _FullScreenJobOfferState();
}

class _FullScreenJobOfferState extends State<FullScreenJobOffer> {
  bool hasResponded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --------------------------------------------------------------------
  // HELPERS
  // --------------------------------------------------------------------
  String na(dynamic v) {
    if (v == null) return "NA";
    final s = v.toString().trim();
    return s.isEmpty ? "NA" : s;
  }

  String get formattedDate {
    final raw = widget.booking.pickupDateTime;
    if (raw == null || raw.isEmpty) return "Date not available";

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return "Invalid date";

    return FirebaseHelper().formatDate(parsed);
  }

  String get paymentMode {
    switch (widget.booking.scope) {
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
        return "Unknown";
    }
  }

  List<String> get viaStops {
    final vias = widget.booking.vias;
    if (vias == null || vias.isEmpty) return [];

    return vias.map<String>((v) {
      String address = "NA";
      String pc = "";

      if (v is Map<String, dynamic>) {
        address = na(v['address'] ?? v['Address'] ?? v['stopAddress']);
        final post = na(v['postCode'] ?? v['postcode'] ?? v['PostCode']);
        pc = post == "NA" ? "" : ", $post";
      } else if (v is String) {
        address = na(v);
      }

      return "$address$pc";
    }).toList();
  }

  void _cancelTimers() {}

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen()),
      (route) => false,
    );
  }

  // --------------------------------------------------------------------
  // ACTIONS
  // --------------------------------------------------------------------
Future<void> _acceptJob() async {
  if (hasResponded) return;

  _cancelTimers();
  hasResponded = true;

  final bookingId = widget.booking.bookingId;

  // 🔑 GUID resolution (SAFE)
  String? guid = widget.overrideGuid ?? widget.booking.guid;

  // 🔄 fallback to SharedPref ONLY if still null
  guid ??= await SharedPrefHelper.getLastGuid();

  if (bookingId == null || guid == null || guid.isEmpty) {
    debugPrint("❌ Accept failed: bookingId or guid missing");
    return;
  }

  debugPrint("✅ Accept Job → bookingId=$bookingId, guid=$guid");

  final bool isSuccess = await JobOfferHelper.acceptJob(
    bookingId: bookingId,
    guid: guid,
  );

  if (!mounted) return;

  if (isSuccess) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailsScreen(booking: widget.booking),
      ),
    );
    return;
  }

    // ❌ FAILURE DIALOG (unchanged)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Job Status",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Job expired or invalid",
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
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

 Future<void> _rejectJob() async {
  if (hasResponded) return;

  _cancelTimers();
  hasResponded = true;

  final bookingId = widget.booking.bookingId;

  // 🔑 GUID resolution (SAFE)
  String? guid = widget.overrideGuid ?? widget.booking.guid;
  guid ??= await SharedPrefHelper.getLastGuid();

  if (bookingId == null || guid == null || guid.isEmpty) {
    debugPrint("❌ Reject failed: bookingId or guid missing");
    return;
  }

  debugPrint("✅ Reject Job → bookingId=$bookingId, guid=$guid");

  await JobOfferHelper.rejectJob(
    bookingId: bookingId,
    guid: guid,
  );

  if (!mounted) return;
  _goToHome();
}


  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BookingScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFCD1A21),
          title: const Text("Job Offer", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true, // ✅ back arrow stays
        ),

        body: Column(
          children: [
            // _buildProgressBar(),
            // _buildTimerText(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(booking),
                    _buildDate(),
                    _buildPrice(booking),
                    const SizedBox(height: 30),

                    _pickupCard(booking),
                    const SizedBox(height: 16),

                    ...viaStops.asMap().entries.map(
                      (e) => _viaCard(e.value, e.key),
                    ),

                    const SizedBox(height: 12),
                    _dropCard(booking),
                    const SizedBox(height: 30),

                    _jobDetails(booking),
                    const SizedBox(height: 40),

                    _mainButton(
                      text: "Accept Job",
                      color: Colors.green,
                      onTap: _acceptJob,
                    ),
                    const SizedBox(height: 12),

                    _mainButton(
                      text: "Reject Job",
                      color: Colors.red,
                      onTap: _rejectJob,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Bookings b) => Center(
    child: Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Icon(Icons.check, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          na(b.passengerName),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "#${b.bookingId ?? 'Unknown'}",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildDate() => Center(
    child: Text(
      formattedDate,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildPrice(Bookings b) => Center(
    child: Text(
      "£${(b.price ?? 0.0).toStringAsFixed(2)}",
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    ),
  );

  // --------------------------------------------------------------------
  // CARDS
  // --------------------------------------------------------------------
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
  );

  Widget _pickupCard(Bookings b) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Pickup",
              style: TextStyle(
                color: AppColors.scopeCash,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            if (b.isASAP == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.scopeCash,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ASAP",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _locationRow(AppColors.scopeCash, b.pickupAddress, b.pickupPostCode),
      ],
    ),
  );

  Widget _viaCard(String address, int index) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.greyBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: AppColors.scopeRank, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Via ${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _dropCard(Bookings b) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Drop",
          style: TextStyle(
            color: AppColors.scopeAccount,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _locationRow(
          AppColors.scopeAccount,
          b.destinationAddress,
          b.destinationPostCode,
        ),
      ],
    ),
  );

  Widget _locationRow(Color color, String? address, String? postcode) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.location_on, color: color, size: 26),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              na(address),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (postcode != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  na(postcode),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  // --------------------------------------------------------------------
  // JOB DETAILS
  // --------------------------------------------------------------------
  Widget _jobDetails(Bookings b) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.greyBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Job Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Divider(height: 20, color: AppColors.divider),
        _detailRow("Booking ID", na(b.bookingId)),
        _detailRow("Passengers", na(b.passengers)),
        _detailRow("Payment Mode", paymentMode),
        _detailRow(
          "Booked On",
          b.dateCreated != null
              ? FirebaseHelper().formatDate(DateTime.tryParse(b.dateCreated!)!)
              : "NA",
        ),
      ],
    ),
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black54, // 👈 slightly black
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  // --------------------------------------------------------------------
  // BUTTON
  // --------------------------------------------------------------------
  Widget _mainButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasResponded ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

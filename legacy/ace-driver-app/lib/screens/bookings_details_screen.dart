import 'package:ace_taxis/screens/completed_job_screen.dart';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking.dart';

class BookingsDetails extends StatefulWidget {
  final Bookings booking;

  const BookingsDetails({super.key, required this.booking});

  @override
  State<BookingsDetails> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<BookingsDetails> {
  bool isArrived = false;

  String getPaymentMode(int? scope) {
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
        return "Unknown";
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "--";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return "--";
    return DateFormat('EEEE, dd MMM yyyy – hh:mm a').format(parsed);
  }

  Future<void> callPassenger(String? number) async {
    if (number == null || number.trim().isEmpty) return;

    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse("tel:$cleanNumber");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Dialer not available");
      }
    } catch (e) {
      print("Call error: $e");
    }
  }

  Future<void> messagePassenger(String? number) async {
    if (number == null || number.isEmpty || number == "NA" || number == "na") return;
    final uri = Uri(scheme: "sms", path: number);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    // Convert vias to string list safely, including postcode
    List<String> viaList = [];
    if (booking.vias != null && booking.vias!.isNotEmpty) {
      for (int i = 0; i < booking.vias!.length; i++) {
        final via = booking.vias![i];
        String address = "--";
        String? postcode;
        if (via is Map<String, dynamic>) {
          address = via['address'] ?? "--";
          postcode = via['postCode'] ?? "";
        } else if (via is String) {
          address = via;
          postcode = "";
        }
        String fullVia = "Via ${i + 1}:\n$address";
        if (postcode != null && postcode.isNotEmpty) {
          fullVia += ", $postcode";
        }
        viaList.add(fullVia);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Job Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, size: 28, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "${booking.passengerName ?? "Passenger"} (${booking.bookingId ?? "--"})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatDate(booking.pickupDateTime),
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      isArrived = !isArrived;
                    });
                  },
                  icon: const Icon(Icons.flag, size: 18, color: Colors.blue),
                  label: Text(
                    isArrived ? "Picked Up" : "Arrived",
                    style: const TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.grey.shade300,
                  child: IconButton(
                    icon: const Icon(Icons.call, size: 20, color: Colors.black87),
                    onPressed: () => callPassenger(booking.phoneNumber),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.grey.shade300,
                  child: IconButton(
                    icon: const Icon(Icons.message, size: 20, color: Colors.black87),
                    onPressed: () => messagePassenger(booking.phoneNumber),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pickup & Drop with Vias
            _locationCard(
              title: "Pickup",
              address: [
                booking.pickupAddress ?? "Pickup Address",
                booking.pickupPostCode,
              ].where((e) => e != null && e.isNotEmpty).join(", "),
              color: Colors.green,
            ),
            if (viaList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: viaList.map((via) => _viaCard(via)).toList(),
                ),
              ),
            _locationCard(
              title: "Drop",
              address: [
                booking.destinationAddress ?? "Drop Address",
                booking.destinationPostCode,
              ].where((e) => e != null && e.isNotEmpty).join(", "),
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // Total Earning Dropdown
            _earningExpansionTile(booking),

            const SizedBox(height: 8),
            _infoCard(
              "Payment Mode",
              booking.paymentStatus == 1 ? "Paid" : getPaymentMode(booking.scope),
              highlight: true,
              extra: booking.scope == 1 && booking.accountNumber != null
                  ? "Account No: ${booking.accountNumber}"
                  : null,
            ),
            const SizedBox(height: 8),
            _infoCard("Booked By", booking.bookedByName ?? "--"),
            const SizedBox(height: 8),

            // Passenger Dropdown
            _passengerExpansionTile(booking),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFCD1A21),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            onPressed: () {
              if (booking.bookingId == null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Booking ID missing')));
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompleteJobScreen(
                    price: booking.price ?? 0,
                    bookingId: booking.bookingId!,
                  ),
                ),
              );
            },
            child: const Text("Complete Booking",
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // =================== Via Card ===================
  Widget _viaCard(String via) {
    return Container(
      width: double.infinity, // Match pickup & drop width
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.shade700),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.shade200,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.home, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              via,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // =================== Total Earning Dropdown ===================
  Widget _earningExpansionTile(Bookings booking) {
    String totalEarning =
        booking.price != null ? "£${booking.price!.toStringAsFixed(2)}" : "NA";

    String timeValue =
        booking.durationMinutes != null ? booking.durationMinutes.toString() : "NA";
    String distanceValue =
        booking.mileageText != null && booking.mileageText!.isNotEmpty
            ? booking.mileageText!
            : "NA";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Earning",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                totalEarning,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Time: $timeValue",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text("Distance: $distanceValue",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== Passenger Dropdown ===================
  Widget _passengerExpansionTile(Bookings booking) {
    String passengerName =
        booking.passengerName?.trim().isEmpty ?? true ? "NA" : booking.passengerName!;
    String email = booking.email?.trim().isEmpty ?? true ? "NA" : booking.email!;
    String phone = booking.phoneNumber?.trim().isEmpty ?? true ? "NA" : booking.phoneNumber!;
    String count = booking.passengers?.toString().isEmpty ?? true
        ? "NA"
        : booking.passengers.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: const Text(
            "Passengers",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person, size: 20, color: Colors.green),
                        SizedBox(width: 6),
                        Text("Passenger",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87)),
                      ],
                    ),
                    const Divider(thickness: 0.8, height: 14),
                    Text("Passenger Name: $passengerName",
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("Email: $email",
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("Phone Number: $phone",
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("Passenger Count: $count",
                        style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== Location Card with Title ===================
  static Widget _locationCard(
      {required String title, required String address, required Color color}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.location_on, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(address,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================== Info Card ===================
  static Widget _infoCard(String title, String value,
      {bool highlight = false, String? extra}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: highlight ? Colors.green : Colors.black),
            ),
          ]),
          if (extra != null) ...[
            const SizedBox(height: 4),
            Text(extra, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

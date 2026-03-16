// import 'package:ace_taxis/providers/complete_job_provider.dart';
// import 'package:ace_taxis/screens/booking_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CompleteJobScreen extends StatefulWidget {
//   final int bookingId;
//   final double price;

//   const CompleteJobScreen({
//     Key? key,
//     required this.bookingId,
//     required this.price,
//   }) : super(key: key);

//   @override
//   _CompleteJobScreenState createState() => _CompleteJobScreenState();
// }

// class _CompleteJobScreenState extends State<CompleteJobScreen> {
//   final TextEditingController paymentController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController waitingTimeController = TextEditingController(
//     text: '0',
//   );
//   final TextEditingController parkingController = TextEditingController(
//     text: '0',
//   );
//   final TextEditingController tipController = TextEditingController(
//     text: '0.00',
//   );

//   @override
//   void initState() {
//     super.initState();
//     priceController.text = widget.price.toStringAsFixed(2);
//   }

//   @override
//   void dispose() {
//     paymentController.dispose();
//     priceController.dispose();
//     waitingTimeController.dispose();
//     parkingController.dispose();
//     tipController.dispose();
//     super.dispose();
//   }

//   void _submit() async {
//     final provider = Provider.of<CompleteJobProvider>(context, listen: false);

//     final apiResponse = await provider.submitCompleteJob(
//       bookingId: widget.bookingId,
//       waitingTime: int.tryParse(waitingTimeController.text) ?? 0,
//       parkingCharge: int.tryParse(parkingController.text) ?? 0,
//       driverPrice: double.tryParse(priceController.text) ?? 0,
//       accountPrice: double.tryParse(paymentController.text) ?? 0,
//       tip: double.tryParse(tipController.text) ?? 0,
//     );

//     print("API Response → $apiResponse");

//     if (provider.errorMessage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Booking completed successfully!')),
//       );

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => BookingScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${provider.errorMessage}')),
//       );
//     }
//   }

//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Colors.grey),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFCD1A21), width: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<CompleteJobProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Complete Job",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFFCD1A21),
//         iconTheme: const IconThemeData(
//           color: Colors.white, // back arrow white
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: provider.isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.check_circle,
//                       size: 80,
//                       color: Colors.amber,
//                     ),
//                     const SizedBox(height: 20),

//                     // PAYMENT
//                     TextField(
//                       controller: paymentController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: _inputDecoration("Payment"),
//                     ),

//                     const SizedBox(height: 16),

//                     // PRICE (READ ONLY – SAME UI)
//                     TextField(
//                       controller: priceController,
//                       readOnly: true,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: _inputDecoration("Price"),
//                     ),

//                     const SizedBox(height: 16),

//                     // TIP (UNCHANGED)
//                     TextField(
//                       controller: tipController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: _inputDecoration("Tip"),
//                     ),

//                     const SizedBox(height: 30),

//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size.fromHeight(50),
//                         backgroundColor: const Color(0xFFCD1A21),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       onPressed: _submit,
//                       child: const Text(
//                         "Submit",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size.fromHeight(50),
//                         side: const BorderSide(color: Color(0xFFCD1A21)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text(
//                         "Close",
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Color(0xFFCD1A21),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:ace_taxis/helpers/uk_time.dart';
import 'package:ace_taxis/providers/booking_provider.dart';
import 'package:ace_taxis/providers/complete_job_provider.dart';
import 'package:ace_taxis/screens/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompleteJobScreen extends StatefulWidget {
  final int bookingId;
  final double price;

  const CompleteJobScreen({
    Key? key,
    required this.bookingId,
    required this.price,
  }) : super(key: key);

  @override
  _CompleteJobScreenState createState() => _CompleteJobScreenState();
}

class _CompleteJobScreenState extends State<CompleteJobScreen> {
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController waitingTimeController = TextEditingController(
    text: '0',
  );
  final TextEditingController parkingController = TextEditingController(
    text: '0',
  );
  final TextEditingController tipController = TextEditingController(
    text: '0.00',
  );

  @override
  void initState() {
    super.initState();
    priceController.text = widget.price.toStringAsFixed(2);
  }

  @override
  void dispose() {
    paymentController.dispose();
    priceController.dispose();
    waitingTimeController.dispose();
    parkingController.dispose();
    tipController.dispose();
    super.dispose();
  }

  Future<bool> _canCompleteJob() async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );

    // 🔹 Fetch booking using repository/provider
    final booking = await bookingProvider.getBookingById(widget.bookingId);

    // ❌ Booking not found
    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking details not found."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // ❌ Pickup time missing
    final pickupDateTimeStr = booking.pickupDateTime;
    if (pickupDateTimeStr == null || pickupDateTimeStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pickup time not available yet. Please wait."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // 🇬🇧 Pickup time in UK
    final pickupUkTime = UkTime.parse(pickupDateTimeStr);

    // ⏱ Pickup + 5 minutes
    final allowedTime = pickupUkTime.add(const Duration(minutes: 5));

    // 🇬🇧 Current UK time (NOT device time)
    final nowUkTime = UkTime.now();

    debugPrint("Pickup UK Time  : $pickupUkTime");
    debugPrint("Allowed UK Time : $allowedTime");
    debugPrint("Now UK Time     : $nowUkTime");

    // ❌ Too early (before or equal pickup + <5 mins)
    if (nowUkTime.isBefore(allowedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Can not complete job before pickup time"
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // ✅ Allowed
    return true;
  }

  void _submit() async {
    final canProceed = await _canCompleteJob();
    if (!canProceed) return; // 👈 stay on same page

    final provider = Provider.of<CompleteJobProvider>(context, listen: false);

    await provider.submitCompleteJob(
      bookingId: widget.bookingId,
      waitingTime: int.tryParse(waitingTimeController.text) ?? 0,
      parkingCharge: int.tryParse(parkingController.text) ?? 0,
      driverPrice: double.tryParse(priceController.text) ?? 0,
      accountPrice: double.tryParse(paymentController.text) ?? 0,
      tip: double.tryParse(tipController.text) ?? 0,
    );

    if (provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking completed successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCD1A21), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompleteJobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complete Job",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFCD1A21),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),

              // Payment Field
              TextField(
                controller: paymentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Payment"),
              ),

              const SizedBox(height: 16),


              // Price Field (Now Editable)
              TextField(
                controller: priceController,
                // readOnly: true,  <-- Removed to make it editable
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Price"),
              ),

              const SizedBox(height: 16),

              // Tip Field
              TextField(
                controller: tipController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Tip"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFFCD1A21),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

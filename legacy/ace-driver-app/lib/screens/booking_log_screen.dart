// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/booking_log_provider.dart';
// import '../models/create_booking_model.dart';

// class BookingLogScreen extends StatelessWidget {
//   const BookingLogScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<CreateBookingModel> logs = context
//         .watch<BookingLogProvider>()
//         .logs;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F0F0),
//       appBar: AppBar(
//         title: const Text("Booking Logs"),
//         backgroundColor: const Color(0xFFCD1A21),
//         foregroundColor: Colors.white,
//       ),
//       body: logs.isEmpty
//           ? const Center(
//               child: Text(
//                 "No booking logs available",
//                 style: TextStyle(fontSize: 16),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: logs.length,
//               itemBuilder: (context, index) {
//                 final b = logs[index];

//                 // Fade + slide animation
//                 return TweenAnimationBuilder(
//                   tween: Tween<double>(begin: 0, end: 1),
//                   duration: Duration(milliseconds: 400 + (index * 100)),
//                   builder: (context, double value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Transform.translate(
//                         offset: Offset(0, 50 * (1 - value)),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: _buildModernCard(b),
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildModernCard(CreateBookingModel b) {
//     Widget styledLabel(String label, String value) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: "$label: ",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   fontSize: 15,
//                 ),
//               ),
//               TextSpan(
//                 text: value,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             styledLabel("Pickup", "${b.pickup}, ${b.pickupPostcode}"),
//             styledLabel(
//               "Destination",
//               "${b.destination}, ${b.destinationPostcode}",
//             ),
//             styledLabel("Passenger", b.name),
//             styledLabel("Mileage", b.mileageText),
//             styledLabel("Duration", b.durationText),
//             styledLabel("Price", "£${b.price}"),
//             if (b.date != null)
//               styledLabel(
//                 "Date",
//                 "${b.date!.day}/${b.date!.month}/${b.date!.year}",
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_log_provider.dart';
import '../models/create_booking_model.dart';

class BookingLogScreen extends StatelessWidget {
  const BookingLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<CreateBookingModel> logs = context
        .watch<BookingLogProvider>()
        .logs;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFFCD1A21), // 🔴 SAME AS OTHER SCREENS
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Booking Logs",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: logs.isEmpty
          ? Center(
              child: Text(
                "No booking logs available",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final b = logs[index];

                /// Fade + slide animation
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildModernCard(context, b),
                );
              },
            ),
    );
  }

  Widget _buildModernCard(BuildContext context, CreateBookingModel b) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget styledLabel(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$label: ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDark
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.6),
                  theme.colorScheme.primary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            styledLabel("Pickup", "${b.pickup}, ${b.pickupPostcode}"),
            styledLabel(
              "Destination",
              "${b.destination}, ${b.destinationPostcode}",
            ),
            styledLabel("Passenger", b.name),
            styledLabel("Mileage", b.mileageText),
            styledLabel("Duration", b.durationText),
            styledLabel("Price", "£${b.price}"),
            if (b.date != null)
              styledLabel(
                "Date",
                "${b.date!.day}/${b.date!.month}/${b.date!.year}",
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:ace_taxis/providers/earning_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../models/earning_model.dart';
// import 'home_screen.dart';

// class EarningReportScreen extends StatefulWidget {
//   const EarningReportScreen({super.key});

//   @override
//   State<EarningReportScreen> createState() => _EarningReportScreenState();
// }

// class _EarningReportScreenState extends State<EarningReportScreen> {
//   int _pageIndex = 0;
//   DateTimeRange? _selectedRange;
//   final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

//   /// Pick date range
//   void _pickDateRange() async {
//     DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       initialDateRange: _selectedRange,
//     );

//     if (picked != null) {
//       setState(() => _selectedRange = picked);

//       // Fetch data from API for selected range
//       final provider = Provider.of<EarningProvider>(context, listen: false);
//       provider.fetchEarnings(from: picked.start, to: picked.end);
//     }
//   }

//   /// Show detailed breakdown
//   void _showBreakdownDialog(EarningModel earning) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Earning Breakdown"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Date: ${_dateFormat.format(earning.date)}"),
//             const SizedBox(height: 12),
//             const Text(
//               "Totals:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 6),
//             Text("Cash Total: £${earning.cashTotal.toStringAsFixed(2)}"),
//             Text("Account Total: £${earning.accTotal.toStringAsFixed(2)}"),
//             Text("Rank Total: £${earning.rankTotal.toStringAsFixed(2)}"),
//             Text("Commission: £${earning.commsTotal.toStringAsFixed(2)}"),
//             Text("Gross Total: £${earning.grossTotal.toStringAsFixed(2)}"),
//             Text("Net Total: £${earning.netTotal.toStringAsFixed(2)}"),
//             const SizedBox(height: 12),
//             const Text(
//               "Job Counts:",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 6),
//             Text("Cash Jobs: ${earning.cashJobsCount}"),
//             Text("Account Jobs: ${earning.accJobsCount}"),
//             Text("Rank Jobs: ${earning.rankJobsCount}"),
//             if (earning.rankMilesCount != null)
//               Text("Rank Miles: ${earning.rankMilesCount!.toStringAsFixed(1)}"),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFCD1A21),
//             ),
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<EarningProvider>(context);
//     final earnings = provider.earnings;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Earning Report",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: GestureDetector(
//                   onTap: _pickDateRange,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _selectedRange == null
//                               ? "Select Date Range"
//                               : "${_dateFormat.format(_selectedRange!.start)} - ${_dateFormat.format(_selectedRange!.end)}",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const Icon(Icons.calendar_today, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               /// Earnings List
//               Expanded(
//                 child: provider.loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : earnings.isEmpty
//                     ? const Center(child: Text("No earnings in selected range"))
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         itemCount: earnings.length,
//                         itemBuilder: (context, index) {
//                           final item = earnings[index];
//                           return Card(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             margin: const EdgeInsets.symmetric(vertical: 6),
//                             elevation: 3,
//                             child: ListTile(
//                               leading: CircleAvatar(
//                                 backgroundColor: Colors.grey.shade200,
//                                 child: Text(
//                                   "${index + 1}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFFCD1A21),
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 "Date: ${_dateFormat.format(item.date)}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 "Gross Total: £${item.grossTotal.toStringAsFixed(2)}",
//                               ),
//                               trailing: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFCD1A21),
//                                   minimumSize: const Size(60, 35),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 onPressed: () => _showBreakdownDialog(item),
//                                 child: const Text(
//                                   "View",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//               const SizedBox(height: 60),
//             ],
//           ),

//           /// Total earnings summary
//           Align(
//             alignment: const Alignment(0, 0.95),
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.6,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade400,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 "Total Earnings: £${provider.totalAmount.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Colors.white,
//         color: const Color(0xFFCD1A21),
//         buttonBackgroundColor: const Color(0xFFCD1A21),
//         height: 60,
//         index: _pageIndex,
//         animationDuration: const Duration(milliseconds: 400),
//         items: const [
//           Icon(Icons.home, size: 28, color: Colors.white),
//           Icon(Icons.directions_car, size: 28, color: Colors.white),
//           Icon(Icons.access_time, size: 28, color: Colors.white),
//           Icon(Icons.person, size: 28, color: Colors.white),
//         ],
//         onTap: (i) {
//           setState(() => _pageIndex = i);
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: i)),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:ace_taxis/providers/earning_providers.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/earning_model.dart';
import 'home_screen.dart';

class EarningReportScreen extends StatefulWidget {
  const EarningReportScreen({super.key});

  @override
  State<EarningReportScreen> createState() => _EarningReportScreenState();
}

class _EarningReportScreenState extends State<EarningReportScreen> {
  int _pageIndex = 0;
  DateTimeRange? _selectedRange;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      Provider.of<EarningProvider>(
        context,
        listen: false,
      ).fetchEarnings(from: picked.start, to: picked.end);
    }
  }

  void _showBreakdownDialog(EarningModel earning) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Earning Breakdown",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: SingleChildScrollView(
          child: DefaultTextStyle(
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${_dateFormat.format(earning.date)}"),
                const SizedBox(height: 12),
                const Text(
                  "Totals:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Cash: £${earning.cashTotal.toStringAsFixed(2)}"),
                Text("Account: £${earning.accTotal.toStringAsFixed(2)}"),
                Text("Rank: £${earning.rankTotal.toStringAsFixed(2)}"),
                Text("Commission: £${earning.commsTotal.toStringAsFixed(2)}"),
                Text("Gross: £${earning.grossTotal.toStringAsFixed(2)}"),
                Text("Net: £${earning.netTotal.toStringAsFixed(2)}"),
                const SizedBox(height: 12),
                const Text(
                  "Job Counts:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Cash Jobs: ${earning.cashJobsCount}"),
                Text("Account Jobs: ${earning.accJobsCount}"),
                Text("Rank Jobs: ${earning.rankJobsCount}"),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCD1A21),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EarningProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        title: const Text(
          "Earning Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedRange == null
                              ? "Select Date Range"
                              : "${_dateFormat.format(_selectedRange!.start)} - ${_dateFormat.format(_selectedRange!.end)}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.earnings.isEmpty
                    ? Center(
                        child: Text(
                          "No earnings in selected range",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.earnings.length,
                        itemBuilder: (context, index) {
                          final item = provider.earnings[index];
                          return Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Color(0xFFCD1A21),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Date: ${_dateFormat.format(item.date)}",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Gross Total: £${item.grossTotal.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCD1A21),
                                ),
                                onPressed: () => _showBreakdownDialog(item),
                                child: const Text(
                                  "View",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 80),
            ],
          ),

          Align(
            alignment: const Alignment(0, 0.95),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Total Earnings: £${provider.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: const Color(0xFFCD1A21),
        buttonBackgroundColor: const Color(0xFFCD1A21),
        height: 60,
        index: _pageIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.directions_car, color: Colors.white),
          Icon(Icons.access_time, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (i) {
          setState(() => _pageIndex = i);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: i)),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import '../providers/dash_total_provider.dart';
// import 'earning_report_screen.dart';
// import 'your_statement_screen.dart';
// import 'dashboard_screen.dart';
// import 'booking_screen.dart';
// import 'availability_screen.dart';
// import 'profile_screen.dart';

// class ReportScreen extends StatefulWidget {
//   const ReportScreen({super.key});

//   @override
//   State<ReportScreen> createState() => _ReportScreenState();
// }

// class _ReportScreenState extends State<ReportScreen>
//     with SingleTickerProviderStateMixin {
//   int _pageIndex = 0;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DashTotalProvider>(context);

//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       // ------------------------------------------------
//       // APP BAR FULLY VISIBLE
//       // ------------------------------------------------
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         title: const Text(
//           "Reports",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),

//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   _buildBarGraph(provider),
//                   const SizedBox(height: 60),
//                   _buildReportButtons(),
//                 ],
//               ),
//             ),

//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Colors.transparent,
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
//         onTap: (index) {
//           setState(() => _pageIndex = index);

//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const DashboardScreen()),
//             );
//           } else if (index == 1) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const BookingScreen()),
//             );
//           } else if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const AvailabilityScreen()),
//             );
//           } else if (index == 3) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const ProfileScreen()),
//             );
//           }
//         },
//       ),
//     );
//   }

//   // --------------------------------------------------
//   // REPORT BUTTONS
//   // --------------------------------------------------
//   Widget _buildReportButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const EarningReportScreen()),
//             ),
//             child: Container(
//               height: 90,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFCD1A21),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Text(
//                     "£",
//                     style: TextStyle(
//                       fontSize: 36,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Earning Report",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: _buildCardButton(
//             title: "Your Statement",
//             icon: Icons.receipt_long,
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const YourStatementScreen()),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCardButton({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 90,
//         decoration: BoxDecoration(
//           color: const Color(0xFFCD1A21),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 36, color: Colors.white),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --------------------------------------------------
//   // BAR GRAPH
//   // --------------------------------------------------
//   Widget _buildBarGraph(DashTotalProvider provider) {
//     final dash = provider.dashTotal;
//     if (dash == null) return const SizedBox();

//     final earnings = [
//       dash.earningsTotalToday ?? 0,
//       dash.earningsTotalWeek ?? 0,
//       dash.earningsTotalMonth ?? 0,
//     ];

//     final labels = ["Today", "This week", "This month"];
//     final displayValues = earnings
//         .map((e) => "£${e.toStringAsFixed(0)}")
//         .toList();

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 8.0),
//             child: Text(
//               "Earnings",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
//             ),
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 250,
//             child: _BarChart(
//               values: earnings,
//               labels: labels,
//               displayValues: displayValues,
//               animationValue: 1.0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BarChart extends StatelessWidget {
//   final List<double> values;
//   final List<String> labels;
//   final List<String> displayValues;
//   final double animationValue;

//   const _BarChart({
//     required this.values,
//     required this.labels,
//     required this.displayValues,
//     required this.animationValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final maxValue = values.reduce((a, b) => a > b ? a : b);
//     final colors = [
//       Colors.blue,
//       const Color.fromARGB(255, 222, 94, 85),
//       const Color.fromARGB(255, 220, 35, 22),
//     ];
//     const chartHeight = 160.0;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: List.generate(values.length, (index) {
//         final fullHeight = maxValue == 0
//             ? 0
//             : (values[index] / maxValue) * chartHeight;
//         final animatedHeight = fullHeight * animationValue;

//         return Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               displayValues[index],
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               height: animatedHeight,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: colors[index % colors.length],
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               labels[index],
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../providers/dash_total_provider.dart';
import 'earning_report_screen.dart';
import 'your_statement_screen.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'availability_screen.dart';
import 'profile_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  int _pageIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashTotalProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          "Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ---------------- BODY ----------------
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBarGraph(provider, theme),
                  const SizedBox(height: 60),
                  _buildReportButtons(theme),
                ],
              ),
            ),

      // ---------------- BOTTOM BAR ----------------
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xFFCD1A21),
        buttonBackgroundColor: const Color(0xFFCD1A21),
        height: 60,
        index: _pageIndex,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(Icons.home, size: 28, color: Colors.white),
          Icon(Icons.directions_car, size: 28, color: Colors.white),
          Icon(Icons.access_time, size: 28, color: Colors.white),
          Icon(Icons.person, size: 28, color: Colors.white),
        ],
        onTap: (index) {
          setState(() => _pageIndex = index);

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AvailabilityScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  // ---------------- REPORT BUTTONS ----------------
  Widget _buildReportButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EarningReportScreen()),
            ),
            child: _cardButton(
              theme,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "£",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Earning Report",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YourStatementScreen()),
            ),
            child: _cardButton(
              theme,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 36, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    "Your Statement",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardButton(ThemeData theme, {required Widget child}) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFCD1A21),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  // ---------------- BAR GRAPH ----------------
  Widget _buildBarGraph(DashTotalProvider provider, ThemeData theme) {
    final dash = provider.dashTotal;
    if (dash == null) return const SizedBox();

    final earnings = [
      dash.earningsTotalToday ?? 0,
      dash.earningsTotalWeek ?? 0,
      dash.earningsTotalMonth ?? 0,
    ];

    final labels = ["Today", "This week", "This month"];
    final displayValues = earnings
        .map((e) => "£${e.toStringAsFixed(0)}")
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Earnings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: _BarChart(
              values: earnings,
              labels: labels,
              displayValues: displayValues,
              textColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final List<String> displayValues;
  final Color textColor;

  const _BarChart({
    required this.values,
    required this.labels,
    required this.displayValues,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final colors = [
      Colors.blue,
      const Color(0xFFDE5E55),
      const Color(0xFFDC2316),
    ];
    const chartHeight = 160.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final double fullHeight = maxValue == 0
            ? 0.0
            : (values[index] / maxValue) * chartHeight;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              displayValues[index],
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Container(
              height: fullHeight,
              width: 50,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              labels[index],
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        );
      }),
    );
  }
}

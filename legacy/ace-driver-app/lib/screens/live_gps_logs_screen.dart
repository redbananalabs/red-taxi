// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:ace_taxis/helpers/shared_pref_helper.dart';

// class LiveGpsLogsScreen extends StatefulWidget {
//   const LiveGpsLogsScreen({super.key});

//   @override
//   State<LiveGpsLogsScreen> createState() => _LiveGpsLogsScreenState();
// }

// class _LiveGpsLogsScreenState extends State<LiveGpsLogsScreen> {
//   List<Map<String, dynamic>> _logs = [];
//   final ScrollController _scrollController = ScrollController();
//   Timer? _refreshTimer;

//   @override
//   void initState() {
//     super.initState();
//     _loadLogs();

//     /// Auto refresh every 2 seconds
//     _refreshTimer = Timer.periodic(
//       const Duration(seconds: 2),
//       (_) => _loadLogs(),
//     );
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadLogs() async {
//     final logs = await SharedPrefHelper.getGpsLogs();
//     if (!mounted) return;
//     setState(() => _logs = logs);
//   }

//   String getApiStatus(Map<String, dynamic> log) {
//     return log["status"]?.toString() ?? "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Live GPS Logs",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFCD1A21),
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () async {
//               await SharedPrefHelper.clearGpsLogs();
//               _loadLogs();
//             },
//           ),
//         ],
//       ),
//       body: _logs.isEmpty
//           ? const Center(
//               child: Text(
//                 "No GPS logs saved yet",
//                 style: TextStyle(fontSize: 16),
//               ),
//             )
//           : ListView.builder(
//               controller: _scrollController,
//               itemCount: _logs.length,
//               itemBuilder: (context, index) {
//                 final log = _logs[index];
//                 final status = getApiStatus(log);
//                 final isSuccess = status == "200";

//                 return Dismissible(
//                   key: ValueKey(log["time"] ?? index.toString()),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     color: Colors.red,
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),
//                   onDismissed: (direction) async {
//                     await SharedPrefHelper.deleteGpsLogAt(index);
//                     _loadLogs();
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(
//                       vertical: 3, // slightly smaller
//                       horizontal: 0,
//                     ),
//                     child: Card(
//                       color: isSuccess
//                           ? Colors.lightBlue.shade100
//                           : Colors.red.shade100,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           5,
//                         ), // smaller corners
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8), // slightly smaller
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               log["time"] ?? "",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 3),
//                             Text(
//                               "API Status: $status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: isSuccess ? Colors.blue : Colors.red,
//                               ),
//                             ),
//                             const SizedBox(height: 3),
//                             Text("Latitude:  ${log["latitude"]}"),
//                             Text("Longtitude: ${log["longtitude"]}"),
//                             Text("Speed:     ${log["speed"]}"),
//                             Text("Heading:   ${log["heading"]}"),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';

class LiveGpsLogsScreen extends StatefulWidget {
  const LiveGpsLogsScreen({super.key});

  @override
  State<LiveGpsLogsScreen> createState() => _LiveGpsLogsScreenState();
}

class _LiveGpsLogsScreenState extends State<LiveGpsLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLogs();

    /// Auto refresh every 2 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _loadLogs(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final logs = await SharedPrefHelper.getGpsLogs();
    if (!mounted) return;
    setState(() => _logs = logs);
  }

  String getApiStatus(Map<String, dynamic> log) {
    return log["status"]?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFFCD1A21), // 🔴 RED LIKE DOCUMENT SCREEN
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Live GPS Logs",
          style: TextStyle(
            fontSize: 18, // ⬆ INCREASED SIZE
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              await SharedPrefHelper.clearGpsLogs();
              _loadLogs();
            },
          ),
        ],
      ),
      body: _logs.isEmpty
          ? Center(
              child: Text(
                "No GPS logs saved yet",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final status = getApiStatus(log);
                final isSuccess = status == "200";

                return Dismissible(
                  key: ValueKey(log["time"] ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: theme.colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: theme.colorScheme.onError),
                  ),
                  onDismissed: (direction) async {
                    await SharedPrefHelper.deleteGpsLogAt(index);
                    _loadLogs();
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Card(
                      color: isSuccess
                          ? (isDark
                                ? theme.colorScheme.primary.withOpacity(0.25)
                                : theme.colorScheme.primaryContainer
                                      .withOpacity(0.5))
                          : (isDark
                                ? theme.colorScheme.error.withOpacity(0.25)
                                : theme.colorScheme.errorContainer.withOpacity(
                                    0.5,
                                  )),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log["time"] ?? "",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "API Status: $status",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSuccess
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Latitude:  ${log["latitude"]}",
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              "Longitude: ${log["longtitude"]}",
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              "Speed:     ${log["speed"]}",
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              "Heading:   ${log["heading"]}",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

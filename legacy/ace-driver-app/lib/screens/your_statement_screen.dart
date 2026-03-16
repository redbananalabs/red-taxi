// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../providers/statement_provider.dart';
// import '../models/statement_model.dart';

// class YourStatementScreen extends StatefulWidget {
//   const YourStatementScreen({super.key});

//   @override
//   State<YourStatementScreen> createState() => _YourStatementScreenState();
// }

// class _YourStatementScreenState extends State<YourStatementScreen>
//     with SingleTickerProviderStateMixin {
//   final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
//   DateTimeRange? _selectedRange;

//   bool _sortDescending = true;
//   late AnimationController _arrowController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<StatementProvider>(context, listen: false).fetchStatements();
//     });

//     _arrowController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//       value: 1,
//     );
//   }

//   @override
//   void dispose() {
//     _arrowController.dispose();
//     super.dispose();
//   }

//   // ================= FILTER & SORT =================

//   void _pickDateRange() async {
//     DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       initialDateRange: _selectedRange,
//     );
//     if (picked != null) {
//       setState(() => _selectedRange = picked);
//     }
//   }

//   void _toggleSort() {
//     setState(() {
//       _sortDescending = !_sortDescending;
//       _sortDescending ? _arrowController.forward() : _arrowController.reverse();
//     });
//   }

//   List<StatementModel> _filterAndSort(List<StatementModel> list) {
//     List<StatementModel> filtered = list;

//     if (_selectedRange != null) {
//       filtered = filtered.where((s) {
//         return s.dateCreated.isAfter(
//               _selectedRange!.start.subtract(const Duration(days: 1)),
//             ) &&
//             s.dateCreated.isBefore(
//               _selectedRange!.end.add(const Duration(days: 1)),
//             );
//       }).toList();
//     }

//     filtered.sort(
//       (a, b) => _sortDescending
//           ? b.dateCreated.compareTo(a.dateCreated)
//           : a.dateCreated.compareTo(b.dateCreated),
//     );

//     return filtered;
//   }

//   // ================= MODERN STATEMENT DIALOG =================

//   void _showStatementDialog(StatementModel s, StatementProvider provider) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Statement Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 20),

//                 _row("Statement ID", s.statementId.toString()),
//                 _row("Created", _dateFormat.format(s.dateCreated)),
//                 _row(
//                   "Period",
//                   "${_dateFormat.format(s.startDate)} - ${_dateFormat.format(s.endDate)}",
//                 ),

//                 const SizedBox(height: 10),
//                 _section("Earnings"),
//                 _row("Cash", "£${s.earningsCash.toStringAsFixed(2)}"),
//                 _row("Account", "£${s.earningsAccount.toStringAsFixed(2)}"),
//                 _row("Card", "£${s.earningsCard.toStringAsFixed(2)}"),

//                 const SizedBox(height: 10),
//                 _section("Summary"),
//                 _row("Subtotal", "£${s.subTotal.toStringAsFixed(2)}"),
//                 _row("Commission", "£${s.commissionDue.toStringAsFixed(2)}"),
//                 _row("Total Earned", "£${s.totalEarned.toStringAsFixed(2)}"),
//                 _row("Payment Due", "£${s.paymentDue.toStringAsFixed(2)}"),

//                 const SizedBox(height: 10),
//                 _section("Jobs"),
//                 _row("Total Jobs", s.totalJobCount.toString()),
//                 _row("Account Jobs", s.accountJobsTotalCount.toString()),
//                 _row("Cash Jobs", s.cashJobsTotalCount.toString()),
//                 _row("Rank Jobs", s.rankJobsTotalCount.toString()),

//                 const SizedBox(height: 10),
//                 _row("Paid In Full", s.paidInFull ? "Yes" : "No"),

//                 const SizedBox(height: 20),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor: const Color(0xFFCD1A21),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     icon: const Icon(Icons.download, color: Colors.white),
//                     label: const Text(
//                       "DOWNLOAD",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     onPressed: () async {
//                       Navigator.pop(context);
//                       await provider.downloadStatementFile(s.statementId);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= UI HELPERS =================

//   Widget _section(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFCD1A21),
//         ),
//       ),
//     );
//   }

//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(color: Colors.grey.shade700)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   // ================= MAIN UI =================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Statement Report",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFCD1A21),
//       ),
//       body: Consumer<StatementProvider>(
//         builder: (context, provider, _) {
//           if (provider.loading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final statements = _filterAndSort(provider.statements);

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: _pickDateRange,
//                         child: Container(
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: Text(
//                             _selectedRange == null
//                                 ? "Select Date Range"
//                                 : "${_dateFormat.format(_selectedRange!.start)} - ${_dateFormat.format(_selectedRange!.end)}",
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     GestureDetector(
//                       onTap: _toggleSort,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(color: const Color(0xFFCD1A21)),
//                         ),
//                         child: Row(
//                           children: [
//                             RotationTransition(
//                               turns: _arrowController,
//                               child: const Icon(
//                                 Icons.arrow_upward,
//                                 color: Color(0xFFCD1A21),
//                                 size: 16,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               _sortDescending ? "Newest" : "Oldest",
//                               style: const TextStyle(
//                                 color: Color(0xFFCD1A21),
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: statements.length,
//                   itemBuilder: (context, index) {
//                     final s = statements[index];
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Statement ID: ${s.statementId}",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(_dateFormat.format(s.dateCreated)),
//                             const SizedBox(height: 6),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "£${s.totalEarned.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextButton(
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: const Color(0xFFCD1A21),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 6,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     minimumSize: Size.zero,
//                                     tapTargetSize:
//                                         MaterialTapTargetSize.shrinkWrap,
//                                   ),
//                                   onPressed: () =>
//                                       _showStatementDialog(s, provider),
//                                   child: const Text(
//                                     "VIEW",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/statement_provider.dart';
import '../models/statement_model.dart';

class YourStatementScreen extends StatefulWidget {
  const YourStatementScreen({super.key});

  @override
  State<YourStatementScreen> createState() => _YourStatementScreenState();
}

class _YourStatementScreenState extends State<YourStatementScreen>
    with SingleTickerProviderStateMixin {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  DateTimeRange? _selectedRange;

  bool _sortDescending = true;
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();

    // Fetch statements immediately
    final provider = Provider.of<StatementProvider>(context, listen: false);
    provider.fetchStatements();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  // ================= FILTER & SORT =================

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        // Theme for date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFCD1A21),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCD1A21),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  void _toggleSort() {
    setState(() {
      _sortDescending = !_sortDescending;
      _sortDescending ? _arrowController.forward() : _arrowController.reverse();
    });
  }

  List<StatementModel> _filterAndSort(List<StatementModel> list) {
    List<StatementModel> filtered = list;

    if (_selectedRange != null) {
      filtered = filtered.where((s) {
        return s.dateCreated.isAfter(
              _selectedRange!.start.subtract(const Duration(days: 1)),
            ) &&
            s.dateCreated.isBefore(
              _selectedRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    filtered.sort(
      (a, b) => _sortDescending
          ? b.dateCreated.compareTo(a.dateCreated)
          : a.dateCreated.compareTo(b.dateCreated),
    );

    return filtered;
  }

  // ================= MODERN THEMED STATEMENT DIALOG =================

  void _showStatementDialog(StatementModel s, StatementProvider provider) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Statement Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCD1A21),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.grey),

                _row("Statement ID", s.statementId.toString()),
                _row("Created", _dateFormat.format(s.dateCreated)),
                _row(
                  "Period",
                  "${_dateFormat.format(s.startDate)} - ${_dateFormat.format(s.endDate)}",
                ),

                const SizedBox(height: 10),
                _section("Earnings"),
                _row("Cash", "£${s.earningsCash.toStringAsFixed(2)}"),
                _row("Account", "£${s.earningsAccount.toStringAsFixed(2)}"),
                _row("Card", "£${s.earningsCard.toStringAsFixed(2)}"),
                _row("Rank", "£${s.earningsRank.toStringAsFixed(2)}"),

                const SizedBox(height: 10),
                _section("Summary"),
                _row("Subtotal", "£${s.subTotal.toStringAsFixed(2)}"),
                _row("Commission", "£${s.commissionDue.toStringAsFixed(2)}"),
                _row("Total Earned", "£${s.totalEarned.toStringAsFixed(2)}"),
                _row("Payment Due", "£${s.paymentDue.toStringAsFixed(2)}"),

                const SizedBox(height: 10),
                _section("Jobs"),
                _row("Total Jobs", s.totalJobCount.toString()),
                _row("Account Jobs", s.accountJobsTotalCount.toString()),
                _row("Cash Jobs", s.cashJobsTotalCount.toString()),
                _row("Rank Jobs", s.rankJobsTotalCount.toString()),

                const SizedBox(height: 10),
                _row("Paid In Full", s.paidInFull ? "Yes" : "No"),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: const Color(0xFFCD1A21),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      "DOWNLOAD",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await provider.downloadStatementFile(s.statementId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFCD1A21),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Statement Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFCD1A21),
      ),
      body: Consumer<StatementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final statements = _filterAndSort(provider.statements);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDateRange,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _selectedRange == null
                                ? "Select Date Range"
                                : "${_dateFormat.format(_selectedRange!.start)} - ${_dateFormat.format(_selectedRange!.end)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleSort,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFCD1A21)),
                        ),
                        child: Row(
                          children: [
                            RotationTransition(
                              turns: _arrowController,
                              child: const Icon(
                                Icons.arrow_upward,
                                color: Color(0xFFCD1A21),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sortDescending ? "Newest" : "Oldest",
                              style: const TextStyle(
                                color: Color(0xFFCD1A21),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: statements.length,
                  itemBuilder: (context, index) {
                    final s = statements[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statement ID: ${s.statementId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_dateFormat.format(s.dateCreated)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "£${s.totalEarned.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFCD1A21),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () =>
                                      _showStatementDialog(s, provider),
                                  child: const Text(
                                    "VIEW",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

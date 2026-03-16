// import 'package:ace_taxis/providers/view_expense_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../helpers/shared_pref_helper.dart';

// class ViewExpensesScreen extends StatefulWidget {
//   const ViewExpensesScreen({super.key});

//   @override
//   State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
// }

// class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
//   int _pageIndex = 3;
//   DateTimeRange? _selectedDateRange;
//   String _selectedCategory = "All";

//   final List<String> _categories = [
//     "All",
//     "Fuel",
//     "Parking/ULEZ",
//     "Insurance",
//     "MOT",
//     "DBS",
//     "Vehicle Badge",
//     "Maintenance",
//     "Certification",
//     "Other",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeDefaultDateRange();
//   }

//   Future<void> _initializeDefaultDateRange() async {
//     final userData = await SharedPrefHelper.getUser();
//     if (userData == null) return;

//     final userId = userData['userId'];

//     final now = DateTime.now();
//     final from = now.subtract(const Duration(days: 30));
//     final to = now;

//     setState(() {
//       _selectedDateRange = DateTimeRange(start: from, end: to);
//     });

//     await Provider.of<ViewExpenseProvider>(
//       context,
//       listen: false,
//     ).fetchExpenses(userId: userId, from: from, to: to);
//   }

//   Future<void> _pickDateRange() async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       initialDateRange: _selectedDateRange,
//     );

//     if (picked != null) {
//       setState(() => _selectedDateRange = picked);

//       final userData = await SharedPrefHelper.getUser();
//       if (userData == null) return;

//       final userId = userData['userId'];

//       await Provider.of<ViewExpenseProvider>(
//         context,
//         listen: false,
//       ).fetchExpenses(userId: userId, from: picked.start, to: picked.end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ViewExpenseProvider>(context);

//     final filtered = provider.expenses.where((expense) {
//       final inCategory =
//           _selectedCategory == "All" || expense.category == _selectedCategory;

//       final inDate =
//           _selectedDateRange == null ||
//           (expense.date.isAfter(
//                 _selectedDateRange!.start.subtract(const Duration(days: 1)),
//               ) &&
//               expense.date.isBefore(
//                 _selectedDateRange!.end.add(const Duration(days: 1)),
//               ));

//       return inCategory && inDate;
//     }).toList();

//     final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Expenses",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),

//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//           ? Center(child: Text("Error: ${provider.error}"))
//           : Column(
//               children: [
//                 // 🔹 Date Range Button
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _pickDateRange,
//                     icon: const Icon(Icons.date_range, color: Colors.white),
//                     label: Text(
//                       "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - "
//                       "${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 // 🔹 Category Filter Chips
//                 SizedBox(
//                   height: 45,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _categories.length,
//                     itemBuilder: (context, index) {
//                       final category = _categories[index];
//                       final isSelected = _selectedCategory == category;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: ChoiceChip(
//                           label: Text(category),
//                           labelStyle: const TextStyle(color: Colors.white),
//                           selected: isSelected,
//                           selectedColor: Colors.green,
//                           backgroundColor: Colors.red,
//                           onSelected: (_) =>
//                               setState(() => _selectedCategory = category),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // 🔹 Expense List
//                 Expanded(
//                   child: filtered.isEmpty
//                       ? const Center(
//                           child: Text(
//                             "No expenses found",
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                         )
//                       : ListView.separated(
//                           padding: const EdgeInsets.all(12),
//                           itemCount: filtered.length,
//                           separatorBuilder: (_, __) => const Divider(height: 1),
//                           itemBuilder: (context, index) {
//                             final expense = filtered[index];
//                             return ListTile(
//                               leading: const Icon(
//                                 Icons.receipt_long,
//                                 color: Colors.green,
//                               ),
//                               title: Text(expense.category),
//                               subtitle: Text("£${expense.amount}"),
//                               trailing: Text(
//                                 "${expense.date.day}/${expense.date.month}/${expense.date.year}",
//                               ),
//                             );
//                           },
//                         ),
//                 ),

//                 // 🔹 Total Summary
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 20,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       "Total: £$total",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

// import 'package:ace_taxis/providers/view_expense_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../helpers/shared_pref_helper.dart';

// class ViewExpensesScreen extends StatefulWidget {
//   const ViewExpensesScreen({super.key});

//   @override
//   State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
// }

// class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
//   int _pageIndex = 3;
//   DateTimeRange? _selectedDateRange;
//   String _selectedCategory = "All";

//   final List<String> _categories = [
//     "All",
//     "Fuel",
//     "Parking/ULEZ",
//     "Insurance",
//     "MOT",
//     "DBS",
//     "Vehicle Badge",
//     "Maintenance",
//     "Certification",
//     "Other",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeDefaultDateRange();
//   }

//   Future<void> _initializeDefaultDateRange() async {
//     final userData = await SharedPrefHelper.getUser();
//     if (userData == null) return;

//     final userId = userData['userId'];

//     final now = DateTime.now();
//     final from = now.subtract(const Duration(days: 30));
//     final to = now;

//     setState(() {
//       _selectedDateRange = DateTimeRange(start: from, end: to);
//     });

//     await Provider.of<ViewExpenseProvider>(
//       context,
//       listen: false,
//     ).fetchExpenses(userId: userId, from: from, to: to);
//   }

//   Future<void> _pickDateRange() async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       initialDateRange: _selectedDateRange,
//       builder: (context, child) {
//         return Theme(data: Theme.of(context), child: child!);
//       },
//     );

//     if (picked != null) {
//       setState(() => _selectedDateRange = picked);

//       final userData = await SharedPrefHelper.getUser();
//       if (userData == null) return;

//       final userId = userData['userId'];

//       await Provider.of<ViewExpenseProvider>(
//         context,
//         listen: false,
//       ).fetchExpenses(userId: userId, from: picked.start, to: picked.end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ViewExpenseProvider>(context);
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     final filtered = provider.expenses.where((expense) {
//       final inCategory =
//           _selectedCategory == "All" || expense.category == _selectedCategory;

//       final inDate =
//           _selectedDateRange == null ||
//           (expense.date.isAfter(
//                 _selectedDateRange!.start.subtract(const Duration(days: 1)),
//               ) &&
//               expense.date.isBefore(
//                 _selectedDateRange!.end.add(const Duration(days: 1)),
//               ));

//       return inCategory && inDate;
//     }).toList();

//     final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,

//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Expenses",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),

//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//           ? Center(child: Text("Error: ${provider.error}"))
//           : Column(
//               children: [
//                 // 🔹 Date Range Button
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _pickDateRange,
//                     icon: const Icon(Icons.date_range, color: Colors.white),
//                     label: Text(
//                       "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - "
//                       "${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 // 🔹 Category Filter Chips
//                 SizedBox(
//                   height: 45,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _categories.length,
//                     itemBuilder: (context, index) {
//                       final category = _categories[index];
//                       final isSelected = _selectedCategory == category;

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: ChoiceChip(
//                           label: Text(category),
//                           selected: isSelected,
//                           labelStyle: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : theme.colorScheme.onSurface,
//                           ),
//                           selectedColor: theme.colorScheme.primary,
//                           backgroundColor: theme.cardColor,
//                           onSelected: (_) =>
//                               setState(() => _selectedCategory = category),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // 🔹 Expense List
//                 Expanded(
//                   child: filtered.isEmpty
//                       ? Center(
//                           child: Text(
//                             "No expenses found",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: theme.colorScheme.onSurface.withOpacity(
//                                 0.6,
//                               ),
//                             ),
//                           ),
//                         )
//                       : ListView.separated(
//                           padding: const EdgeInsets.all(12),
//                           itemCount: filtered.length,
//                           separatorBuilder: (_, __) =>
//                               Divider(color: theme.dividerColor),
//                           itemBuilder: (context, index) {
//                             final expense = filtered[index];
//                             return Card(
//                               color: theme.cardColor,
//                               child: ListTile(
//                                 leading: Icon(
//                                   Icons.receipt_long,
//                                   color: theme.colorScheme.primary,
//                                 ),
//                                 title: Text(
//                                   expense.category,
//                                   style: TextStyle(
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   "£${expense.amount}",
//                                   style: TextStyle(
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                 ),
//                                 trailing: Text(
//                                   "${expense.date.day}/${expense.date.month}/${expense.date.year}",
//                                   style: TextStyle(
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),

//                 // 🔹 Total Summary
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 10,
//                       horizontal: 20,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       "Total: £$total",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:ace_taxis/providers/view_expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/shared_pref_helper.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  int _pageIndex = 3;
  DateTimeRange? _selectedDateRange;
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Fuel",
    "Parking/ULEZ",
    "Insurance",
    "MOT",
    "DBS",
    "Vehicle Badge",
    "Maintenance",
    "Certification",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _initializeDefaultDateRange();
  }

  Future<void> _initializeDefaultDateRange() async {
    final userData = await SharedPrefHelper.getUser();
    if (userData == null) return;

    final userId = userData['userId'];

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final to = now;

    setState(() {
      _selectedDateRange = DateTimeRange(start: from, end: to);
    });

    await Provider.of<ViewExpenseProvider>(
      context,
      listen: false,
    ).fetchExpenses(userId: userId, from: from, to: to);
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);

      final userData = await SharedPrefHelper.getUser();
      if (userData == null) return;

      final userId = userData['userId'];

      await Provider.of<ViewExpenseProvider>(
        context,
        listen: false,
      ).fetchExpenses(userId: userId, from: picked.start, to: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ViewExpenseProvider>(context);
    final theme = Theme.of(context);

    final filtered = provider.expenses.where((expense) {
      final inCategory =
          _selectedCategory == "All" || expense.category == _selectedCategory;

      final inDate =
          _selectedDateRange == null ||
          (expense.date.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              ));

      return inCategory && inDate;
    }).toList();

    // 🔹 SORT BY DATE (LATEST FIRST)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Expenses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text("Error: ${provider.error}"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    label: Text(
                      "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - "
                      "${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: theme.cardColor,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            "No expenses found",
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: theme.dividerColor),
                          itemBuilder: (context, index) {
                            final expense = filtered[index];
                            return Card(
                              color: theme.cardColor,
                              child: ListTile(
                                leading: Icon(
                                  Icons.receipt_long,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(
                                  expense.category,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  "£${expense.amount}",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                trailing: Text(
                                  "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Total: £$total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

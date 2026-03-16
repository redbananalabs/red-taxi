// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:provider/provider.dart';
// import '../providers/expense_provider.dart';
// import 'home_screen.dart';
// import 'view_expenses_screen.dart';

// class AddExpensePage extends StatefulWidget {
//   const AddExpensePage({super.key});

//   @override
//   State<AddExpensePage> createState() => _AddExpensePageState();
// }

// class _AddExpensePageState extends State<AddExpensePage> {
//   int _pageIndex = 1;

//   DateTime _selectedDate = DateTime.now();
//   String? _selectedCategory;
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();

//   final List<String> _categories = [
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
//     _selectedCategory = _categories.first;
//     _dateController.text =
//         "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
//   }

//   Future<void> _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       initialDate: _selectedDate,
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _dateController.text =
//             "${picked.day}/${picked.month}/${picked.year}";
//       });
//     }
//   }

//   Future<void> _saveExpense() async {
//     if (_amountController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter amount")),
//       );
//       return;
//     }

//     final provider = Provider.of<ExpenseProvider>(context, listen: false);
//     final success = await provider.addExpense(
//       date: _selectedDate,
//       category: _selectedCategory!,
//       description: _descController.text,
//       amount: double.tryParse(_amountController.text) ?? 0,
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Expense added successfully")),
//       );

//       // ✅ Stay on same screen, just clear fields
//       _amountController.clear();
//       _descController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Failed to add expense")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = context.watch<ExpenseProvider>().isLoading;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         title: const Text(
//           "Add Expense",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       backgroundColor: const Color(0xFFF8F6FA),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _dateController,
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: "Date",
//                 suffixIcon: const Icon(Icons.calendar_today),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onTap: _pickDate,
//             ),
//             const SizedBox(height: 16),

//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               decoration: InputDecoration(
//                 labelText: "Category",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: _categories
//                   .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                   .toList(),
//               onChanged: (val) => setState(() => _selectedCategory = val),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "Amount (£)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               controller: _descController,
//               decoration: InputDecoration(
//                 labelText: "Description (Optional)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 24),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFCD1A21),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: isLoading ? null : _saveExpense,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Add Expense",
//                       style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey.shade700,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => const ViewExpensesScreen()),
//                 );
//               },
//               child: const Text("View Expenses",
//                   style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ],
//         ),
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
//             MaterialPageRoute(
//               builder: (_) => HomeScreen(initialIndex: i),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'home_screen.dart';
import 'view_expenses_screen.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  int _pageIndex = 1;

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<String> _categories = [
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
    _selectedCategory = _categories.first;
    _dateController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: _selectedDate,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter amount")));
      return;
    }

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final success = await provider.addExpense(
      date: _selectedDate,
      category: _selectedCategory!,
      description: _descController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "✅ Expense added successfully" : "❌ Failed to add expense",
        ),
      ),
    );

    if (success) {
      _amountController.clear();
      _descController.clear();
    }
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label, {
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCD1A21), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ExpenseProvider>().isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        title: const Text("Add Expense", style: TextStyle(color: Colors.white)),
      ),

      // ✅ AUTO dark/light background
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: _inputDecoration(
                context,
                "Date",
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: theme.cardColor,
              decoration: _inputDecoration(context, "Category"),
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(context, "Amount (£)"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration(context, "Description (Optional)"),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCD1A21),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading ? null : _saveExpense,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Add Expense",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewExpensesScreen()),
                );
              },
              child: const Text(
                "View Expenses",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        color: const Color(0xFFCD1A21),
        buttonBackgroundColor: const Color(0xFFCD1A21),
        height: 60,
        index: _pageIndex,
        items: const [
          Icon(Icons.home, size: 28, color: Colors.white),
          Icon(Icons.directions_car, size: 28, color: Colors.white),
          Icon(Icons.access_time, size: 28, color: Colors.white),
          Icon(Icons.person, size: 28, color: Colors.white),
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

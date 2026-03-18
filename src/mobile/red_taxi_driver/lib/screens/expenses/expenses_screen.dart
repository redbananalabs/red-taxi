import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Expense history list screen.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = [
      _Expense(date: '18/03/2026', category: 'Fuel', desc: 'Shell - Deansgate',
          amount: 65.00),
      _Expense(date: '15/03/2026', category: 'Car Wash', desc: 'Express Wash',
          amount: 12.00),
      _Expense(date: '12/03/2026', category: 'Parking', desc: 'NCP Manchester',
          amount: 8.50),
      _Expense(date: '10/03/2026', category: 'Fuel', desc: 'BP - Oxford Road',
          amount: 70.00),
      _Expense(date: '05/03/2026', category: 'Maintenance',
          desc: 'Tyre replacement', amount: 120.00),
    ];

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/more/expenses/add'),
        backgroundColor: RedTaxiColors.brandRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(label: 'This Month', value: '\u00A3275.50'),
                Container(width: 1, height: 36,
                    color: RedTaxiColors.textSecondary.withOpacity(0.2)),
                _SummaryItem(label: 'Last Month', value: '\u00A3412.00'),
                Container(width: 1, height: 36,
                    color: RedTaxiColors.textSecondary.withOpacity(0.2)),
                _SummaryItem(label: 'YTD', value: '\u00A31,890'),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expenses.length,
              itemBuilder: (_, i) {
                final e = expenses[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: RedTaxiColors.brandRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_categoryIcon(e.category),
                            color: RedTaxiColors.brandRed, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.desc,
                                style: const TextStyle(
                                    color: RedTaxiColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(e.category,
                                    style: const TextStyle(
                                        color: RedTaxiColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(width: 8),
                                Text(e.date,
                                    style: const TextStyle(
                                        color: RedTaxiColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-\u00A3${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: RedTaxiColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Fuel':
        return Icons.local_gas_station_outlined;
      case 'Car Wash':
        return Icons.local_car_wash_outlined;
      case 'Parking':
        return Icons.local_parking_rounded;
      case 'Maintenance':
        return Icons.build_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}

class _Expense {
  final String date;
  final String category;
  final String desc;
  final double amount;
  const _Expense({
    required this.date,
    required this.category,
    required this.desc,
    required this.amount,
  });
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: RedTaxiColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Statement history list screen.
class StatementsScreen extends StatelessWidget {
  const StatementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statements = [
      _Statement(period: 'March 2026 (Week 11)', date: '17/03/2026',
          amount: 312.50, status: 'Pending'),
      _Statement(period: 'March 2026 (Week 10)', date: '10/03/2026',
          amount: 428.75, status: 'Paid'),
      _Statement(period: 'March 2026 (Week 9)', date: '03/03/2026',
          amount: 395.20, status: 'Paid'),
      _Statement(period: 'February 2026 (Week 8)', date: '24/02/2026',
          amount: 510.00, status: 'Paid'),
      _Statement(period: 'February 2026 (Week 7)', date: '17/02/2026',
          amount: 455.30, status: 'Paid'),
    ];

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Statements')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: statements.length,
        itemBuilder: (_, i) {
          final s = statements[i];
          final isPending = s.status == 'Pending';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isPending
                            ? RedTaxiColors.warning
                            : RedTaxiColors.success)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: isPending
                        ? RedTaxiColors.warning
                        : RedTaxiColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.period,
                        style: const TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.date,
                        style: const TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u00A3${s.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isPending
                                ? RedTaxiColors.warning
                                : RedTaxiColors.success)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.status,
                        style: TextStyle(
                          color: isPending
                              ? RedTaxiColors.warning
                              : RedTaxiColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Statement {
  final String period;
  final String date;
  final double amount;
  final String status;
  const _Statement({
    required this.period,
    required this.date,
    required this.amount,
    required this.status,
  });
}

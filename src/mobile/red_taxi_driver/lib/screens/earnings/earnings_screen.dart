import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Earnings breakdown by period (today, this week, this month).
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _selectedPeriod = 0; // 0=Today, 1=This Week, 2=This Month

  // Stub data
  static const _periods = ['Today', 'This Week', 'This Month'];
  static const _totals = ['\u00A342.50', '\u00A3287.00', '\u00A31,245.80'];
  static const _jobCounts = [4, 28, 112];

  final List<_EarningEntry> _entries = [
    _EarningEntry(
        time: '14:30', route: 'Northern Quarter -> Old Trafford', amount: 11.00),
    _EarningEntry(
        time: '10:15', route: 'Oxford Road -> Trafford Centre', amount: 14.00),
    _EarningEntry(
        time: '08:45', route: 'Deansgate -> Piccadilly Station', amount: 8.50),
    _EarningEntry(time: '07:00', route: 'Airport -> City Centre', amount: 9.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Earnings')),
      body: Column(
        children: [
          // Period selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: List.generate(3, (i) {
                final isActive = _selectedPeriod == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? RedTaxiColors.brandRed
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _periods[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : RedTaxiColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Summary card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  RedTaxiColors.brandRed.withOpacity(0.2),
                  RedTaxiColors.backgroundCard,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: RedTaxiColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _totals[_selectedPeriod],
                  style: const TextStyle(
                    color: RedTaxiColors.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SummaryChip(
                      icon: Icons.local_taxi_outlined,
                      value: '${_jobCounts[_selectedPeriod]}',
                      label: 'Jobs',
                    ),
                    const SizedBox(width: 24),
                    _SummaryChip(
                      icon: Icons.access_time_rounded,
                      value: '6.5h',
                      label: 'Hours',
                    ),
                    const SizedBox(width: 24),
                    _SummaryChip(
                      icon: Icons.trending_up_rounded,
                      value: '\u00A36.54',
                      label: 'Avg/job',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENT JOBS',
                style: TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Job list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              itemBuilder: (_, i) {
                final e = _entries[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        e.time,
                        style: const TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.route,
                          style: const TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\u00A3${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: RedTaxiColors.success,
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
}

class _EarningEntry {
  final String time;
  final String route;
  final double amount;
  const _EarningEntry(
      {required this.time, required this.route, required this.amount});
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: RedTaxiColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

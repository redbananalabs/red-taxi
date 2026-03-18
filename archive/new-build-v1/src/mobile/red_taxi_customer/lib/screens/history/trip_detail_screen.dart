import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Single past trip detail with receipt information.
class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F2B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.route,
                    size: 48,
                    color: RedTaxiColors.textSecondary.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 20),

            // Route details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.circle,
                    iconColor: RedTaxiColors.success,
                    label: 'Pickup',
                    address: '123 Main St, Dublin',
                    time: '08:30',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 2,
                          height: 6,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: RedTaxiColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.circle,
                    iconColor: RedTaxiColors.brandRed,
                    label: 'Drop-off',
                    address: 'Dublin Airport, Terminal 1',
                    time: '08:48',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trip stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Duration', value: '18 min'),
                  Container(
                    width: 1,
                    height: 36,
                    color: RedTaxiColors.textSecondary.withOpacity(0.2),
                  ),
                  _Stat(label: 'Distance', value: '12.4 km'),
                  Container(
                    width: 1,
                    height: 36,
                    color: RedTaxiColors.textSecondary.withOpacity(0.2),
                  ),
                  _Stat(label: 'Wait', value: '2 min'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Driver info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: RedTaxiColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person,
                        color: RedTaxiColors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Murphy',
                          style: TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Toyota Prius - 191-D-12345',
                          style: TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: RedTaxiColors.warning, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Receipt
            const Text(
              'Receipt',
              style: TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  _ReceiptLine(label: 'Base fare', value: '\$3.50'),
                  SizedBox(height: 8),
                  _ReceiptLine(label: 'Distance (12.4 km)', value: '\$24.80'),
                  SizedBox(height: 8),
                  _ReceiptLine(label: 'Wait time (2 min)', value: '\$1.20'),
                  SizedBox(height: 8),
                  _ReceiptLine(label: 'Booking fee', value: '\$3.00'),
                  SizedBox(height: 12),
                  Divider(color: Color(0xFF2A2D3A)),
                  SizedBox(height: 12),
                  _ReceiptLine(
                    label: 'Total',
                    value: '\$32.50',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Download receipt
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RedTaxiColors.textPrimary,
                  side: const BorderSide(color: Color(0xFF2A2D3A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String time;

  const _RoutePoint({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReceiptLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold
                ? RedTaxiColors.textPrimary
                : RedTaxiColors.textSecondary,
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? RedTaxiColors.brandRed : RedTaxiColors.textPrimary,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

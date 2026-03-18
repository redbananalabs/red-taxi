import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';

/// Trip completion screen with summary, rating, and tip option.
class TripCompleteScreen extends StatefulWidget {
  const TripCompleteScreen({super.key});

  @override
  State<TripCompleteScreen> createState() => _TripCompleteScreenState();
}

class _TripCompleteScreenState extends State<TripCompleteScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  double? _tipAmount;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>().activeBooking;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Checkmark
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: RedTaxiColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: RedTaxiColors.success, size: 44),
              ),
              const SizedBox(height: 16),
              Text(
                'Trip Complete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Trip summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Pickup',
                      value: booking?.pickupAddress ?? 'Current Location',
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Destination',
                      value: booking?.destinationAddress ?? 'Destination',
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF2A2D3A)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MiniStat(label: 'Duration', value: '18 min'),
                        _MiniStat(label: 'Distance', value: '7.2 km'),
                        _MiniStat(
                          label: 'Fare',
                          value: '\$${booking?.price.toStringAsFixed(2) ?? '14.50'}',
                          highlight: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rate driver
              Text(
                'Rate your driver',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: i < _rating
                            ? RedTaxiColors.warning
                            : RedTaxiColors.textSecondary,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Comment
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(
                    color: RedTaxiColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)',
                  hintStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tip
              Text(
                'Leave a tip',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [2.0, 5.0, 10.0].map((amount) {
                  final selected = _tipAmount == amount;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _tipAmount = selected ? null : amount;
                      }),
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? RedTaxiColors.brandRed.withOpacity(0.15)
                              : RedTaxiColors.backgroundCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? RedTaxiColors.brandRed
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '\$${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: selected
                                  ? RedTaxiColors.brandRed
                                  : RedTaxiColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<BookingProvider>()
                        .rateTrip(_rating, _commentController.text);
                    context.go('/home');
                  },
                  child: const Text(
                    'Done',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: RedTaxiColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MiniStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? RedTaxiColors.brandRed : RedTaxiColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

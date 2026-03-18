import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';

/// Booking submitted confirmation screen with estimated pickup time.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>().activeBooking;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: RedTaxiColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: RedTaxiColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ride has been booked successfully',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RedTaxiColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Booking details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.my_location,
                      iconColor: RedTaxiColors.success,
                      label: 'Pickup',
                      value: booking?.pickupAddress ?? 'Current Location',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: _DottedLine(),
                    ),
                    _DetailRow(
                      icon: Icons.location_on,
                      iconColor: RedTaxiColors.brandRed,
                      label: 'Destination',
                      value: booking?.destinationAddress ?? 'Not set',
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2D3A)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoChip(
                          icon: Icons.schedule,
                          label: 'ETA',
                          value: '5 min',
                        ),
                        _InfoChip(
                          icon: Icons.attach_money,
                          label: 'Fare',
                          value: '\$${booking?.price.toStringAsFixed(2) ?? '14.50'}',
                        ),
                        _InfoChip(
                          icon: Icons.confirmation_number_outlined,
                          label: 'ID',
                          value: '#${booking?.id.substring(0, 6) ?? '------'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Track ride button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/tracking'),
                  icon: const Icon(Icons.gps_fixed, size: 20),
                  label: const Text(
                    'Track Your Ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RedTaxiColors.textPrimary,
                    side: const BorderSide(color: Color(0xFF2A2D3A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            width: 2,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 1),
            color: RedTaxiColors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: RedTaxiColors.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

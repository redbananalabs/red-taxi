import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/status_button.dart';

/// Detailed view for a single booking — pickup, destination, passenger, price.
class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bp, _) {
        final booking = bp.scheduledBookings
            .cast<Booking?>()
            .firstWhere((b) => b?.id == bookingId, orElse: () => null);

        if (booking == null) {
          return Scaffold(
            backgroundColor: RedTaxiColors.backgroundBase,
            appBar: AppBar(title: const Text('Booking')),
            body: const Center(
              child: Text(
                'Booking not found',
                style: TextStyle(color: RedTaxiColors.textSecondary),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: RedTaxiColors.backgroundBase,
          appBar: AppBar(
            title: Text('Booking #${booking.id.substring(0, 8)}'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map placeholder
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 48,
                            color: RedTaxiColors.textSecondary),
                        SizedBox(height: 8),
                        Text('Route Map',
                            style: TextStyle(
                                color: RedTaxiColors.textSecondary,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price + status
                Row(
                  children: [
                    _StatusChip(status: booking.status),
                    const Spacer(),
                    Text(
                      '\u00A3${booking.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Route details card
                _DetailCard(
                  children: [
                    _RouteRow(
                      icon: Icons.circle,
                      iconColor: RedTaxiColors.success,
                      label: 'PICKUP',
                      value: booking.pickupAddress,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 11),
                      child: SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          color: RedTaxiColors.textSecondary,
                          thickness: 1.5,
                        ),
                      ),
                    ),
                    _RouteRow(
                      icon: Icons.circle,
                      iconColor: RedTaxiColors.brandRed,
                      label: 'DESTINATION',
                      value: booking.destinationAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time card
                _DetailCard(
                  children: [
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Pickup Time',
                      value: _formatDateTime(booking.pickupDateTime),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Created',
                      value: _formatDateTime(booking.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Passenger card
                _DetailCard(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Customer ID',
                      value: booking.customerId,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action buttons
                if (booking.status == BookingStatus.accepted) ...[
                  StatusButton(
                    label: 'Start Job',
                    subtitle: 'Begin driving to pickup',
                    icon: Icons.navigation_rounded,
                    color: RedTaxiColors.brandRed,
                    onPressed: () {
                      // Start this booking as the active job
                      context.go('/active');
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RedTaxiColors.error,
                        side: const BorderSide(color: RedTaxiColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}  $h:$m';
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RedTaxiColors.backgroundSurface,
        title: const Text('Cancel Booking?',
            style: TextStyle(color: RedTaxiColors.textPrimary)),
        content: const Text(
          'Are you sure you want to cancel this booking? '
          'This action cannot be undone.',
          style: TextStyle(color: RedTaxiColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep',
                style: TextStyle(color: RedTaxiColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Cancel Booking',
                style: TextStyle(color: RedTaxiColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case BookingStatus.pending:
        return RedTaxiColors.warning;
      case BookingStatus.accepted:
      case BookingStatus.driverEnRoute:
        return RedTaxiColors.brandRed;
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
        return const Color(0xFF3B82F6);
      case BookingStatus.completed:
        return RedTaxiColors.success;
      case BookingStatus.cancelled:
        return RedTaxiColors.error;
    }
  }

  String get _label {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.driverEnRoute:
        return 'En Route';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 10, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RedTaxiColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

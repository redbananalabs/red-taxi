import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/countdown_ring.dart';

/// CRITICAL: Full-screen takeover for incoming job offers.
///
/// Mimics an incoming call UI with countdown timer, booking details,
/// map preview, and Accept/Reject buttons. Triggers sound + vibration.
class JobOfferScreen extends StatefulWidget {
  const JobOfferScreen({super.key});

  @override
  State<JobOfferScreen> createState() => _JobOfferScreenState();
}

class _JobOfferScreenState extends State<JobOfferScreen> {
  static const int _offerTimeoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    // Vibration feedback on offer arrival
    HapticFeedback.heavyImpact();
  }

  void _onCountdownComplete() {
    // Auto-reject when timer expires
    if (mounted) {
      context.read<BookingProvider>().rejectOffer();
      Navigator.of(context).pop();
    }
  }

  void _accept() {
    HapticFeedback.mediumImpact();
    context.read<BookingProvider>().acceptOffer();
    Navigator.of(context).pop();
  }

  void _reject() {
    HapticFeedback.lightImpact();
    context.read<BookingProvider>().rejectOffer();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final offer = context.watch<BookingProvider>().incomingOffer;

    if (offer == null) {
      return const Scaffold(
        backgroundColor: RedTaxiColors.backgroundBase,
        body: Center(
          child: Text('No offer available',
              style: TextStyle(color: RedTaxiColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              const Text(
                'INCOMING JOB',
                style: TextStyle(
                  color: RedTaxiColors.brandRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 24),

              // Countdown ring
              CountdownRing(
                totalSeconds: _offerTimeoutSeconds,
                onComplete: _onCountdownComplete,
                size: 160,
                strokeWidth: 7,
              ),
              const SizedBox(height: 28),

              // Price
              Text(
                '\u00A3${offer.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // Route card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup
                      _LocationRow(
                        dotColor: RedTaxiColors.success,
                        label: 'PICKUP',
                        address: offer.pickupAddress,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          width: 2,
                          height: 16,
                          color:
                              RedTaxiColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      // Destination
                      _LocationRow(
                        dotColor: RedTaxiColors.brandRed,
                        label: 'DESTINATION',
                        address: offer.destinationAddress,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF2A2D3A)),
                      const SizedBox(height: 12),
                      // Pickup time
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 16, color: RedTaxiColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Pickup: ${_formatTime(offer.pickupDateTime)}',
                            style: const TextStyle(
                              color: RedTaxiColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Map placeholder
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: RedTaxiColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 20, color: RedTaxiColors.textSecondary),
                              SizedBox(width: 8),
                              Text('Route Preview',
                                  style: TextStyle(
                                      color: RedTaxiColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Accept / Reject buttons
              Row(
                children: [
                  // Reject
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _reject,
                        icon: const Icon(Icons.close_rounded, size: 26),
                        label: const Text('Reject',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RedTaxiColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Accept
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _accept,
                        icon: const Icon(Icons.check_rounded, size: 26),
                        label: const Text('Accept',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RedTaxiColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _LocationRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String address;

  const _LocationRow({
    required this.dotColor,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
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
                address,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/booking_tile.dart';
import 'job_offer_screen.dart';

/// Tab 2: List of pending job offers.
class OffersListScreen extends StatelessWidget {
  const OffersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Job Offers'),
        actions: [
          // Debug: simulate incoming offer
          IconButton(
            icon: const Icon(Icons.add_alert_rounded),
            tooltip: 'Simulate offer',
            onPressed: () {
              context.read<BookingProvider>().simulateIncomingOffer();
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const JobOfferScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          if (bp.pendingOffers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: RedTaxiColors.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending offers',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'New job offers will appear here',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: bp.refresh,
            color: RedTaxiColors.brandRed,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bp.pendingOffers.length,
              itemBuilder: (context, i) {
                final offer = bp.pendingOffers[i];
                return _OfferCard(
                  offer: offer,
                  onTap: () {
                    // Show full-screen offer takeover
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => const JobOfferScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Booking offer;
  final VoidCallback? onTap;

  const _OfferCard({required this.offer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: RedTaxiColors.backgroundCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RedTaxiColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        color: RedTaxiColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\u00A3${offer.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Pickup
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: RedTaxiColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      offer.pickupAddress,
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  width: 2,
                  height: 10,
                  color: RedTaxiColors.textSecondary.withOpacity(0.3),
                ),
              ),
              // Destination
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: RedTaxiColors.brandRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      offer.destinationAddress,
                      style: const TextStyle(
                        color: RedTaxiColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Time
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: RedTaxiColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Pickup at ${_formatTime(offer.pickupDateTime)}',
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: RedTaxiColors.textSecondary, size: 20),
                ],
              ),
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

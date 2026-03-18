import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/status_button.dart';

/// Tab 3: Active job screen with status progression.
///
/// Status flow: On Route -> I've Arrived -> Passenger Onboard -> Complete.
class ActiveJobScreen extends StatelessWidget {
  const ActiveJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Active Job'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation_rounded),
            tooltip: 'Navigate',
            onPressed: () {
              // TODO: launch external navigation app
            },
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          if (bp.activeBooking == null) {
            return _NoActiveJob();
          }

          final booking = bp.activeBooking!;
          final phase = bp.phase;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status progress indicator
                _ProgressIndicator(phase: phase),
                const SizedBox(height: 20),

                // Map placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined,
                                size: 48,
                                color: RedTaxiColors.textSecondary),
                            SizedBox(height: 8),
                            Text('Live Map',
                                style: TextStyle(
                                    color: RedTaxiColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      // Navigation button overlay
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FloatingActionButton.small(
                          onPressed: () {
                            // TODO: launch navigation
                          },
                          backgroundColor: RedTaxiColors.brandRed,
                          child: const Icon(Icons.navigation_rounded,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Route details
                _RouteCard(booking: booking),
                const SizedBox(height: 16),

                // Price
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fare',
                        style: TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\u00A3${booking.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status progression button
                _buildStatusButton(context, bp, phase),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusButton(
      BuildContext context, BookingProvider bp, ActiveJobPhase phase) {
    switch (phase) {
      case ActiveJobPhase.onRoute:
        return StatusButton(
          label: "I've Arrived",
          subtitle: 'SMS will be sent to customer',
          icon: Icons.place_rounded,
          color: const Color(0xFF3B82F6),
          onPressed: () => bp.progressJob(),
        );
      case ActiveJobPhase.arrived:
        return StatusButton(
          label: 'Passenger Onboard',
          subtitle: 'Tap when passenger is in vehicle',
          icon: Icons.person_add_rounded,
          color: RedTaxiColors.warning,
          onPressed: () => bp.progressJob(),
        );
      case ActiveJobPhase.passengerOnBoard:
        return StatusButton(
          label: 'Complete Job',
          subtitle: 'Finish the trip',
          icon: Icons.check_circle_rounded,
          color: RedTaxiColors.success,
          onPressed: () {
            bp.progressJob();
            context.push('/active/complete');
          },
        );
      case ActiveJobPhase.completing:
        return const SizedBox.shrink();
      case ActiveJobPhase.none:
        return const SizedBox.shrink();
    }
  }
}

class _ProgressIndicator extends StatelessWidget {
  final ActiveJobPhase phase;
  const _ProgressIndicator({required this.phase});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('On Route', ActiveJobPhase.onRoute),
      ('Arrived', ActiveJobPhase.arrived),
      ('POB', ActiveJobPhase.passengerOnBoard),
      ('Complete', ActiveJobPhase.completing),
    ];

    int currentIdx = steps.indexWhere((s) => s.$2 == phase);
    if (currentIdx < 0) currentIdx = 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIdx = i ~/ 2;
            final isComplete = stepIdx < currentIdx;
            return Expanded(
              child: Container(
                height: 2,
                color: isComplete
                    ? RedTaxiColors.success
                    : RedTaxiColors.backgroundCard,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isComplete = stepIdx < currentIdx;
          final isCurrent = stepIdx == currentIdx;

          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isComplete
                      ? RedTaxiColors.success
                      : isCurrent
                          ? RedTaxiColors.brandRed
                          : RedTaxiColors.backgroundCard,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : RedTaxiColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx].$1,
                style: TextStyle(
                  color: isCurrent
                      ? RedTaxiColors.textPrimary
                      : RedTaxiColors.textSecondary,
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final Booking booking;
  const _RouteCard({required this.booking});

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
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 10, color: RedTaxiColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PICKUP',
                        style: TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(booking.pickupAddress,
                        style: const TextStyle(
                            color: RedTaxiColors.textPrimary, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 2,
              height: 16,
              color: RedTaxiColors.textSecondary.withOpacity(0.3),
            ),
          ),
          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child:
                    Icon(Icons.circle, size: 10, color: RedTaxiColors.brandRed),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DESTINATION',
                        style: TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(booking.destinationAddress,
                        style: const TextStyle(
                            color: RedTaxiColors.textPrimary, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoActiveJob extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_taxi_outlined,
              size: 72, color: RedTaxiColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 20),
          const Text(
            'No Active Job',
            style: TextStyle(
              color: RedTaxiColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accept an offer to start a trip',
            style: TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

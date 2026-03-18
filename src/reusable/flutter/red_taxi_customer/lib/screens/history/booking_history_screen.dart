import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Past trips list with date, route, and price.
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Trips'),
        automaticallyImplyLeading: false,
      ),
      body: _mockTrips.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64,
                      color: RedTaxiColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No trips yet',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your ride history will appear here',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockTrips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final trip = _mockTrips[index];
                return _TripCard(
                  trip: trip,
                  onTap: () => context.push('/trip-detail'),
                );
              },
            ),
    );
  }
}

class _MockTrip {
  final String id;
  final String pickup;
  final String destination;
  final String date;
  final String price;
  final String status;

  const _MockTrip({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.date,
    required this.price,
    required this.status,
  });
}

const _mockTrips = [
  _MockTrip(
    id: '1',
    pickup: '123 Main St',
    destination: 'Dublin Airport',
    date: '15 Mar 2026, 08:30',
    price: '\$32.50',
    status: 'Completed',
  ),
  _MockTrip(
    id: '2',
    pickup: 'Grand Canal Dock',
    destination: 'Heuston Station',
    date: '12 Mar 2026, 14:15',
    price: '\$18.00',
    status: 'Completed',
  ),
  _MockTrip(
    id: '3',
    pickup: 'St Stephen\'s Green',
    destination: 'Dundrum Town Centre',
    date: '10 Mar 2026, 19:45',
    price: '\$22.75',
    status: 'Completed',
  ),
  _MockTrip(
    id: '4',
    pickup: 'Temple Bar',
    destination: 'Phoenix Park',
    date: '8 Mar 2026, 11:00',
    price: '\$15.50',
    status: 'Cancelled',
  ),
];

class _TripCard extends StatelessWidget {
  final _MockTrip trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCancelled = trip.status == 'Cancelled';

    return Material(
      color: RedTaxiColors.backgroundCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.date,
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? RedTaxiColors.error.withOpacity(0.15)
                          : RedTaxiColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trip.status,
                      style: TextStyle(
                        color: isCancelled
                            ? RedTaxiColors.error
                            : RedTaxiColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Route
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle,
                          color: RedTaxiColors.success, size: 10),
                      Container(
                        width: 1,
                        height: 20,
                        color: RedTaxiColors.textSecondary.withOpacity(0.3),
                      ),
                      const Icon(Icons.circle,
                          color: RedTaxiColors.brandRed, size: 10),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.pickup,
                          style: const TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          trip.destination,
                          style: const TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    trip.price,
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

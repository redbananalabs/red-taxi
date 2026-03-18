import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Today's bookings list with status filters.
class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  String _activeFilter = 'All';
  final _filters = ['All', 'Pending', 'Allocated', 'In Progress', 'Completed'];

  final _mockBookings = const [
    _MockBooking(
      id: 'BK-001',
      customerName: 'Mary O\'Brien',
      pickup: '15 Grafton St',
      destination: 'Dublin Airport T2',
      time: '09:30',
      status: 'Pending',
      driverName: null,
    ),
    _MockBooking(
      id: 'BK-002',
      customerName: 'Patrick Walsh',
      pickup: 'Heuston Station',
      destination: '42 Dame St',
      time: '10:00',
      status: 'Allocated',
      driverName: 'Sean Byrne',
    ),
    _MockBooking(
      id: 'BK-003',
      customerName: 'Aisling Murphy',
      pickup: 'Grand Canal Dock',
      destination: 'Blanchardstown Centre',
      time: '10:15',
      status: 'In Progress',
      driverName: 'Liam Doyle',
    ),
    _MockBooking(
      id: 'BK-004',
      customerName: 'Conor Gallagher',
      pickup: 'Stephen\'s Green',
      destination: 'Dundrum',
      time: '08:45',
      status: 'Completed',
      driverName: 'Declan Ryan',
    ),
    _MockBooking(
      id: 'BK-005',
      customerName: 'Siobhan Kelly',
      pickup: 'Connolly Station',
      destination: 'The Point',
      time: '11:00',
      status: 'Pending',
      driverName: null,
    ),
  ];

  List<_MockBooking> get _filteredBookings {
    if (_activeFilter == 'All') return _mockBookings;
    return _mockBookings.where((b) => b.status == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Bookings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-booking'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filters
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final active = filter == _activeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = filter),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? RedTaxiColors.brandRed
                          : RedTaxiColors.backgroundCard,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : RedTaxiColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Bookings list
          Expanded(
            child: _filteredBookings.isEmpty
                ? Center(
                    child: Text(
                      'No $_activeFilter bookings',
                      style: const TextStyle(
                        color: RedTaxiColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _BookingCard(
                        booking: booking,
                        onTap: () => context.push('/booking-detail'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MockBooking {
  final String id;
  final String customerName;
  final String pickup;
  final String destination;
  final String time;
  final String status;
  final String? driverName;

  const _MockBooking({
    required this.id,
    required this.customerName,
    required this.pickup,
    required this.destination,
    required this.time,
    required this.status,
    this.driverName,
  });
}

class _BookingCard extends StatelessWidget {
  final _MockBooking booking;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.onTap});

  Color _statusColor() {
    switch (booking.status) {
      case 'Pending':
        return RedTaxiColors.warning;
      case 'Allocated':
        return const Color(0xFF3B82F6);
      case 'In Progress':
        return RedTaxiColors.brandRed;
      case 'Completed':
        return RedTaxiColors.success;
      default:
        return RedTaxiColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RedTaxiColors.backgroundCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: ID, time, status
              Row(
                children: [
                  Text(
                    booking.id,
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.schedule,
                      color: RedTaxiColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    booking.time,
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: _statusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Customer name
              Text(
                booking.customerName,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Route
              Row(
                children: [
                  const Icon(Icons.circle,
                      color: RedTaxiColors.success, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.pickup,
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
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.circle,
                      color: RedTaxiColors.brandRed, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.destination,
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

              // Driver info
              if (booking.driverName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        color: RedTaxiColors.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      booking.driverName!,
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

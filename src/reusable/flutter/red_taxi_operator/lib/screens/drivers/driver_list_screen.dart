import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Driver list screen with status indicators.
class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  String _filter = 'All';

  final _drivers = const [
    _DriverInfo(
      name: 'Sean Byrne',
      phone: '+353 87 111 2222',
      vehicle: 'Toyota Prius',
      reg: '191-D-12345',
      status: 'available',
      rating: 4.8,
      trips: 342,
    ),
    _DriverInfo(
      name: 'Liam Doyle',
      phone: '+353 87 333 4444',
      vehicle: 'VW Passat',
      reg: '201-D-67890',
      status: 'busy',
      rating: 4.6,
      trips: 218,
    ),
    _DriverInfo(
      name: 'Declan Ryan',
      phone: '+353 87 555 6666',
      vehicle: 'Skoda Octavia',
      reg: '211-D-11111',
      status: 'available',
      rating: 4.9,
      trips: 456,
    ),
    _DriverInfo(
      name: 'Michael Nolan',
      phone: '+353 87 777 8888',
      vehicle: 'Ford Mondeo',
      reg: '191-D-22222',
      status: 'offline',
      rating: 4.5,
      trips: 189,
    ),
    _DriverInfo(
      name: 'Brian Kavanagh',
      phone: '+353 87 999 0000',
      vehicle: 'Toyota Camry',
      reg: '201-D-33333',
      status: 'busy',
      rating: 4.7,
      trips: 267,
    ),
    _DriverInfo(
      name: 'Paul Fitzgerald',
      phone: '+353 86 111 3333',
      vehicle: 'Hyundai Ioniq',
      reg: '221-D-44444',
      status: 'available',
      rating: 4.8,
      trips: 123,
    ),
  ];

  List<_DriverInfo> get _filtered {
    if (_filter == 'All') return _drivers;
    return _drivers
        .where((d) => d.status == _filter.toLowerCase())
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return RedTaxiColors.success;
      case 'busy':
        return RedTaxiColors.warning;
      case 'offline':
        return RedTaxiColors.textSecondary;
      default:
        return RedTaxiColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Drivers'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_drivers.length} total',
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Available', 'Busy', 'Offline'].map((f) {
                final active = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? RedTaxiColors.brandRed
                            : RedTaxiColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        f,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : RedTaxiColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Driver list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final driver = _filtered[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: RedTaxiColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: RedTaxiColors.backgroundSurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person,
                                color: RedTaxiColors.textSecondary, size: 26),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _statusColor(driver.status),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: RedTaxiColors.backgroundCard,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: const TextStyle(
                                color: RedTaxiColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${driver.vehicle} - ${driver.reg}',
                              style: const TextStyle(
                                color: RedTaxiColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: RedTaxiColors.warning, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '${driver.rating}',
                                  style: const TextStyle(
                                    color: RedTaxiColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${driver.trips} trips',
                                  style: const TextStyle(
                                    color: RedTaxiColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Column(
                        children: [
                          Text(
                            driver.status[0].toUpperCase() +
                                driver.status.substring(1),
                            style: TextStyle(
                              color: _statusColor(driver.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: RedTaxiColors.backgroundSurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.phone,
                                      color: RedTaxiColors.success, size: 16),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => context.push('/send-message'),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: RedTaxiColors.backgroundSurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.message,
                                      color: RedTaxiColors.brandRed, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
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

class _DriverInfo {
  final String name;
  final String phone;
  final String vehicle;
  final String reg;
  final String status;
  final double rating;
  final int trips;

  const _DriverInfo({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.reg,
    required this.status,
    required this.rating,
    required this.trips,
  });
}

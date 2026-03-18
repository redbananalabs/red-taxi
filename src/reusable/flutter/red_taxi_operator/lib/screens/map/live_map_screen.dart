import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Live map screen showing driver pins colored by status.
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  String _filter = 'All';

  final _mockDrivers = const [
    _MapDriver(name: 'Sean Byrne', status: 'available', vehicle: 'Toyota Prius'),
    _MapDriver(name: 'Liam Doyle', status: 'busy', vehicle: 'VW Passat'),
    _MapDriver(name: 'Declan Ryan', status: 'available', vehicle: 'Skoda Octavia'),
    _MapDriver(name: 'Michael Nolan', status: 'offline', vehicle: 'Ford Mondeo'),
    _MapDriver(name: 'Brian Kavanagh', status: 'busy', vehicle: 'Toyota Camry'),
    _MapDriver(name: 'Paul Fitzgerald', status: 'available', vehicle: 'Hyundai Ioniq'),
  ];

  List<_MapDriver> get _filtered {
    if (_filter == 'All') return _mockDrivers;
    return _mockDrivers.where((d) => d.status == _filter.toLowerCase()).toList();
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
      body: Stack(
        children: [
          // Map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1C1F2B),
            child: CustomPaint(
              painter: _GridPainter(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 56,
                        color: RedTaxiColors.textSecondary.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    Text(
                      'Google Maps will render here',
                      style: TextStyle(
                        color: RedTaxiColors.textSecondary.withOpacity(0.3),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Simulated driver pins
          ..._mockDrivers.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final top = 120.0 + (i * 70);
            final left = 40.0 + (i % 3) * 100;
            return Positioned(
              top: top,
              left: left,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _statusColor(d.status),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_taxi,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: RedTaxiColors.backgroundCard.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      d.name.split(' ').first,
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.backgroundCard.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map,
                              color: RedTaxiColors.brandRed, size: 22),
                          const SizedBox(width: 10),
                          const Text(
                            'Live Map',
                            style: TextStyle(
                              color: RedTaxiColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_mockDrivers.where((d) => d.status != 'offline').length} active',
                            style: const TextStyle(
                              color: RedTaxiColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filters
                    Row(
                      children: ['All', 'Available', 'Busy', 'Offline']
                          .map((f) {
                        final active = f == _filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: active
                                    ? RedTaxiColors.brandRed
                                    : RedTaxiColors.backgroundCard
                                        .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : RedTaxiColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom driver list
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                color: RedTaxiColors.backgroundSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: RedTaxiColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Text(
                      '${_filtered.length} drivers',
                      style: const TextStyle(
                        color: RedTaxiColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final d = _filtered[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: RedTaxiColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _statusColor(d.status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      d.name,
                                      style: const TextStyle(
                                        color: RedTaxiColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                d.vehicle,
                                style: const TextStyle(
                                  color: RedTaxiColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                d.status[0].toUpperCase() +
                                    d.status.substring(1),
                                style: TextStyle(
                                  color: _statusColor(d.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDriver {
  final String name;
  final String status;
  final String vehicle;

  const _MapDriver({
    required this.name,
    required this.status,
    required this.vehicle,
  });
}

/// Draws a faint grid to simulate map tiles.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF242736)
      ..strokeWidth = 0.5;

    const step = 60.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

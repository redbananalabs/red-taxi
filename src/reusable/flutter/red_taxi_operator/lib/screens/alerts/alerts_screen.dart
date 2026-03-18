import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Web booking notifications with Accept/Reject buttons.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<_Alert> _alerts = [
    _Alert(
      id: '1',
      type: 'Web Booking',
      customerName: 'James McCarthy',
      pickup: '44 O\'Connell St',
      destination: 'Malahide',
      time: '2 min ago',
      passengers: 3,
    ),
    _Alert(
      id: '2',
      type: 'Web Booking',
      customerName: 'Sophie Ryan',
      pickup: 'Pearse Station',
      destination: 'Dun Laoghaire',
      time: '5 min ago',
      passengers: 1,
    ),
    _Alert(
      id: '3',
      type: 'App Booking',
      customerName: 'Tom Brennan',
      pickup: 'Christ Church',
      destination: 'Tallaght Hospital',
      time: '8 min ago',
      passengers: 2,
    ),
  ];

  void _accept(String id) {
    setState(() {
      _alerts.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking accepted'),
        backgroundColor: RedTaxiColors.success,
      ),
    );
  }

  void _reject(String id) {
    setState(() {
      _alerts.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking rejected'),
        backgroundColor: RedTaxiColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        automaticallyImplyLeading: false,
        actions: [
          if (_alerts.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _alerts.clear()),
              child: const Text(
                'Clear All',
                style: TextStyle(color: RedTaxiColors.textSecondary),
              ),
            ),
        ],
      ),
      body: _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: RedTaxiColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No new alerts',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'New web bookings will appear here',
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
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return _AlertCard(
                  alert: alert,
                  onAccept: () => _accept(alert.id),
                  onReject: () => _reject(alert.id),
                );
              },
            ),
    );
  }
}

class _Alert {
  final String id;
  final String type;
  final String customerName;
  final String pickup;
  final String destination;
  final String time;
  final int passengers;

  const _Alert({
    required this.id,
    required this.type,
    required this.customerName,
    required this.pickup,
    required this.destination,
    required this.time,
    required this.passengers,
  });
}

class _AlertCard extends StatelessWidget {
  final _Alert alert;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _AlertCard({
    required this.alert,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RedTaxiColors.brandRed.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: RedTaxiColors.brandRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.type,
                  style: const TextStyle(
                    color: RedTaxiColors.brandRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule,
                  color: RedTaxiColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(
                alert.time,
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: RedTaxiColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                alert.customerName,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people_outline,
                  color: RedTaxiColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${alert.passengers}',
                style: const TextStyle(
                  color: RedTaxiColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route
          Row(
            children: [
              const Icon(Icons.circle, color: RedTaxiColors.success, size: 8),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.pickup,
                  style: const TextStyle(
                    color: RedTaxiColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.circle, color: RedTaxiColors.brandRed, size: 8),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.destination,
                  style: const TextStyle(
                    color: RedTaxiColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RedTaxiColors.error,
                      side: const BorderSide(color: RedTaxiColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RedTaxiColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

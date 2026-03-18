import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Booking detail with allocate driver action.
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  String? _selectedDriver;

  final _availableDrivers = [
    'Sean Byrne',
    'Liam Doyle',
    'Declan Ryan',
    'Michael Nolan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Booking Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RedTaxiColors.warning.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, color: RedTaxiColors.warning, size: 20),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Allocation',
                        style: TextStyle(
                          color: RedTaxiColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Assign a driver to this booking',
                        style: TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Booking info
            _SectionTitle('Booking Info'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'Booking ID', value: 'BK-001'),
                  SizedBox(height: 10),
                  _InfoRow(label: 'Date', value: '18 Mar 2026'),
                  SizedBox(height: 10),
                  _InfoRow(label: 'Time', value: '09:30'),
                  SizedBox(height: 10),
                  _InfoRow(label: 'Passengers', value: '2'),
                  SizedBox(height: 10),
                  _InfoRow(label: 'Vehicle', value: 'Standard'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer info
            _SectionTitle('Customer'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: RedTaxiColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person,
                        color: RedTaxiColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mary O\'Brien',
                          style: TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '+353 87 123 4567',
                          style: TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone,
                        color: RedTaxiColors.success, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route
            _SectionTitle('Route'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.circle, color: RedTaxiColors.success, size: 10),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '15 Grafton St, Dublin 2',
                          style: TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 2,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: RedTaxiColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: RedTaxiColors.brandRed, size: 10),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dublin Airport, Terminal 2',
                          style: TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Allocate driver
            _SectionTitle('Allocate Driver'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDriver,
                    hint: const Text(
                      'Select a driver',
                      style: TextStyle(color: RedTaxiColors.textSecondary),
                    ),
                    dropdownColor: RedTaxiColors.backgroundCard,
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: RedTaxiColors.backgroundSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_search,
                          color: RedTaxiColors.textSecondary, size: 20),
                    ),
                    items: _availableDrivers
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDriver = v),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _selectedDriver != null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Allocated to $_selectedDriver'),
                                  backgroundColor: RedTaxiColors.success,
                                ),
                              );
                              context.pop();
                            }
                          : null,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Allocate Driver',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cancel booking
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.pop();
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RedTaxiColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

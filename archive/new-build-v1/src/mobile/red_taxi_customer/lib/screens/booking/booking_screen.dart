import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';

/// Full booking form: pickup, destination, date/time, passengers, vehicle type.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupController = TextEditingController();
  final _destController = TextEditingController();
  String _selectedVehicle = 'standard';
  int _passengers = 1;
  DateTime? _scheduledTime;

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'Current Location';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  Future<void> _confirmBooking() async {
    final provider = context.read<BookingProvider>();
    provider.setPickup(_pickupController.text);
    provider.setDestination(_destController.text);
    provider.setVehicleType(_selectedVehicle);
    provider.setPassengerCount(_passengers);
    provider.setScheduledDateTime(_scheduledTime);

    final success = await provider.createBooking();
    if (mounted && success) {
      context.go('/booking-confirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Book a Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup
            _SectionLabel('Pickup Location'),
            const SizedBox(height: 8),
            _InputField(
              controller: _pickupController,
              icon: Icons.my_location,
              hint: 'Enter pickup address',
              iconColor: RedTaxiColors.success,
            ),
            const SizedBox(height: 16),

            // Destination
            _SectionLabel('Destination'),
            const SizedBox(height: 8),
            _InputField(
              controller: _destController,
              icon: Icons.location_on,
              hint: 'Where are you going?',
              iconColor: RedTaxiColors.brandRed,
            ),
            const SizedBox(height: 24),

            // Date / Time
            _SectionLabel('Date & Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule,
                        color: RedTaxiColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _scheduledTime != null
                          ? '${_scheduledTime!.day}/${_scheduledTime!.month}/${_scheduledTime!.year} '
                            '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                          : 'Now',
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: RedTaxiColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Passengers
            _SectionLabel('Passengers'),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline,
                      color: RedTaxiColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '$_passengers passenger${_passengers > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _passengers > 1
                        ? () => setState(() => _passengers--)
                        : null,
                    icon: Icon(Icons.remove_circle_outline,
                        color: _passengers > 1
                            ? RedTaxiColors.textPrimary
                            : RedTaxiColors.textSecondary),
                    iconSize: 22,
                  ),
                  Text(
                    '$_passengers',
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _passengers < 8
                        ? () => setState(() => _passengers++)
                        : null,
                    icon: Icon(Icons.add_circle_outline,
                        color: _passengers < 8
                            ? RedTaxiColors.textPrimary
                            : RedTaxiColors.textSecondary),
                    iconSize: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle type
            _SectionLabel('Vehicle Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _VehicleOption(
                    label: 'Standard',
                    icon: Icons.local_taxi,
                    price: '\$14.50',
                    isSelected: _selectedVehicle == 'standard',
                    onTap: () => setState(() => _selectedVehicle = 'standard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VehicleOption(
                    label: 'Premium',
                    icon: Icons.directions_car,
                    price: '\$24.50',
                    isSelected: _selectedVehicle == 'premium',
                    onTap: () => setState(() => _selectedVehicle = 'premium'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Price estimate
            if (_destController.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RedTaxiColors.brandRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated fare',
                      style: TextStyle(
                        color: RedTaxiColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _selectedVehicle == 'premium' ? '\$24.50' : '\$14.50',
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : _confirmBooking,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: RedTaxiColors.textPrimary,
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Color iconColor;

  const _InputField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: RedTaxiColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: RedTaxiColors.textSecondary),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: RedTaxiColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RedTaxiColors.brandRed),
        ),
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.label,
    required this.icon,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RedTaxiColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? RedTaxiColors.brandRed
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.textSecondary,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? RedTaxiColors.textPrimary
                    : RedTaxiColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: isSelected
                    ? RedTaxiColors.brandRed
                    : RedTaxiColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

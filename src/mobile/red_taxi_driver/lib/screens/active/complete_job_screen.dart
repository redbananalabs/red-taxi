import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';

/// Completion form: waiting time, parking charge, driver price, tip.
class CompleteJobScreen extends StatefulWidget {
  const CompleteJobScreen({super.key});

  @override
  State<CompleteJobScreen> createState() => _CompleteJobScreenState();
}

class _CompleteJobScreenState extends State<CompleteJobScreen> {
  final _waitingCtrl = TextEditingController(text: '0');
  final _parkingCtrl = TextEditingController(text: '0.00');
  final _priceCtrl = TextEditingController();
  final _tipCtrl = TextEditingController(text: '0.00');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final booking = context.read<BookingProvider>().activeBooking;
    _priceCtrl.text = booking?.price.toStringAsFixed(2) ?? '0.00';
  }

  @override
  void dispose() {
    _waitingCtrl.dispose();
    _parkingCtrl.dispose();
    _priceCtrl.dispose();
    _tipCtrl.dispose();
    super.dispose();
  }

  double get _total {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final parking = double.tryParse(_parkingCtrl.text) ?? 0;
    final tip = double.tryParse(_tipCtrl.text) ?? 0;
    return price + parking + tip;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    context.read<BookingProvider>().completeJob(
          waitingMinutes: int.tryParse(_waitingCtrl.text) ?? 0,
          parkingCharge: double.tryParse(_parkingCtrl.text) ?? 0,
          driverPrice: double.tryParse(_priceCtrl.text) ?? 0,
          tip: double.tryParse(_tipCtrl.text) ?? 0,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Job completed successfully'),
          backgroundColor: RedTaxiColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.go('/schedule');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Complete Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(Icons.check_circle_rounded,
                size: 48, color: RedTaxiColors.success),
            const SizedBox(height: 12),
            const Text(
              'Job Summary',
              style: TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter the final charges for this trip',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),

            // Waiting time
            _FormField(
              controller: _waitingCtrl,
              label: 'Waiting Time',
              suffix: 'mins',
              icon: Icons.timer_outlined,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Parking charge
            _FormField(
              controller: _parkingCtrl,
              label: 'Parking Charge',
              prefix: '\u00A3',
              icon: Icons.local_parking_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Driver price
            _FormField(
              controller: _priceCtrl,
              label: 'Driver Price',
              prefix: '\u00A3',
              icon: Icons.payments_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Tip
            _FormField(
              controller: _tipCtrl,
              label: 'Tip',
              prefix: '\u00A3',
              icon: Icons.volunteer_activism_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    'Total',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\u00A3${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedTaxiColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit & Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix;
  final String? suffix;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    this.prefix,
    this.suffix,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        color: RedTaxiColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: RedTaxiColors.textSecondary),
        prefixIcon: Icon(icon, color: RedTaxiColors.textSecondary),
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: const TextStyle(
          color: RedTaxiColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          color: RedTaxiColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: RedTaxiColors.backgroundSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: RedTaxiColors.brandRed, width: 1.5),
        ),
      ),
    );
  }
}

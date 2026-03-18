import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Quick booking creation form (simplified for operator use).
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  int _passengers = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_customerNameCtrl.text.isEmpty ||
        _pickupCtrl.text.isEmpty ||
        _destCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: RedTaxiColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // TODO: call API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully'),
          backgroundColor: RedTaxiColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label('Customer Name *'),
            const SizedBox(height: 8),
            _Field(controller: _customerNameCtrl, hint: 'Full name'),
            const SizedBox(height: 16),

            _Label('Customer Phone'),
            const SizedBox(height: 8),
            _Field(
              controller: _customerPhoneCtrl,
              hint: '+353 xxx xxx xxxx',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _Label('Pickup Address *'),
            const SizedBox(height: 8),
            _Field(
              controller: _pickupCtrl,
              hint: 'Enter pickup address',
              icon: Icons.my_location,
            ),
            const SizedBox(height: 16),

            _Label('Destination *'),
            const SizedBox(height: 8),
            _Field(
              controller: _destCtrl,
              hint: 'Enter destination',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            _Label('Passengers'),
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
                    '$_passengers',
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
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                    color: RedTaxiColors.textPrimary,
                    disabledColor: RedTaxiColors.textSecondary,
                  ),
                  IconButton(
                    onPressed: _passengers < 8
                        ? () => setState(() => _passengers++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    color: RedTaxiColors.textPrimary,
                    disabledColor: RedTaxiColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: RedTaxiColors.textPrimary,
                        ),
                      )
                    : const Text(
                        'Create Booking',
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RedTaxiColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: RedTaxiColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: RedTaxiColors.textSecondary),
        prefixIcon: icon != null
            ? Icon(icon, color: RedTaxiColors.textSecondary, size: 20)
            : null,
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

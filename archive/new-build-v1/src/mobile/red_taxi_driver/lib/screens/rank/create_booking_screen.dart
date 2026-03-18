import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Create rank job (Hackney) booking form.
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _vehicleType = 'Saloon';
  bool _submitting = false;

  static const _vehicleTypes = [
    'Saloon',
    'Estate',
    'MPV',
    'Executive',
    'Wheelchair Accessible',
  ];

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking created successfully'),
          backgroundColor: RedTaxiColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Create Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rank / Hackney Job',
                style: TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create a new booking from the rank',
                style: TextStyle(
                    color: RedTaxiColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Pickup
              _buildField(
                controller: _pickupCtrl,
                label: 'Pickup Address',
                hint: 'Enter pickup location',
                icon: Icons.trip_origin_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Destination
              _buildField(
                controller: _destCtrl,
                label: 'Destination',
                hint: 'Enter destination',
                icon: Icons.place_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Passenger name
              _buildField(
                controller: _nameCtrl,
                label: 'Passenger Name',
                hint: 'Optional',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Phone
              _buildField(
                controller: _phoneCtrl,
                label: 'Passenger Phone',
                hint: 'Optional',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Vehicle type
              const Text('Vehicle Type',
                  style: TextStyle(
                      color: RedTaxiColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _vehicleType,
                    isExpanded: true,
                    dropdownColor: RedTaxiColors.backgroundSurface,
                    style: const TextStyle(
                        color: RedTaxiColors.textPrimary, fontSize: 15),
                    items: _vehicleTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _vehicleType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price
              _buildField(
                controller: _priceCtrl,
                label: 'Price (\u00A3)',
                hint: '0.00',
                icon: Icons.payments_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                  label: Text(
                    _submitting ? 'Creating...' : 'Create Booking',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RedTaxiColors.brandRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: RedTaxiColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: RedTaxiColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: RedTaxiColors.textSecondary.withOpacity(0.5)),
            prefixIcon: icon != null
                ? Icon(icon, color: RedTaxiColors.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: RedTaxiColors.backgroundSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: RedTaxiColors.brandRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

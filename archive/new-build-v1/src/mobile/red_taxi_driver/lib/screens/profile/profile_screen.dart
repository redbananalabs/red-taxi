import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/auth_provider.dart';

/// Driver profile view/edit screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _vehicleCtrl;
  late TextEditingController _regCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.driverName ?? 'John Driver');
    _phoneCtrl = TextEditingController(text: '07700 900123');
    _vehicleCtrl = TextEditingController(text: 'Toyota Prius 2023');
    _regCtrl = TextEditingController(text: 'AB23 CDE');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleCtrl.dispose();
    _regCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_editing) {
      // Save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          backgroundColor: RedTaxiColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    setState(() => _editing = !_editing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _editing ? 'Save' : 'Edit',
              style: const TextStyle(
                color: RedTaxiColors.brandRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: RedTaxiColors.brandRed.withOpacity(0.2),
                    child: const Text(
                      'JD',
                      style: TextStyle(
                        color: RedTaxiColors.brandRed,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_editing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: RedTaxiColors.brandRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Personal Details
            _SectionHeader(title: 'PERSONAL DETAILS'),
            const SizedBox(height: 10),
            _ProfileField(
              label: 'Full Name',
              controller: _nameCtrl,
              icon: Icons.person_outline,
              editing: _editing,
            ),
            const SizedBox(height: 10),
            _ProfileField(
              label: 'Phone Number',
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              editing: _editing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _ProfileField(
              label: 'Email',
              value: context.read<AuthProvider>().email ?? 'driver@redtaxi.co.uk',
              icon: Icons.email_outlined,
              editing: false, // Email not editable
            ),
            const SizedBox(height: 24),

            // Vehicle Details
            _SectionHeader(title: 'VEHICLE DETAILS'),
            const SizedBox(height: 10),
            _ProfileField(
              label: 'Vehicle',
              controller: _vehicleCtrl,
              icon: Icons.directions_car_outlined,
              editing: _editing,
            ),
            const SizedBox(height: 10),
            _ProfileField(
              label: 'Registration',
              controller: _regCtrl,
              icon: Icons.confirmation_number_outlined,
              editing: _editing,
            ),
            const SizedBox(height: 24),

            // Stats
            _SectionHeader(title: 'STATISTICS'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  _StatRow(label: 'Total Jobs', value: '1,247'),
                  SizedBox(height: 10),
                  _StatRow(label: 'Member Since', value: 'Jan 2024'),
                  SizedBox(height: 10),
                  _StatRow(label: 'Rating', value: '4.8 / 5.0'),
                  SizedBox(height: 10),
                  _StatRow(label: 'Acceptance Rate', value: '94%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: RedTaxiColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? value;
  final IconData icon;
  final bool editing;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.label,
    this.controller,
    this.value,
    required this.icon,
    required this.editing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: RedTaxiColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: RedTaxiColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                editing && controller != null
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: const TextStyle(
                            color: RedTaxiColors.textPrimary, fontSize: 15),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        value ?? controller?.text ?? '',
                        style: const TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: RedTaxiColors.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/customer_auth_provider.dart';

/// Profile screen: name, phone, email, payment methods.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<CustomerAuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: RedTaxiColors.brandRed.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        color: RedTaxiColors.brandRed, size: 40),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth.userName ?? 'Customer',
                    style: const TextStyle(
                      color: RedTaxiColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.phoneNumber ?? '+353 xxx xxx xxxx',
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (auth.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      auth.email!,
                      style: const TextStyle(
                        color: RedTaxiColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 140,
                    child: OutlinedButton(
                      onPressed: () => _showEditProfile(context, auth),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RedTaxiColors.textPrimary,
                        side: const BorderSide(color: Color(0xFF2A2D3A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: 'Trips', value: '24'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'Saved', value: '3'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'Rating', value: '4.9'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment methods
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Methods',
                style: TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PaymentMethodCard(
              icon: Icons.money,
              label: 'Cash',
              subtitle: 'Default payment',
              isDefault: true,
            ),
            const SizedBox(height: 8),
            _PaymentMethodCard(
              icon: Icons.credit_card,
              label: 'Visa ending 4242',
              subtitle: 'Expires 12/27',
              isDefault: false,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: RedTaxiColors.brandRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add,
                      color: RedTaxiColors.brandRed, size: 20),
                ),
                title: const Text(
                  'Add Payment Method',
                  style: TextStyle(
                    color: RedTaxiColors.brandRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // Menu items
            _MenuItem(
              icon: Icons.bookmark_outline,
              label: 'Saved Places',
              onTap: () => context.push('/saved-places'),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  auth.logout();
                  context.go('/tenant-select');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: RedTaxiColors.error,
                  side: const BorderSide(color: RedTaxiColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, CustomerAuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userName);
    final emailCtrl = TextEditingController(text: auth.email);

    showModalBottomSheet(
      context: context,
      backgroundColor: RedTaxiColors.backgroundSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: RedTaxiColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: RedTaxiColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    auth.updateProfile(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: RedTaxiColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDefault;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: RedTaxiColors.backgroundSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: RedTaxiColors.textSecondary, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: RedTaxiColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: isDefault
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RedTaxiColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: RedTaxiColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: RedTaxiColors.textSecondary, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            color: RedTaxiColors.textPrimary,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: RedTaxiColors.textSecondary, size: 20),
        onTap: onTap,
      ),
    );
  }
}

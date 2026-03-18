import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/operator_auth_provider.dart';

/// Menu screen: Drivers, Accounts, Send Message, Settings.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<OperatorAuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Operator info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: RedTaxiColors.brandRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: RedTaxiColors.brandRed, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName ?? 'Operator',
                        style: const TextStyle(
                          color: RedTaxiColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.tenantName ?? 'Company',
                        style: const TextStyle(
                          color: RedTaxiColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                child: _StatCard(
                  icon: Icons.local_taxi,
                  label: 'Drivers',
                  value: '12',
                  color: RedTaxiColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.list_alt,
                  label: 'Today',
                  value: '34',
                  color: RedTaxiColors.brandRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  label: 'Revenue',
                  value: '\$1.2k',
                  color: RedTaxiColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu items
          _SectionHeader('Fleet Management'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.people_outline,
                  label: 'Drivers',
                  subtitle: 'View and manage drivers',
                  onTap: () => context.push('/drivers'),
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Accounts',
                  subtitle: 'Financial overview',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _SectionHeader('Communication'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.send_outlined,
                  label: 'Send Message',
                  subtitle: 'Message drivers',
                  onTap: () => context.push('/send-message'),
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.campaign_outlined,
                  label: 'Announcements',
                  subtitle: 'Broadcast to all drivers',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _SectionHeader('Settings'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.settings_outlined,
                  label: 'App Settings',
                  subtitle: 'Notifications, preferences',
                  onTap: () {},
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  subtitle: 'Contact support',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                auth.logout();
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
          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Red Taxi Operator v1.0.0',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: RedTaxiColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: RedTaxiColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: RedTaxiColors.textSecondary, size: 22),
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
      trailing: const Icon(Icons.chevron_right,
          color: RedTaxiColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}

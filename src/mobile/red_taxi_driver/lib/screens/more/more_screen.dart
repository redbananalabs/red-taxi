import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/auth_provider.dart';

/// Tab 5: More menu with grid of sub-features.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('More')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Driver info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RedTaxiColors.backgroundCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: RedTaxiColors.brandRed.withOpacity(0.2),
                    child: Text(
                      (auth.driverName ?? 'D')[0].toUpperCase(),
                      style: const TextStyle(
                        color: RedTaxiColors.brandRed,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.driverName ?? 'Driver',
                          style: const TextStyle(
                            color: RedTaxiColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.email ?? '',
                          style: const TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: RedTaxiColors.textSecondary),
                    onPressed: () => context.push('/more/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings',
                  color: RedTaxiColors.success,
                  onTap: () => context.push('/more/earnings'),
                ),
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Statements',
                  color: const Color(0xFF3B82F6),
                  onTap: () => context.push('/more/statements'),
                ),
                _MenuTile(
                  icon: Icons.folder_outlined,
                  label: 'Documents',
                  color: RedTaxiColors.warning,
                  onTap: () => context.push('/more/documents'),
                ),
                _MenuTile(
                  icon: Icons.receipt_outlined,
                  label: 'Expenses',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/more/expenses'),
                ),
                _MenuTile(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  color: const Color(0xFF06B6D4),
                  onTap: () => context.push('/more/profile'),
                ),
                _MenuTile(
                  icon: Icons.message_outlined,
                  label: 'Messages',
                  color: const Color(0xFFEC4899),
                  onTap: () => context.push('/more/messages'),
                ),
                _MenuTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  color: RedTaxiColors.textSecondary,
                  onTap: () => context.push('/more/settings'),
                ),
                _MenuTile(
                  icon: Icons.add_circle_outline,
                  label: 'Create\nBooking',
                  color: RedTaxiColors.brandRed,
                  onTap: () => context.push('/more/create-booking'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: RedTaxiColors.backgroundSurface,
                      title: const Text('Sign Out?',
                          style:
                              TextStyle(color: RedTaxiColors.textPrimary)),
                      content: const Text(
                        'Are you sure you want to sign out?',
                        style:
                            TextStyle(color: RedTaxiColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: RedTaxiColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out',
                              style:
                                  TextStyle(color: RedTaxiColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RedTaxiColors.error,
                  side: const BorderSide(color: RedTaxiColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RedTaxiColors.backgroundCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

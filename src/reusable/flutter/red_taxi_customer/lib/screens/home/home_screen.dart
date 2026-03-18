import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/booking_provider.dart';

/// Main home screen with map placeholder and "Where to?" search bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1C1F2B),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined,
                      size: 80, color: RedTaxiColors.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary.withOpacity(0.3),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top bar with greeting
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu,
                          color: RedTaxiColors.textPrimary, size: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_taxi,
                              color: RedTaxiColors.brandRed, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Red Taxi',
                            style: TextStyle(
                              color: RedTaxiColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: RedTaxiColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: RedTaxiColors.textPrimary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: RedTaxiColors.backgroundSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Where to search bar
                  GestureDetector(
                    onTap: () => context.push('/booking'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: RedTaxiColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search,
                              color: RedTaxiColors.textSecondary, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Where to?',
                            style: TextStyle(
                              color: RedTaxiColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.schedule,
                              color: RedTaxiColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.flash_on,
                          label: 'Book Now',
                          onTap: () {
                            context.read<BookingProvider>().clearBookingForm();
                            context.push('/booking');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.schedule,
                          label: 'Schedule',
                          onTap: () {
                            context.read<BookingProvider>().clearBookingForm();
                            context.push('/booking');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Saved places
                  const Text(
                    'Saved places',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SavedPlaceRow(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    subtitle: 'Set home address',
                    onTap: () => context.push('/saved-places'),
                  ),
                  const SizedBox(height: 4),
                  _SavedPlaceRow(
                    icon: Icons.work_outline,
                    label: 'Work',
                    subtitle: 'Set work address',
                    onTap: () => context.push('/saved-places'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RedTaxiColors.backgroundCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: RedTaxiColors.brandRed, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedPlaceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SavedPlaceRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: RedTaxiColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: RedTaxiColors.textPrimary, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: RedTaxiColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: RedTaxiColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

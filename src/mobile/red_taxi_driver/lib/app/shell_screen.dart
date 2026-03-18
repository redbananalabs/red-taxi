import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../providers/booking_provider.dart';

/// Bottom navigation shell that wraps the 5 main tabs.
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  static const _tabs = [
    '/schedule',
    '/offers',
    '/active',
    '/availability',
    '/more',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final offerCount = context.watch<BookingProvider>().pendingOffers.length;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: RedTaxiColors.backgroundSurface,
          border: Border(
            top: BorderSide(color: Color(0xFF2A2D3A), width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          backgroundColor: RedTaxiColors.backgroundSurface,
          indicatorColor: RedTaxiColors.brandRed.withOpacity(0.15),
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined,
                  color: RedTaxiColors.textSecondary),
              selectedIcon: Icon(Icons.calendar_today_rounded,
                  color: RedTaxiColors.brandRed),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: offerCount > 0,
                label: Text('$offerCount',
                    style: const TextStyle(fontSize: 10)),
                backgroundColor: RedTaxiColors.brandRed,
                child: const Icon(Icons.work_outline_rounded,
                    color: RedTaxiColors.textSecondary),
              ),
              selectedIcon: Badge(
                isLabelVisible: offerCount > 0,
                label: Text('$offerCount',
                    style: const TextStyle(fontSize: 10)),
                backgroundColor: RedTaxiColors.brandRed,
                child: const Icon(Icons.work_rounded,
                    color: RedTaxiColors.brandRed),
              ),
              label: 'Offers',
            ),
            const NavigationDestination(
              icon: Icon(Icons.local_taxi_outlined,
                  color: RedTaxiColors.textSecondary),
              selectedIcon: Icon(Icons.local_taxi_rounded,
                  color: RedTaxiColors.brandRed),
              label: 'Active',
            ),
            const NavigationDestination(
              icon: Icon(Icons.event_available_outlined,
                  color: RedTaxiColors.textSecondary),
              selectedIcon: Icon(Icons.event_available_rounded,
                  color: RedTaxiColors.brandRed),
              label: 'Availability',
            ),
            const NavigationDestination(
              icon: Icon(Icons.menu_rounded,
                  color: RedTaxiColors.textSecondary),
              selectedIcon:
                  Icon(Icons.menu_rounded, color: RedTaxiColors.brandRed),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

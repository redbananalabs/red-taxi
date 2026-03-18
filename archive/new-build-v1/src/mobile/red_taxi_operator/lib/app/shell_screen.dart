import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Bottom navigation shell for the operator app.
class OperatorShellScreen extends StatelessWidget {
  final Widget child;

  const OperatorShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/alerts')) return 1;
    if (location.startsWith('/map')) return 2;
    if (location.startsWith('/more')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2A2D3A), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go('/bookings');
              case 1:
                context.go('/alerts');
              case 2:
                context.go('/map');
              case 3:
                context.go('/more');
            }
          },
          backgroundColor: RedTaxiColors.backgroundSurface,
          selectedItemColor: RedTaxiColors.brandRed,
          unselectedItemColor: RedTaxiColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                smallSize: 8,
                backgroundColor: RedTaxiColors.brandRed,
                child: Icon(Icons.notifications_outlined),
              ),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/bookings/booking_list_screen.dart';
import '../screens/bookings/booking_detail_screen.dart';
import '../screens/bookings/create_booking_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/map/live_map_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/drivers/driver_list_screen.dart';
import '../screens/messaging/send_message_screen.dart';
import 'shell_screen.dart';

final operatorRouter = GoRouter(
  initialLocation: '/bookings',
  routes: [
    // Main app with bottom nav
    ShellRoute(
      builder: (context, state, child) => OperatorShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/bookings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookingListScreen(),
          ),
        ),
        GoRoute(
          path: '/alerts',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AlertsScreen(),
          ),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LiveMapScreen(),
          ),
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MoreScreen(),
          ),
        ),
      ],
    ),

    // Standalone screens
    GoRoute(
      path: '/booking-detail',
      builder: (context, state) => const BookingDetailScreen(),
    ),
    GoRoute(
      path: '/create-booking',
      builder: (context, state) => const CreateBookingScreen(),
    ),
    GoRoute(
      path: '/drivers',
      builder: (context, state) => const DriverListScreen(),
    ),
    GoRoute(
      path: '/send-message',
      builder: (context, state) => const SendMessageScreen(),
    ),
  ],
);

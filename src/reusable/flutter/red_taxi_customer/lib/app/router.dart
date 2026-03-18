import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/tenant_select_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/tracking/trip_complete_screen.dart';
import '../screens/history/booking_history_screen.dart';
import '../screens/history/trip_detail_screen.dart';
import '../screens/places/saved_places_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'shell_screen.dart';

final customerRouter = GoRouter(
  initialLocation: '/tenant-select',
  routes: [
    // Auth flow
    GoRoute(
      path: '/tenant-select',
      builder: (context, state) => const TenantSelectScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),

    // Main app with bottom nav
    ShellRoute(
      builder: (context, state, child) => CustomerShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/activity',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookingHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),

    // Standalone screens (no bottom nav)
    GoRoute(
      path: '/booking',
      builder: (context, state) => const BookingScreen(),
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (context, state) => const BookingConfirmationScreen(),
    ),
    GoRoute(
      path: '/tracking',
      builder: (context, state) => const TrackingScreen(),
    ),
    GoRoute(
      path: '/trip-complete',
      builder: (context, state) => const TripCompleteScreen(),
    ),
    GoRoute(
      path: '/trip-detail',
      builder: (context, state) => const TripDetailScreen(),
    ),
    GoRoute(
      path: '/saved-places',
      builder: (context, state) => const SavedPlacesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

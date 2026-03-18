import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/booking_detail_screen.dart';
import '../screens/offers/offers_list_screen.dart';
import '../screens/active/active_job_screen.dart';
import '../screens/active/complete_job_screen.dart';
import '../screens/availability/availability_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/statements/statements_screen.dart';
import '../screens/documents/documents_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/rank/create_booking_screen.dart';
import 'shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final auth = authProvider;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/splash';

      if (auth.status == AuthStatus.unknown) {
        return '/splash';
      }
      if (auth.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/login';
      }
      if (auth.status == AuthStatus.authenticated && isAuthRoute) {
        return '/schedule';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => ShellScreen(child: child),
        routes: [
          // Tab 1: Schedule
          GoRoute(
            path: '/schedule',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: ScheduleScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, state) => BookingDetailScreen(
                  bookingId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),

          // Tab 2: Offers
          GoRoute(
            path: '/offers',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: OffersListScreen(),
            ),
          ),

          // Tab 3: Active
          GoRoute(
            path: '/active',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: ActiveJobScreen(),
            ),
            routes: [
              GoRoute(
                path: 'complete',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const CompleteJobScreen(),
              ),
            ],
          ),

          // Tab 4: Availability
          GoRoute(
            path: '/availability',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: AvailabilityScreen(),
            ),
          ),

          // Tab 5: More
          GoRoute(
            path: '/more',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: MoreScreen(),
            ),
            routes: [
              GoRoute(
                path: 'earnings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const EarningsScreen(),
              ),
              GoRoute(
                path: 'statements',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const StatementsScreen(),
              ),
              GoRoute(
                path: 'documents',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const DocumentsScreen(),
              ),
              GoRoute(
                path: 'expenses',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const ExpensesScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const AddExpenseScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'profile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'messages',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const MessagesScreen(),
              ),
              GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'create-booking',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (_, __) => const CreateBookingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

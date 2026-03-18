import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/shift_provider.dart';
import 'router.dart';

/// Root widget for the Red Taxi Driver app.
class RedTaxiDriverApp extends StatelessWidget {
  const RedTaxiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthState()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
      ],
      child: _AppWithRouter(),
    );
  }
}

class _AppWithRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final router = buildRouter(authProvider);

    return MaterialApp.router(
      title: 'Red Taxi Driver',
      debugShowCheckedModeBanner: false,
      theme: RedTaxiTheme.dark(),
      routerConfig: router,
    );
  }
}

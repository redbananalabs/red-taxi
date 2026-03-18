import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../providers/customer_auth_provider.dart';
import '../providers/booking_provider.dart';
import 'router.dart';

/// Root widget for the Red Taxi Customer App.
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerAuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp.router(
        title: 'Red Taxi',
        debugShowCheckedModeBanner: false,
        theme: RedTaxiTheme.dark(),
        routerConfig: customerRouter,
      ),
    );
  }
}

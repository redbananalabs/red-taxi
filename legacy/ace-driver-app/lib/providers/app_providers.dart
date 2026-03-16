import 'package:ace_taxis/providers/booking_log_provider.dart';
import 'package:ace_taxis/providers/complete_job_provider.dart';
import 'package:ace_taxis/providers/create_booking_provider.dart';
import 'package:ace_taxis/providers/document_provider.dart';
import 'package:ace_taxis/providers/earning_providers.dart';
import 'package:ace_taxis/providers/expense_provider.dart';
import 'package:ace_taxis/providers/statement_provider.dart';
import 'package:ace_taxis/providers/availability_provider.dart';
import 'package:ace_taxis/providers/view_expense_provider.dart';
import 'package:ace_taxis/repositories/availability_repository.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/repositories/complete_job_repository.dart';
import 'package:ace_taxis/repositories/count_booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'profile_provider.dart';
import 'booking_provider.dart';
import 'dash_total_provider.dart';

class AppProviders {
  static MultiProvider init({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => DashTotalProvider()),
        ChangeNotifierProvider(create: (_) => EarningProvider()),
        ChangeNotifierProvider(create: (_) => StatementProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => CountBookingProvider()),
        ChangeNotifierProvider(
          create: (_) => CompleteJobProvider(
            CompleteJobRepository(), // repo instance
          ),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              AvailabilityProvider(repository: AvailabilityRepository()),
        ),

        /// ✅ Add ExpenseProvider
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),

        ChangeNotifierProvider(create: (_) => ViewExpenseProvider()),

        ChangeNotifierProvider(create: (_) => CreateBookingProvider()),
        ChangeNotifierProvider(create: (_) => BookingLogProvider()),
      ],
      child: child,
    );
  }
}

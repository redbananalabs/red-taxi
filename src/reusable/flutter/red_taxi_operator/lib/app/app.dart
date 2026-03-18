import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../providers/operator_auth_provider.dart';
import 'router.dart';

/// Root widget for the Red Taxi Operator App.
class OperatorApp extends StatelessWidget {
  const OperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OperatorAuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'Red Taxi Operator',
        debugShowCheckedModeBanner: false,
        theme: RedTaxiTheme.dark(),
        routerConfig: operatorRouter,
      ),
    );
  }
}

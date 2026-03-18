import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedTaxiOperatorApp());
}

class RedTaxiOperatorApp extends StatelessWidget {
  const RedTaxiOperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Taxi — Operator',
      debugShowCheckedModeBanner: false,
      theme: RedTaxiTheme.dark(),
      home: const OperatorHomePage(),
    );
  }
}

class OperatorHomePage extends StatelessWidget {
  const OperatorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Taxi Operator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Alerts',
            onPressed: () {
              // TODO: navigate to alerts via go_router
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              // TODO: navigate to profile via go_router
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 72,
              color: RedTaxiColors.brandRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Operator Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: RedTaxiColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fleet overview and dispatch management.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: RedTaxiColors.textSecondary),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigate to live map via go_router
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Live Map'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigate to bookings list via go_router
                  },
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('Bookings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

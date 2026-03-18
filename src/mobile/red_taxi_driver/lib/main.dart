import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedTaxiDriverApp());
}

class RedTaxiDriverApp extends StatelessWidget {
  const RedTaxiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Taxi — Driver',
      debugShowCheckedModeBanner: false,
      theme: RedTaxiTheme.dark(),
      home: const DriverHomePage(),
    );
  }
}

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Taxi Driver'),
        actions: [
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
              Icons.local_taxi,
              size: 72,
              color: RedTaxiColors.brandRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Driver App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: RedTaxiColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking queue will appear here.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: RedTaxiColors.textSecondary),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: toggle online/offline status
              },
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Go Online'),
            ),
          ],
        ),
      ),
    );
  }
}

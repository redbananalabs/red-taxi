import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedTaxiCustomerApp());
}

class RedTaxiCustomerApp extends StatelessWidget {
  const RedTaxiCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Taxi',
      debugShowCheckedModeBanner: false,
      theme: RedTaxiTheme.dark(),
      home: const CustomerHomePage(),
    );
  }
}

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Taxi'),
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
              'Where to?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: RedTaxiColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book a taxi in seconds.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: RedTaxiColors.textSecondary),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: navigate to booking flow via go_router
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Book a Ride'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/auth_provider.dart';

/// Splash / loading screen shown on app start while checking auth state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthState();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              listenable: _pulse,
              builder: (context, _) {
                return Opacity(
                  opacity: 0.5 + (_pulse.value * 0.5),
                  child: Icon(
                    Icons.local_taxi_rounded,
                    size: 96,
                    color: RedTaxiColors.brandRed,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'RED TAXI',
              style: TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'DRIVER',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: RedTaxiColors.brandRed,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });
  @override
  Widget build(BuildContext context) => builder(context, child);
}

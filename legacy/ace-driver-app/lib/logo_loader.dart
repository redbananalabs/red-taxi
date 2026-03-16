import 'dart:math';
import 'package:flutter/material.dart';

class LogoLoader extends StatefulWidget {
  final double size;
  const LogoLoader({super.key, this.size = 80});

  @override
  State<LogoLoader> createState() => _LogoLoaderState();
}

class _LogoLoaderState extends State<LogoLoader>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // 🔁 Continuous rotation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 💫 Glow pulse effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.7,
      upperBound: 1.2,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotateController, _glowController]),
        builder: (context, child) {
          final glowScale = _glowController.value;
          final rotation = _rotateController.value * 2 * pi;

          return Transform.scale(
            scale: glowScale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCD1A21)
                        .withOpacity(0.4 * glowScale),
                    blurRadius: 15 * glowScale,
                    spreadRadius: 5 * glowScale,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: rotation,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg', // your logo image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Circular countdown timer widget for job offer screens.
///
/// Displays a ring that depletes over [totalSeconds], showing the
/// remaining time in the centre. Calls [onComplete] when finished.
class CountdownRing extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onComplete;
  final double size;
  final double strokeWidth;

  const CountdownRing({
    super.key,
    required this.totalSeconds,
    this.onComplete,
    this.size = 180,
    this.strokeWidth = 8,
  });

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.totalSeconds),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining =
            (widget.totalSeconds * (1.0 - _controller.value)).ceil();
        final progress = 1.0 - _controller.value;

        // Colour shifts from green -> yellow -> red as time depletes
        Color ringColor;
        if (progress > 0.5) {
          ringColor = RedTaxiColors.success;
        } else if (progress > 0.2) {
          ringColor = RedTaxiColors.warning;
        } else {
          ringColor = RedTaxiColors.error;
        }

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: RedTaxiColors.backgroundCard,
                ),
              ),
              // Animated ring
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: progress,
                    color: ringColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
              ),
              // Time text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$remaining',
                    style: TextStyle(
                      color: ringColor,
                      fontSize: widget.size * 0.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'seconds',
                    style: TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: widget.size * 0.08,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated builder that is safe to use instead of AnimatedBuilder.
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

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-pi/2) clockwise
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = strokeWidth + 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

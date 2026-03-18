import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Large, prominent button used for job status progression.
///
/// Displays a label and optional subtitle. Background colour changes
/// based on the current phase of the active job.
class StatusButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const StatusButton({
    super.key,
    required this.label,
    this.subtitle,
    this.color = RedTaxiColors.brandRed,
    this.icon = Icons.arrow_forward_rounded,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

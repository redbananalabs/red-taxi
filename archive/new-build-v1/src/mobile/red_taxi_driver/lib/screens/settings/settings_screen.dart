import 'package:flutter/material.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// App settings screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoAcceptEnabled = false;
  double _gpsInterval = 8; // seconds
  bool _keepScreenOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RedTaxiColors.backgroundBase,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'NOTIFICATIONS'),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.notifications_outlined,
            label: 'Push Notifications',
            value: _notificationsEnabled,
            onChanged: (v) =>
                setState(() => _notificationsEnabled = v),
          ),
          _ToggleTile(
            icon: Icons.volume_up_outlined,
            label: 'Sound',
            subtitle: 'Play sound for new offers',
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ),
          _ToggleTile(
            icon: Icons.vibration_rounded,
            label: 'Vibration',
            value: _vibrationEnabled,
            onChanged: (v) =>
                setState(() => _vibrationEnabled = v),
          ),
          const SizedBox(height: 20),

          _SectionHeader(title: 'JOB SETTINGS'),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.flash_auto_rounded,
            label: 'Auto-Accept Jobs',
            subtitle: 'Automatically accept incoming offers',
            value: _autoAcceptEnabled,
            onChanged: (v) =>
                setState(() => _autoAcceptEnabled = v),
          ),
          const SizedBox(height: 20),

          _SectionHeader(title: 'GPS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded,
                        size: 20, color: RedTaxiColors.textSecondary),
                    const SizedBox(width: 12),
                    const Text('GPS Update Interval',
                        style: TextStyle(
                            color: RedTaxiColors.textPrimary, fontSize: 14)),
                    const Spacer(),
                    Text('${_gpsInterval.round()}s',
                        style: const TextStyle(
                            color: RedTaxiColors.brandRed,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Slider(
                  value: _gpsInterval,
                  min: 3,
                  max: 15,
                  divisions: 12,
                  activeColor: RedTaxiColors.brandRed,
                  inactiveColor: RedTaxiColors.backgroundSurface,
                  onChanged: (v) => setState(() => _gpsInterval = v),
                ),
                const Text(
                  'Lower interval = more accurate but higher battery usage',
                  style: TextStyle(
                      color: RedTaxiColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _SectionHeader(title: 'DISPLAY'),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.screen_lock_portrait_outlined,
            label: 'Keep Screen On',
            subtitle: 'Prevent screen from sleeping while online',
            value: _keepScreenOn,
            onChanged: (v) =>
                setState(() => _keepScreenOn = v),
          ),
          const SizedBox(height: 20),

          _SectionHeader(title: 'ABOUT'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _InfoRow(label: 'Version', value: '1.0.0'),
                SizedBox(height: 8),
                _InfoRow(label: 'Build', value: '2026.03.18.1'),
                SizedBox(height: 8),
                _InfoRow(label: 'Driver ID', value: 'DRV-001'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: RedTaxiColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: RedTaxiColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: RedTaxiColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: RedTaxiColors.textPrimary, fontSize: 14)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: RedTaxiColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: RedTaxiColors.brandRed,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: RedTaxiColors.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: RedTaxiColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

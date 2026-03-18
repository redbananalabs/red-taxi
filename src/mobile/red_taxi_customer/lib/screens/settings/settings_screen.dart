import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Settings screen: notifications, language, help.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          _SectionHeader('Notifications'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (v) =>
                      setState(() => _pushNotifications = v),
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.email_outlined,
                  label: 'Email Notifications',
                  value: _emailNotifications,
                  onChanged: (v) =>
                      setState(() => _emailNotifications = v),
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.sms_outlined,
                  label: 'SMS Notifications',
                  value: _smsNotifications,
                  onChanged: (v) =>
                      setState(() => _smsNotifications = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language section
          _SectionHeader('Language'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.language,
                  color: RedTaxiColors.textSecondary, size: 22),
              title: const Text(
                'App Language',
                style: TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _language,
                    style: const TextStyle(
                      color: RedTaxiColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: RedTaxiColors.textSecondary, size: 20),
                ],
              ),
              onTap: () => _showLanguagePicker(),
            ),
          ),
          const SizedBox(height: 24),

          // Help section
          _SectionHeader('Help & Support'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Help Centre',
                  onTap: () {},
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Support',
                  onTap: () {},
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () {},
                ),
                const Divider(
                    color: Color(0xFF2A2D3A), height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App version
          const Center(
            child: Text(
              'Red Taxi v1.0.0',
              style: TextStyle(
                color: RedTaxiColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = ['English', 'Irish', 'Polish', 'French', 'Spanish'];

    showModalBottomSheet(
      context: context,
      backgroundColor: RedTaxiColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    color: RedTaxiColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...languages.map((lang) => ListTile(
                    title: Text(
                      lang,
                      style: const TextStyle(color: RedTaxiColors.textPrimary),
                    ),
                    trailing: lang == _language
                        ? const Icon(Icons.check, color: RedTaxiColors.brandRed)
                        : null,
                    onTap: () {
                      setState(() => _language = lang);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RedTaxiColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: RedTaxiColors.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: RedTaxiColors.textPrimary,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: RedTaxiColors.brandRed,
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: RedTaxiColors.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: RedTaxiColors.textPrimary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: RedTaxiColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}

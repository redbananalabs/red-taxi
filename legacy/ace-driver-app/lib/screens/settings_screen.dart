// import 'package:ace_taxis/helpers/theme_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../helpers/shared_pref_helper.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _lightMode = true;
//   bool _pushNotifications = true;
//   bool _gps = true;
//   bool _sms = false;
//   bool _screenOn = true;

//   String _userName = "";
//   String _userId = "";

//   final String _kLightMode = "light_mode";

//   @override
//   void initState() {
//     super.initState();
//     _loadUserDetails();
//     _loadTheme();
//   }

//   Future<void> _loadUserDetails() async {
//     final user = await SharedPrefHelper.getUser();
//     if (user != null) {
//       setState(() {
//         _userName = user["fullName"] ?? "User";
//         _userId = user["id"]?.toString() ?? "No ID";
//       });
//     }
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _lightMode = prefs.getBool(_kLightMode) ?? true;
//     });
//   }

//   Future<void> _onLightModeChanged(bool val) async {
//     setState(() => _lightMode = val);
//     if (val) {
//       await ThemeController.setLightMode();
//     } else {
//       await ThemeController.setDarkMode();
//     }
//   }

//   Widget _buildToggle(
//     String label,
//     bool value,
//     Function(bool) onChanged,
//     IconData icon,
//   ) {
//     return SwitchListTile(
//       title: Text(label),
//       value: value,
//       onChanged: onChanged,
//       activeColor: Theme.of(context).colorScheme.primary,
//       secondary: Icon(icon),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // User info
//           Card(
//             child: ListTile(
//               leading: const CircleAvatar(child: Icon(Icons.person)),
//               title: Text(_userName.isNotEmpty ? _userName : "Loading..."),
//               subtitle: Text("ID: $_userId"),
//             ),
//           ),
//           const SizedBox(height: 24),

//           _buildToggle(
//             "Light Mode",
//             _lightMode,
//             _onLightModeChanged,
//             Icons.light_mode,
//           ),
//           _buildToggle(
//             "Push Notifications",
//             _pushNotifications,
//             (v) {},
//             Icons.notifications,
//           ),
//           _buildToggle("GPS", _gps, (v) {}, Icons.gps_fixed),
//           _buildToggle("SMS", _sms, (v) {}, Icons.sms),
//           _buildToggle(
//             "Screen On/Off",
//             _screenOn,
//             (v) {},
//             Icons.screen_lock_rotation,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:ace_taxis/helpers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/shared_pref_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lightMode = true;
  bool _pushNotifications = true;
  bool _gps = true;
  bool _sms = false;
  bool _screenOn = true;

  String _userName = "";
  String _userId = "";

  final String _kLightMode = "light_mode";

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadTheme();
  }

  Future<void> _loadUserDetails() async {
    final user = await SharedPrefHelper.getUser();
    if (user != null) {
      setState(() {
        _userName = user["fullName"] ?? "User";
        _userId = user["id"]?.toString() ?? "No ID";
      });
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lightMode = prefs.getBool(_kLightMode) ?? true;
    });
  }

  Future<void> _onLightModeChanged(bool val) async {
    setState(() => _lightMode = val);
    if (val) {
      await ThemeController.setLightMode();
    } else {
      await ThemeController.setDarkMode();
    }
  }

  Widget _buildToggle(
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      secondary: Icon(icon, color: theme.colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info
          Card(
            color: theme.colorScheme.surface,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                _userName.isNotEmpty ? _userName : "Loading...",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              subtitle: Text(
                "ID: $_userId",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildToggle(
            "Light Mode",
            _lightMode,
            _onLightModeChanged,
            Icons.light_mode,
          ),
          _buildToggle(
            "Push Notifications",
            _pushNotifications,
            (v) {},
            Icons.notifications,
          ),
          _buildToggle("GPS", _gps, (v) {}, Icons.gps_fixed),
          _buildToggle("SMS", _sms, (v) {}, Icons.sms),
          _buildToggle(
            "Screen On/Off",
            _screenOn,
            (v) {},
            Icons.screen_lock_rotation,
          ),
        ],
      ),
    );
  }
}

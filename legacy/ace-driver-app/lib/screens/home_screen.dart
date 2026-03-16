// import 'package:ace_taxis/helpers/gps_logs_key.dart';
// import 'package:ace_taxis/screens/live_gps_logs_screen.dart';
// import 'package:ace_taxis/screens/messages_screen.dart';
// import 'package:ace_taxis/screens/report_screen.dart';
// import 'package:ace_taxis/screens/login_screen.dart';
// import 'package:ace_taxis/screens/scheduler_screen.dart';
// import 'package:ace_taxis/screens/add_expense_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:provider/provider.dart';
// import '../providers/booking_provider.dart';
// import '../helpers/shared_pref_helper.dart';
// import '../helpers/firebase_helper.dart';
// import 'dashboard_screen.dart';
// import 'booking_screen.dart';
// import 'availability_screen.dart';
// import 'profile_screen.dart';
// import 'settings_screen.dart';
// import 'create_booking_screen.dart';

// class HomeScreen extends StatefulWidget {
//   final int initialIndex;
//   const HomeScreen({super.key, this.initialIndex = 0});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late int _pageIndex;
//   String? userName;
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _pageIndex = widget.initialIndex;
//     _loadUserInfo();

//     // ✅ Run Firebase + fetch active job when the app starts
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // Initialize Firebase (push notifications etc)
//       FirebaseHelper().initFirebase(context);

//       // Fetch active job on app start from your backend
//       final bookingProvider = Provider.of<BookingProvider>(
//         context,
//         listen: false,
//       );
//       await bookingProvider.fetchActiveJob();
//     });
//   }

//   Future<void> _loadUserInfo() async {
//     final user = await SharedPrefHelper.getUser();
//     if (user != null) {
//       setState(() {
//         userName = user['fullName'];
//         userId = user['userId']?.toString();
//       });
//     }
//   }

//   List<Widget> get _pages => [
//     const DashboardScreen(),
//     const BookingScreen(),
//     const AvailabilityScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _pageIndex == 0
//           ? AppBar(
//               backgroundColor: const Color(0xFFCD1A21),
//               elevation: 4,
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(
//                   bottom: Radius.circular(20),
//                 ),
//               ),
//               title: const Text(
//                 "Dashboard",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               iconTheme: const IconThemeData(color: Colors.white),
//             )
//           : null,
//       drawer: _pageIndex == 0 ? _buildDrawer(context) : null,
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 500),
//         child: _pages[_pageIndex],
//       ),
//       bottomNavigationBar: CurvedNavigationBar(
//         backgroundColor: Colors.white,
//         color: const Color(0xFFCD1A21),
//         buttonBackgroundColor: const Color(0xFFCD1A21),
//         height: 60,
//         index: _pageIndex,
//         animationDuration: const Duration(milliseconds: 400),
//         items: const [
//           Icon(Icons.home, size: 28, color: Colors.white),
//           Icon(Icons.directions_car, size: 28, color: Colors.white),
//           Icon(Icons.access_time, size: 28, color: Colors.white),
//           Icon(Icons.person, size: 28, color: Colors.white),
//         ],
//         onTap: (i) => setState(() => _pageIndex = i),
//       ),
//     );
//   }

//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           if (userName != null && userId != null)
//             UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(color: Color(0xFFCD1A21)),
//               accountName: Text(
//                 userName!,
//                 style: const TextStyle(fontSize: 18),
//               ),
//               accountEmail: Text("ID: $userId"),
//               currentAccountPicture: const CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.person, size: 40, color: Color(0xFFCD1A21)),
//               ),
//             )
//           else
//             const SizedBox(
//               height: 100,
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           Expanded(
//             child: ListView(
//               children: [
//                 ListTile(
//                   leading: const Padding(
//                     padding: EdgeInsets.only(top: 4.0),
//                     child: Text(
//                       "£",
//                       style: TextStyle(
//                         color: Color(0xFFCD1A21),
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   title: const Text("Add Expense"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AddExpensePage(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.report, color: Color(0xFFCD1A21)),
//                   title: const Text("Reports"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ReportScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.schedule, color: Color(0xFFCD1A21)),
//                   title: const Text("Scheduler"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SchedulerScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.settings, color: Color(0xFFCD1A21)),
//                   title: const Text("Settings"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SettingsScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(
//                     Icons.local_taxi,
//                     color: Color(0xFFCD1A21),
//                   ),
//                   title: const Text("Rank Pickup"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const CreateBookingScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 ListTile(
//                   leading: const Icon(Icons.message, color: Color(0xFFCD1A21)),
//                   title: const Text("Message Screen"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => MessagesScreen()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(
//                     Icons.gps_fixed,
//                     color: Color(0xFFCD1A21),
//                   ),
//                   title: const Text("Log Screen"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             LiveGpsLogsScreen(key: gpsLogsScreenKey),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Color(0xFFCD1A21)),
//             title: const Text("Logout"),
//             onTap: () async {
//               await SharedPrefHelper.clearUser();
//               Navigator.pop(context);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:ace_taxis/screens/booking_log_screen.dart';
import 'package:ace_taxis/screens/live_gps_logs_screen.dart';
import 'package:ace_taxis/screens/messages_screen.dart';
import 'package:ace_taxis/screens/report_screen.dart';
import 'package:ace_taxis/screens/login_screen.dart';
import 'package:ace_taxis/screens/scheduler_screen.dart';
import 'package:ace_taxis/screens/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../helpers/shared_pref_helper.dart';
import '../helpers/firebase_helper.dart';
import 'dashboard_screen.dart';
import 'booking_screen.dart';
import 'availability_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'create_booking_screen.dart';
import 'package:package_info_plus/package_info_plus.dart'; // NEW

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _pageIndex;
  String? userName;
  String? userId;
  String appVersion = ""; // NEW

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _loadUserInfo();
    _loadAppVersion(); // NEW

    // Hide bottom system bar fully
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirebaseHelper().initFirebase(context);

      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      await bookingProvider.fetchActiveJob();
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version; // e.g. 1.0.3
    });
  }

  Future<void> _loadUserInfo() async {
    final user = await SharedPrefHelper.getUser();
    if (user != null) {
      setState(() {
        userName = user['fullName'];
        userId = user['userId']?.toString();
      });
    }
  }

  List<Widget> get _pages => [
    const DashboardScreen(),
    const BookingScreen(),
    const AvailabilityScreen(),
    const SchedulerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // Make AppBar fully visible
      appBar: _pageIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFFCD1A21),
              elevation: 4,
              centerTitle: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              title: const Text(
                "Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,

      drawer: _pageIndex == 0 ? _buildDrawer(context) : null,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _pages[_pageIndex],
      ),

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xFFCD1A21),
        buttonBackgroundColor: const Color(0xFFCD1A21),
        height: 60,
        index: _pageIndex,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(Icons.home, size: 28, color: Colors.white),
          Icon(Icons.directions_car, size: 28, color: Colors.white),
          Icon(Icons.event_available, size: 28, color: Colors.white),
          Icon(Icons.schedule, size: 28, color: Colors.white),
        ],
        onTap: (i) => setState(() => _pageIndex = i),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          if (userName != null && userId != null)
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFCD1A21)),
              accountName: Text(
                userName!,
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text("ID: $userId"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFFCD1A21)),
              ),
            )
          else
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFFCD1A21)),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "£",
                      style: TextStyle(
                        color: Color(0xFFCD1A21),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: const Text("Add Expense"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpensePage()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.report, color: Color(0xFFCD1A21)),
                  title: const Text("Reports"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.schedule, color: Color(0xFFCD1A21)),
                  title: const Text("Scheduler"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SchedulerScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFFCD1A21)),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.local_taxi,
                    color: Color(0xFFCD1A21),
                  ),
                  title: const Text("Rank Pickup"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateBookingScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.message, color: Color(0xFFCD1A21)),
                  title: const Text("Message Screen"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MessagesScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.gps_fixed,
                    color: Color(0xFFCD1A21),
                  ),
                  title: const Text("Log Screen"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LiveGpsLogsScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.message, color: Color(0xFFCD1A21)),
                  title: const Text("Rank log Screen"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingLogScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          /// 🔹 LOGOUT + VERSION
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFCD1A21)),
            title: const Text("Logout"),
            trailing: Text(
              appVersion.isEmpty ? "" : "v$appVersion",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            onTap: () async {
              await SharedPrefHelper.clearUser();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

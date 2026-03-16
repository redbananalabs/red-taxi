
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'booking_screen.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});
  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  int _selectedIndex = 3;
  WebViewController? _controller;
  bool _isLoading = true;

  // final List<Widget> _screens = [
  //   const HomeScreen(initialIndex: 0),
  //   const BookingScreen(),
  //   const ProfileScreen(),
  //   const SchedulerScreen(),
  // ];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();

    final token = await SharedPrefHelper.getToken() ?? '';
    // final url = 'https://dev-ace-scheduler-driver.vercel.app/?token=$token';
    final url = 'https://ace-scheduler-driver.vercel.app/?token=$token';

    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // -------------------------
            // 1️⃣ HANDLE intent:// LINKS
            // -------------------------
            if (url.startsWith("intent://")) {
              try {
                final httpsUrl = url.replaceFirst("intent://", "https://");

                if (await canLaunchUrl(Uri.parse(httpsUrl))) {
                  await launchUrl(
                    Uri.parse(httpsUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              } catch (e) {
                debugPrint("Error opening intent link: $e");
              }
              return NavigationDecision.prevent;
            }

            // -------------------------------------------
            // 2️⃣ OPEN GOOGLE MAPS LINKS EXTERNALLY
            // -------------------------------------------
            if (url.contains("google.com/maps")) {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) =>
              debugPrint('WebView error: ${error.description}'),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = controller;
    });
  }

  // void _onItemTapped(int index) {
  //   if (index != _selectedIndex) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => _screens[index]),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        elevation: 4,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 0),
              ),
            );
          },
        ),
        title: const Text(
          "Scheduler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: isDark ? Colors.black : Colors.white,
              child: _controller != null
                  ? WebViewWidget(controller: _controller!)
                  : null,
            ),

            // Loading Indicator
            if (_isLoading || _controller == null)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFCD1A21)),
              ),
          ],
        ),
      ),

      // bottomNavigationBar: CurvedNavigationBar(
      //   backgroundColor: Colors.transparent,
      //   color: const Color(0xFFCD1A21),
      //   buttonBackgroundColor: const Color(0xFFCD1A21),
      //   height: 60,
      //   index: _selectedIndex,
      //   items: const [
      //     Icon(Icons.dashboard, color: Colors.white),
      //     Icon(Icons.local_taxi, color: Colors.white),
      //     Icon(Icons.person, color: Colors.white),
      //     Icon(Icons.schedule, color: Colors.white),
      //   ],
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

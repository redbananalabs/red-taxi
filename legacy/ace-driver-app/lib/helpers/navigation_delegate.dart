// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// NavigationDelegate(
//   onNavigationRequest: (request) async {
//     final url = request.url;

//     // Handle intent:// links
//     if (url.startsWith("intent://")) {
//       try {
//         // Extract actual https link from intent URL
//         final httpsUrl = url.replaceAll("intent://", "https://");

//         if (await canLaunchUrl(Uri.parse(httpsUrl))) {
//           await launchUrl(Uri.parse(httpsUrl), mode: LaunchMode.externalApplication);
//         }
//       } catch (e) {
//         debugPrint("Error opening intent link: $e");
//       }
//       return NavigationDecision.prevent;
//     }

//     // Handle Google Maps links (google.com/maps)
//     if (url.contains("google.com/maps")) {
//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//       }
//       return NavigationDecision.prevent;
//     }

//     return NavigationDecision.navigate;
//   },
//   onPageStarted: (_) => setState(() => _isLoading = true),
//   onPageFinished: (_) => setState(() => _isLoading = false),
//   onWebResourceError: (error) =>
//       debugPrint('WebView error: ${error.description}'),
// )

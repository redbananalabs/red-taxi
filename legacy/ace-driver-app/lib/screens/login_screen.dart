// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../helpers/snackbar_helper.dart';
// import 'home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _obscurePassword = true;
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkLoggedIn();
//   }

//   Future<void> _checkLoggedIn() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final loggedIn = await authProvider.isLoggedIn();
//     if (loggedIn) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 25),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   "assets/logo.jpg",
//                   height: 100,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Log In",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   "Hi! Welcome back, you’ve been missed",
//                   style: TextStyle(fontSize: 14, color: Colors.black54),
//                 ),
//                 const SizedBox(height: 30),
//                 TextField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(
//                     labelText: "Username",
//                     prefixIcon: const Icon(Icons.person_outline),
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFCD1A21),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     onPressed: authProvider.isLoading
//                         ? null
//                         : () async {
//                             final message = await authProvider.login(
//                                 _usernameController.text,
//                                 _passwordController.text);

//                             if (message == null) {
//                               SnackbarHelper.show(
//                                   context, "Login Successful",
//                                   color: Colors.red);
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (_) => const HomeScreen()),
//                               );
//                             } else {
//                               SnackbarHelper.show(context, message);
//                             }
//                           },
//                     child: authProvider.isLoading
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                           )
//                         : const Text(
//                             "Log In",
//                             style:
//                                 TextStyle(fontSize: 18, color: Colors.white),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/snackbar_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isProcessing = false; // Local flag to prevent multiple taps

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = await authProvider.isLoggedIn();
    if (loggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _performLogin() async {
    if (_isProcessing) return; // Prevent double tap

    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final message = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (message == null) {
      // Login Success → Immediately go to HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false, // Removes all previous routes (including LoginScreen)
      );

      // Show success message AFTER navigation (optional)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarHelper.show(
          context,
          "Login Successful!",
          color: Colors.green,
        );
      });
    } else {
      // Login Failed
      setState(() {
        _isProcessing = false;
      });
      SnackbarHelper.show(context, message, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.jpg",
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Hi! Welcome back, you’ve been missed",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // Username Field
                TextField(
                  controller: _usernameController,
                  enabled: !_isProcessing, // Disable while processing
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  enabled: !_isProcessing,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD1A21),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: (_isProcessing || authProvider.isLoading)
                        ? null
                        : _performLogin,
                    child: _isProcessing || authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Log In",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
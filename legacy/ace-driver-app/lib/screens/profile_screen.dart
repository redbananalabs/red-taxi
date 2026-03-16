// import 'package:ace_taxis/screens/view_expenses_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:provider/provider.dart';
// import '../models/profile.dart';
// import '../providers/profile_provider.dart';
// import 'document_screen.dart';
// import 'home_screen.dart';
// // TODO: create this screen or change with your screen
// // import 'expense_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _vehicleModelController = TextEditingController();
//   final _vehicleRegNoController = TextEditingController();
//   final _vehicleColorController = TextEditingController();

//   bool _isInitialLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     final provider = Provider.of<ProfileProvider>(context, listen: false);

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await provider.fetchProfile();
//       if (provider.profile != null) {
//         _setControllers(provider.profile!);
//       }
//       setState(() {
//         _isInitialLoading = false;
//       });
//     });
//   }

//   void _setControllers(Profile profile) {
//     _nameController.text = profile.fullName ?? "";
//     _phoneController.text = profile.phone ?? "";
//     _emailController.text = profile.email ?? "";
//     _vehicleModelController.text = profile.vehicleModel ?? "";
//     _vehicleRegNoController.text = profile.vehicleRegNo ?? "";
//     _vehicleColorController.text = profile.vehicleColor ?? "";
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _vehicleModelController.dispose();
//     _vehicleRegNoController.dispose();
//     _vehicleColorController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProfileProvider>(context);

//     if (_isInitialLoading || provider.isFetching) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const HomeScreen()),
//                 );
//               },
//             ),
//             const SizedBox(width: 4),
//             const Text(
//               "Driver Profile",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 24),
//             const CircleAvatar(
//               radius: 40,
//               backgroundColor: Color(0xFFCD1A21),
//               child: Icon(Icons.local_taxi, size: 40, color: Colors.white),
//             ),
//             const SizedBox(height: 24),

//             _buildLabel("Name"),
//             _buildTextField(_nameController, "Enter your name"),
//             const SizedBox(height: 16),

//             _buildLabel("Phone number"),
//             _buildTextField(
//               _phoneController,
//               "Enter your phone number",
//               keyboard: TextInputType.phone,
//             ),
//             const SizedBox(height: 16),

//             _buildLabel("Email Address"),
//             _buildTextField(
//               _emailController,
//               "xxxx@gmail.com",
//               keyboard: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),

//             _buildLabel("Vehicle Model"),
//             _buildTextField(_vehicleModelController, "Enter vehicle model"),
//             const SizedBox(height: 16),

//             _buildLabel("Vehicle Registration No."),
//             _buildTextField(
//               _vehicleRegNoController,
//               "Enter vehicle registration number",
//             ),
//             const SizedBox(height: 16),

//             _buildLabel("Vehicle Colour"),
//             _buildTextField(_vehicleColorController, "Enter vehicle colour"),
//             const SizedBox(height: 24),

//             // Upload Document
//             DottedBorder(
//               options: RoundedRectDottedBorderOptions(
//                 radius: const Radius.circular(6),
//                 dashPattern: const [6, 4],
//                 strokeWidth: 1.5,
//                 color: const Color(0xFFCD1A21),
//               ),
//               child: Material(
//                 color: const Color(0xFFCD1A21),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(6),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const DocumentScreen(),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(
//                           Icons.upload_file,
//                           color: Colors.white,
//                         ), // white icon
//                         SizedBox(width: 8),
//                         Text(
//                           "View / Upload Documents",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 28),

//             // ADD NEW BUTTON HERE
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const ViewExpensesScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFCD1A21),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 child: const Text(
//                   "View Expense",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _buildLabel(String text) => Align(
//     alignment: Alignment.centerLeft,
//     child: Text(
//       text,
//       style: const TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Colors.black,
//       ),
//     ),
//   );

//   static Widget _buildTextField(
//     TextEditingController controller,
//     String hint, {
//     TextInputType keyboard = TextInputType.text,
//   }) => TextField(
//     controller: controller,
//     keyboardType: keyboard,
//     readOnly: true,
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.grey),
//       filled: true,
//       fillColor: Colors.grey.shade200,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: BorderSide.none,
//       ),
//     ),
//   );
// }
import 'package:ace_taxis/screens/view_expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/profile_provider.dart';
import 'document_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleRegNoController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.fetchProfile();
      if (provider.profile != null) {
        _setControllers(provider.profile!);
      }
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    });
  }

  void _setControllers(Profile profile) {
    _nameController.text = profile.fullName ?? "";
    _phoneController.text = profile.phone ?? "";
    _emailController.text = profile.email ?? "";
    _vehicleModelController.text = profile.vehicleModel ?? "";
    _vehicleRegNoController.text = profile.vehicleRegNo ?? "";
    _vehicleColorController.text = profile.vehicleColor ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleModelController.dispose();
    _vehicleRegNoController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
            const Text(
              "Driver Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: _isInitialLoading || provider.isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.local_taxi,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildLabel(context, "Name"),
                  _buildTextField(context, _nameController),
                  const SizedBox(height: 16),

                  _buildLabel(context, "Phone number"),
                  _buildTextField(context, _phoneController),
                  const SizedBox(height: 16),

                  _buildLabel(context, "Email Address"),
                  _buildTextField(context, _emailController),
                  const SizedBox(height: 16),

                  _buildLabel(context, "Vehicle Model"),
                  _buildTextField(context, _vehicleModelController),
                  const SizedBox(height: 16),

                  _buildLabel(context, "Vehicle Registration No."),
                  _buildTextField(context, _vehicleRegNoController),
                  const SizedBox(height: 16),

                  _buildLabel(context, "Vehicle Colour"),
                  _buildTextField(context, _vehicleColorController),
                  const SizedBox(height: 24),

                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(6),
                      dashPattern: const [6, 4],
                      strokeWidth: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DocumentScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_file, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "View / Upload Documents",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewExpensesScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "View Expense",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      readOnly: true,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

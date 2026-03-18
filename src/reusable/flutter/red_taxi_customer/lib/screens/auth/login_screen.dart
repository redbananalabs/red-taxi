import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/customer_auth_provider.dart';

/// Phone number login screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<CustomerAuthProvider>();
    await auth.requestOtp(_phoneController.text.trim());

    if (mounted && auth.errorMessage == null) {
      context.go('/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<CustomerAuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Back button
                GestureDetector(
                  onTap: () => context.go('/tenant-select'),
                  child: const Icon(Icons.arrow_back,
                      color: RedTaxiColors.textPrimary),
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter your\nphone number',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: RedTaxiColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (auth.tenantName != null)
                  Text(
                    'Booking with ${auth.tenantName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RedTaxiColors.brandRed,
                        ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send you a verification code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: RedTaxiColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // Phone input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: RedTaxiColors.textPrimary,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '+353 xxx xxx xxxx',
                    hintStyle: const TextStyle(color: RedTaxiColors.textSecondary),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: RedTaxiColors.textSecondary),
                    filled: true,
                    fillColor: RedTaxiColors.backgroundCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: RedTaxiColors.brandRed),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 7) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.errorMessage!,
                    style: const TextStyle(color: RedTaxiColors.error),
                  ),
                ],
                const Spacer(),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: RedTaxiColors.textPrimary,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

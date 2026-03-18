import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/customer_auth_provider.dart';

/// 6-digit OTP verification screen.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpCode.length < 6) return;

    final auth = context.read<CustomerAuthProvider>();
    final success = await auth.verifyOtp(_otpCode);

    if (mounted && success) {
      context.go('/home');
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<CustomerAuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: const Icon(Icons.arrow_back,
                    color: RedTaxiColors.textPrimary),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify your\nphone number',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to ${auth.phoneNumber ?? 'your phone'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RedTaxiColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 40),
              // OTP digit fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      onChanged: (v) => _onDigitChanged(i, v),
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: RedTaxiColors.backgroundCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: RedTaxiColors.brandRed),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(color: RedTaxiColors.error),
                ),
              ],
              const SizedBox(height: 32),
              // Resend
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: resend OTP
                  },
                  child: const Text(
                    'Didn\'t receive a code? Resend',
                    style: TextStyle(color: RedTaxiColors.brandRed),
                  ),
                ),
              ),
              const Spacer(),
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _verify,
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
                          'Verify',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Poll every 5 seconds to check if email has been verified
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<AuthProvider>().checkVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.firebaseUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    color: AppColors.gold, size: 40),
              ),
              const SizedBox(height: 24),
              const Text('Verify your email',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n$email\n\nPlease check your inbox and click the link to continue.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => context.read<AuthProvider>().checkVerification(),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.navy, strokeWidth: 2))
                      : const Text("I've verified my email"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.read<AuthProvider>().resendVerification(),
                child: const Text('Resend verification email',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Sign out',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

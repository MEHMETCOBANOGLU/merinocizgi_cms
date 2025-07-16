// lib/features/auth/widgets/login_method_dialog.dart

import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class LoginMethodDialog extends StatelessWidget {
  final VoidCallback onEmailSelected;
  final VoidCallback onGoogleSelected;

  const LoginMethodDialog({
    super.key,
    required this.onEmailSelected,
    required this.onGoogleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Giriş Yap',
                style: AppTextStyles.heading.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              // 1. E-posta ile Giriş
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('E-posta ile Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onEmailSelected,
              ),
              const SizedBox(height: 12),
              // 2. Google ile Giriş
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                ),
                label: const Text('Google ile Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                onPressed: onGoogleSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

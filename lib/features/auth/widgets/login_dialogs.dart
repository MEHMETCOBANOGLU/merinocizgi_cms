// lib/features/home/widgets/login_dialogs.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';
import 'package:merinocizgi/features/auth/widgets/email_login_dialog.dart';

/// Giriş yöntemi seçim diyaloğu
class LoginSelectionDialog extends ConsumerWidget {
  const LoginSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller'ın durumunu izle (hataları göstermek için).
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red),
        );
      }
    });

    return AlertDialog(
      title: Center(
          child: Text(
        'Giriş Yap',
        style: AppTextStyles.title.copyWith(color: Colors.black),
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // E-posta ile Giriş/Kayıt Butonu
          ElevatedButton.icon(
            icon: const Icon(Icons.email),
            label: const Text('E‐posta ile Devam Et     ',
                textAlign: TextAlign.left),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () {
              Navigator.of(context).pop(); // Bu diyaloğu kapat
              showDialog(
                  context: context,
                  builder: (_) =>
                      const EmailLoginDialog(isLoginMode: true)); // Diğerini aç
            },
          ),
          const SizedBox(height: 12),
          // Google ile Giriş Butonu
          ElevatedButton.icon(
            icon: Image.asset(
              'assets/images/googleLogo.png',
              width: 18,
              height: 18,
            ), // Google ikonu eklenebilir
            label: const Text('Google ile Devam Et     ',
                textAlign: TextAlign.start),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () async {
              // Controller'daki metodu çağır.
              await ref
                  .read(authControllerProvider.notifier)
                  .signInWithGoogle();
            },
          ),
          const SizedBox(height: 12),
          //facebook ile devam et
          ElevatedButton.icon(
            icon:
                const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
            label:
                const Text('Facebook ile Devam Et', textAlign: TextAlign.start),
            style: ElevatedButton.styleFrom(
                // backgroundColor: const Color(0xFF1877F2), // Facebook mavisi
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () async {
              Navigator.of(context).pop(); // Bu diyaloğu kapat
              await ref
                  .read(authControllerProvider.notifier)
                  .signInWithFacebook();
            },
          ),
          const SizedBox(height: 20),

          Divider(color: Colors.grey.shade400),
          const SizedBox(height: 4),

          RichText(
            text: TextSpan(
              text: 'Hesabınız yok mu? ',
              style: const TextStyle(color: Colors.black38, fontSize: 14),
              children: [
                TextSpan(
                    text: 'Kayıt Ol',
                    style: const TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              const EmailLoginDialog(isLoginMode: false),
                        );
                      }),
              ],
            ),
          )
        ],
      ),
    );
  }
}

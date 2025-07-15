// lib/features/home/widgets/login_dialogs.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';
import 'package:merinocizgi/features/auth/widgets/email_login_dialog.dart';

/// Giriş yöntemi seçim diyaloğu
class LoginSelectionDialog extends ConsumerWidget {
  const LoginSelectionDialog({Key? key}) : super(key: key);

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
            label: const Text('E‐posta ile Giriş Yap'),
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
            label: const Text('Google ile Giriş Yap'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40)),
            onPressed: () async {
              // Controller'daki metodu çağır.
              await ref
                  .read(authControllerProvider.notifier)
                  .signInWithGoogle();
              // Başarılı olursa, AuthStateProvider bunu algılayıp UI'ı güncelleyecek.
              // Bu yüzden burada Navigator.pop() yapmaya gerek kalmayabilir,
              // veya işlemden sonra kapatılabilir. Şimdilik kapatalım.
              if (context.mounted) Navigator.of(context).pop();
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

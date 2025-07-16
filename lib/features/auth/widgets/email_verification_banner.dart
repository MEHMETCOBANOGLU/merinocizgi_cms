// lib/features/auth/widgets/email_verification_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merinocizgi/features/auth/controller/auth_providers.dart'; // bannerVisibilityProvider için

class EmailVerificationBanner extends ConsumerWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yeni banner görünürlük provider'ını izle.
    final isBannerVisible = ref.watch(bannerVisibilityProvider);

    // Banner'ın içeriği, mevcut kullanıcı bilgisine ihtiyaç duyar.
    final user = FirebaseAuth.instance.currentUser;

    // AnimatedSwitcher ile yumuşak bir giriş/çıkış animasyonu ekleyelim.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0, // Yukarıdan aşağı doğru açılsın
          child: child,
        );
      },
      child: isBannerVisible
          ? Material(
              key: const ValueKey('bannerVisible'), // Animasyon için anahtar
              color: Colors.amber,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.white),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Lütfen e-posta adresinizi doğrulayın.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        side: const BorderSide(color: Colors.white),
                      ),
                      // style:
                      // TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () async {
                        try {
                          // Kullanıcı null olabilir, kontrol ekleyelim.
                          await user?.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Doğrulama e-postası tekrar gönderildi.")),
                          );
                        } catch (e) {
                          // Hata yönetimi
                        }
                      },
                      child: const Text('Tekrar Gönder'),
                    ),
                  ],
                ),
              ),
            )
          // Eğer banner görünür değilse, boş bir SizedBox döndür.
          : const SizedBox.shrink(key: ValueKey('bannerHidden')),
    );
  }
}

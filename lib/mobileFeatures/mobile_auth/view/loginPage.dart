import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';

class MobileLoginPage extends ConsumerWidget {
  const MobileLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: ,
        title: Text(
          'Giriş Yap',
          style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.cancel,
              size: 30,
            ),
            onPressed: () {
              context.pop();
            },
          ),
        ],
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              color: Colors.white70,
              thickness: 1,
            )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 12, 30, 0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/merino.png', width: 180),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Text(
                  textAlign: TextAlign.center,
                  "Ücretsiz çizgi romanlar için şimdi giriş yap",
                  // "Hemen giriş yapın ve ücretsiz çizgi romanların keyfini çıkarın.",
                  style: GoogleFonts.oswald(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              // E-posta ile Giriş/Kayıt Butonu
              ElevatedButton.icon(
                icon: const Icon(Icons.email, size: 24),
                label: const Center(child: Text('E‐posta ile Devam Et')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 40),
                  alignment: Alignment.centerLeft,
                  side: const BorderSide(
                    color: Colors.white70,
                  ),
                ),
                onPressed: () {
                  context.push('/emailLogin');
                },
              ),
              const SizedBox(height: 12),
              // Google ile Giriş Butonu
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/googleLogo.png',
                  width: 22,
                ), // Google ikonu eklenebilir
                label: const Center(child: Text('Google ile Devam Et')),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.9, 40),
                  backgroundColor: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  side: const BorderSide(
                    color: Colors.white70,
                  ),
                ),
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
                icon: const Icon(Icons.facebook,
                    size: 28, color: Color(0xFF1877F2)),
                label: const Center(
                  child: Text(
                    'Facebook ile Devam Et',
                    textDirection: TextDirection.ltr,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    side: const BorderSide(
                      color: Colors.white70,
                    ),
                    minimumSize: const Size(double.infinity, 40)),
                onPressed: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .signInWithFacebook();
                },
              ),
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Merino Çizgi, ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    children: [
                      TextSpan(
                          text: 'çerez politikamıza',
                          style: const TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: 15,
                            color: Colors.blue,

                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // showDialog(
                              //   context: context,
                              //   builder: (_) =>
                              //       const EmailLoginDialog(isLoginMode: false),
                              // );
                            }),
                      const TextSpan(
                        text:
                            ' uygun olarak çerezler ve benzeri teknolojiler kullanmaktadır.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Koşullar', // kullanım koşulları
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '© Merino Çizgi',
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Gizlilik', // gizlilik politikası
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';

/// E-posta ile giriş/kayıt işlemlerini yapan diyalog
class EmailLoginPage extends ConsumerStatefulWidget {
  final bool isLoginMode;
  const EmailLoginPage({Key? key, required this.isLoginMode}) : super(key: key);

  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginDialogState();
}

class _EmailLoginDialogState extends ConsumerState<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _mahlasCtrl = TextEditingController();
  late bool isLoginMode;
  bool isPrivacyChecked = false;
  bool isTermsChecked = false;

  @override
  void initState() {
    super.initState();
    isLoginMode = widget.isLoginMode; // ✅ dışarıdan gelen değeri al
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _mahlasCtrl.dispose();
    super.dispose();
  }

  // Ana işlem fonksiyonu
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authControllerProvider.notifier);

    try {
      if (isLoginMode) {
        await authNotifier.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
      } else {
        await authNotifier.signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          mahlas: _mahlasCtrl.text.trim(),
        );
      }
      // Başarılı olunca diyaloğu kapat.
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Hata zaten AuthController tarafından yakalanıp SnackBar ile gösterilecek.
      // Bu yüzden burada tekrar bir şey yapmaya gerek yok.
    }
  }

  // Şifre sıfırlama fonksiyonu
  Future<void> _resetPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Lütfen şifresini sıfırlamak istediğiniz e-posta adresini girin.")));
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: _emailCtrl.text.trim());
      if (mounted) {
        Navigator.of(context).pop(); // Ana diyaloğu kapat
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Şifre sıfırlama linki e-postanıza gönderildi."),
            backgroundColor: Colors.blue));
      }
    } catch (e) {
      // Hata zaten SnackBar ile gösterilecek.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controller'ın durumunu izle (isLoading için)
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    // Hataları dinle ve SnackBar göster
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red),
        );
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            // automaticallyImplyLeading: false,
            ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/merino.png',
                width: 150,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isLoginMode = true),
                        child: Text(
                          'GİRİŞ YAP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLoginMode == true
                                ? AppColors.primary
                                : AppColors.accent,
                          ),
                        ),
                      ),
                      if (isLoginMode == true)
                        Container(
                          height: 3,
                          width: 60,
                          color: AppColors.primary,
                          margin: EdgeInsets.only(top: 4),
                        )
                    ],
                  ),
                  SizedBox(width: 40),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isLoginMode = false),
                        child: Text(
                          'ÜYE OL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLoginMode == false
                                ? AppColors.primary
                                : AppColors.accent,
                          ),
                        ),
                      ),
                      if (isLoginMode == false)
                        Container(
                          height: 3,
                          width: 60,
                          color: AppColors.primary,
                          margin: EdgeInsets.only(top: 4),
                        )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Sadece kayıt modunda görünecek alanlar
                    if (!isLoginMode) ...[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                            controller: _mahlasCtrl,
                            decoration: InputDecoration(
                              labelText: 'Mahlas (Kullanıcı Adı)',
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  )),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Mahlas gerekli' : null),
                      ),
                      const SizedBox(height: 30),
                    ],
                    // Her iki modda da görünecek alanlar
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                          controller: _emailCtrl,
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                )),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v!.isEmpty || !v.contains('@'))
                              ? 'Geçerli e-posta girin'
                              : null),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                          controller: _passwordCtrl,
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                )),
                          ),
                          obscureText: true,
                          validator: (v) => (v!.length < 6)
                              ? 'Şifre en az 6 karakter olmalı'
                              : null),
                    ),
                    if (isLoginMode)
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(right: 30),
                          ),
                          onPressed: isLoading ? null : _resetPassword,
                          child: const Text(
                            "Şifremi Unuttum",
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    if (!isLoginMode)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isPrivacyChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isPrivacyChecked = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                      text: TextSpan(
                                    text:
                                        'Kişisel Verilerin Korunmasına İlişkin Aydınlatma Metni',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.push('/privacy-policy');
                                      },
                                    children: const <TextSpan>[
                                      TextSpan(
                                        text: '\'ni okudum',
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isTermsChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isTermsChecked = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Üyelik Sözleşmesi',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.push('/terms-and-conditions');
                                        },
                                      children: const <TextSpan>[
                                        TextSpan(
                                          text: '\'ni okudum',
                                          style: TextStyle(
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLoginMode) const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (!isLoginMode)
                Center(
                  child: RichText(
                      text: TextSpan(
                    text: 'Zaten bir hesabınız var mı? ',
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                          text: 'Giriş Yap',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() => isLoginMode = true);
                            }),
                    ],
                  )),
                ),
            ],
          ),
        ),

        // Mod değiştirme butonu
        // TextButton(
        //   onPressed: isLoading
        //       ? null
        //       : () => setState(() => isLoginMode = !isLoginMode),
        //   child: Text(isLoginMode ? 'Kayıt Ol' : 'Giriş Yap'),
        // ),
      ),
    );
  }
}

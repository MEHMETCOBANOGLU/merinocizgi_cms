import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';

/// E-posta ile giriş/kayıt işlemlerini yapan diyalog
class EmailLoginDialog extends ConsumerStatefulWidget {
  final bool isLoginMode;
  const EmailLoginDialog({Key? key, required this.isLoginMode})
      : super(key: key);

  @override
  ConsumerState<EmailLoginDialog> createState() => _EmailLoginDialogState();
}

class _EmailLoginDialogState extends ConsumerState<EmailLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _mahlasCtrl = TextEditingController();

  late bool isLoginMode;

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

    return AlertDialog(
      title: Center(
        child: Text(
          isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
          style: AppTextStyles.title.copyWith(color: Colors.black),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Sadece kayıt modunda görünecek alanlar
              if (!isLoginMode) ...[
                const SizedBox(height: 16),
                TextFormField(
                    controller: _mahlasCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Mahlas (Yazar Adı)'),
                    validator: (v) => v!.isEmpty ? 'Mahlas gerekli' : null),
                const SizedBox(height: 16),
              ],
              // Her iki modda da görünecek alanlar
              TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v!.isEmpty || !v.contains('@'))
                      ? 'Geçerli e-posta girin'
                      : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator: (v) =>
                      (v!.length < 6) ? 'Şifre en az 6 karakter olmalı' : null),
            ],
          ),
        ),
      ),
      actions: [
        // Şifremi unuttum butonu (sadece giriş modunda)
        Column(
          children: [
            // Ana aksiyon butonu
            // if (isLoginMode)
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isLoginMode ? 'Giriş Yap' : 'Kayıt Ol'),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade400),
            if (isLoginMode)
              TextButton(
                onPressed: isLoading ? null : _resetPassword,
                child: const Text("Şifremi Unuttum",
                    style: TextStyle(color: Colors.black54)),
              ),
          ],
        ),
        if (!isLoginMode)
          Center(
            child: RichText(
                text: TextSpan(
              text: 'Zaten bir hesabınız var mı? ',
              style: const TextStyle(color: Colors.black38, fontSize: 14),
              children: [
                TextSpan(
                    text: 'Giriş Yap',
                    style: const TextStyle(
                      color: Colors.black54,
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

        // Mod değiştirme butonu
        // TextButton(
        //   onPressed: isLoading
        //       ? null
        //       : () => setState(() => isLoginMode = !isLoginMode),
        //   child: Text(isLoginMode ? 'Kayıt Ol' : 'Giriş Yap'),
        // ),
      ],
    );
  }
}

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
  late bool _isLoginMode;
  bool _isPrivacyChecked = false;
  bool _isTermsChecked = false;
  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.isLoginMode; // ✅ dışarıdan gelen değeri al
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _mahlasCtrl.dispose();
    super.dispose();
  }

  // --- ANA İŞLEM FONKSİYONLARI ---

  Future<void> _submit() async {
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();
    // Form geçerli değilse işlemi durdur
    if (!_formKey.currentState!.validate()) return;

    // Kayıt modundaysa ve sözleşmeler onaylanmamışsa uyar
    if (!_isLoginMode && (!_isPrivacyChecked || !_isTermsChecked)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Lütfen üyelik ve gizlilik sözleşmelerini onaylayın.')),
      );
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);

    try {
      if (_isLoginMode) {
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

      if (mounted) {
        final successMessage = _isLoginMode
            ? "Başarıyla giriş yapıldı!"
            : "Kayıt başarılı! Lütfen e-postanızı kontrol edin.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(successMessage), backgroundColor: Colors.green));
        // Başarılı işlem sonrası bir önceki sayfaya (veya ana sayfaya) yönlendir.
        context.go('/');
      }
    } catch (e) {
      // Hata zaten AuthController tarafından yakalanıp global listener ile gösterilecek.
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

  // --- YARDIMCI WIDGET OLUŞTURMA METOTLARI ---

  // Giriş Yap / Üye Ol sekmelerini oluşturan metot
  Widget _buildAuthTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab("GİRİŞ YAP", true),
        const SizedBox(width: 40),
        _buildTab("ÜYE OL", false),
      ],
    );
  }

  // Tek bir sekmeyi oluşturan metot
  Widget _buildTab(String title, bool isLoginTab) {
    final bool isActive = (_isLoginMode == isLoginTab);
    return GestureDetector(
      onTap: () => setState(() => _isLoginMode = isLoginTab),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primary : AppColors.accent,
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 60,
              color: AppColors.primary,
              margin: const EdgeInsets.only(top: 4),
            )
        ],
      ),
    );
  }

  // Kayıt modunda gösterilecek sözleşme checkbox'larını oluşturan metot
  Widget _buildAgreementChecks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          _buildCheckboxRow(
            value: _isPrivacyChecked,
            onChanged: (val) => setState(() => _isPrivacyChecked = val!),
            text: 'Kişisel Verilerin Korunmasına İlişkin Aydınlatma Metni',
            linkText: '\'ni okudum, anladım.',
            onLinkTap: () => context.go('/privacy-policy'),
          ),
          _buildCheckboxRow(
            value: _isTermsChecked,
            onChanged: (val) => setState(() => _isTermsChecked = val!),
            text: 'Üyelik Sözleşmesi',
            linkText: '\'ni okudum ve kabul ediyorum.',
            onLinkTap: () => context.go('/terms-and-conditions'),
          ),
        ],
      ),
    );
  }

  // Tek bir checkbox satırını oluşturan metot
  Widget _buildCheckboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2, // Varsayılan stil
              children: [
                TextSpan(
                  text: text,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      color: AppColors.primary),
                  recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                ),
                TextSpan(text: linkText, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red),
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/merino.png', width: 180),
                const SizedBox(height: 40),
                _buildAuthTabs(),
                const SizedBox(height: 40),
                if (!_isLoginMode) ...[
                  TextFormField(
                      controller: _mahlasCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Mahlas (Kullanıcı Adı)'),
                      validator: (v) => v!.isEmpty ? 'Mahlas gerekli' : null),
                  const SizedBox(height: 30),
                ],
                TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v!.isEmpty || !v.contains('@'))
                        ? 'Geçerli e-posta girin'
                        : null),
                const SizedBox(height: 30),
                TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    validator: (v) => (v!.length < 6)
                        ? 'Şifre en az 6 karakter olmalı'
                        : null),
                if (_isLoginMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: isLoading ? null : _resetPassword,
                        child: const Text("Şifremi Unuttum")),
                  ),
                const SizedBox(height: 16),
                if (!_isLoginMode) _buildAgreementChecks(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
                          style: GoogleFonts.oswald(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                const SizedBox(height: 16),
                // if (!_isLoginMode)
                // Center(
                //   child: RichText(
                //       text: TextSpan(
                //     text: 'Zaten bir hesabınız var mı? ',
                //     style: const TextStyle(fontSize: 14),
                //     children: [
                //       TextSpan(
                //           text: 'Giriş Yap',
                //           style: const TextStyle(
                //             decoration: TextDecoration.underline,
                //             fontSize: 15,
                //             fontWeight: FontWeight.bold,
                //           ),
                //           recognizer: TapGestureRecognizer()
                //             ..onTap = () {
                //               setState(() => _isLoginMode = true);
                //             }),
                //     ],
                //   )),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

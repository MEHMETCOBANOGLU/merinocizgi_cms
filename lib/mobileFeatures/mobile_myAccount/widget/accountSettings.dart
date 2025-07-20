import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart'; // showSignOutDialog için

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  static const Map<String, String> _legalLinks = {
    'Kullanım Koşulları': '/terms',
    'KVKK Aydınlatma Metni': '/kvkk',
    'Çerez Politikası': '/cookies',
    'Veri Silme Talimatları': '/delete-data',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          _SectionHeader('Hesap'),
          Consumer(builder: (context, ref, _) {
            final userProfile = ref.watch(currentUserProfileProvider);
            return userProfile.when(
              data: (data) => Column(
                children: [
                  _SettingsTile(
                    title: data?['mahlas'] ?? 'Mahlas Yükleniyor...',
                    subtitle: "Profilini düzenle",
                    icon: Icons.person_outline,
                    onTap: () => context
                        .go('/account'), // Profil düzenleme sayfasına git
                  ),
                  _SettingsTile(
                    title: data?['email'] ?? 'E-posta Yükleniyor...',
                    icon: Icons.email_outlined,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => _SettingsTile(
                  title: "Bilgiler yüklenemedi", icon: Icons.error),
            );
          }),

          _SectionHeader('Uygulama'),
          _SettingsTile(
              title: 'Bildirimler',
              icon: Icons.notifications_outlined,
              onTap: () {}),
          _SettingsTile(
            title: 'Çıkış Yap',
            icon: Icons.logout,
            onTap: () => _showSignOutConfirmationDialog(context, ref),
            textColor: Colors.red,
          ),

          _SectionHeader('Hakkımızda & Yasal'),
          // Linkleri haritadan (map) otomatik olarak oluştur
          ..._legalLinks.entries.map(
            (entry) => _SettingsTile(
              title: entry.key,
              onTap: () => context.go(entry.value),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- YARDIMCI WIDGET'LAR ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Tema ile uyumlu renk
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.grey[700]) : null,
        title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12))
            : null,
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// Bu fonksiyonu ayrı bir dialogs.dart dosyasına taşımak en iyisi
Future<void> _showSignOutConfirmationDialog(
    BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'Çıkış Yap',
          textAlign: TextAlign.center,
          style: AppTextStyles.title,
        ),
        content: const Text('Oturumu kapatmak istediğinize emin misiniz?'),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () async {
                // Önce diyaloğu kapat.
                Navigator.of(dialogContext).pop();

                // Sonra çıkış işlemini gerçekleştir.
                await FirebaseAuth.instance.signOut();
                ref.invalidate(authStateProvider); // auth provider'ı reset
                ref.invalidate(
                    selectedBottomBarIndexProvider); // bottom bar'ı sıfırla

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Başarıyla çıkış yapıldı.")),
                );
              },
              child: const Text('Çıkış Yap'))
        ],
      );
    },
  );
}

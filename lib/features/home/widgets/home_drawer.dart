// lib/features/home/widgets/home_drawer.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/features/auth/controller/auth_providers.dart';
import 'package:merinocizgi/features/auth/widgets/login_dialogs.dart';

// Drawer'ın artık state'i (auth durumu) okuması gerektiği için ConsumerWidget yapıyoruz.
class HomeDrawer extends ConsumerWidget {
  final GlobalKey merinoKey, comicsKey, artistsKey;
  final VoidCallback onPublish, onLogin;
  final void Function(GlobalKey) onNavTap;

  const HomeDrawer({
    super.key,
    required this.merinoKey,
    required this.comicsKey,
    required this.artistsKey,
    required this.onPublish,
    required this.onLogin,
    required this.onNavTap,
  });

  // HomeAppBar'dan kopyalanan özel buton widget'ları
  Widget _loginButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(label.toUpperCase(), style: AppTextStyles.title),
    );
  }

  Widget _publishButton(String label, VoidCallback? onTap) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label.toUpperCase(), style: AppTextStyles.title),
    );
  }

  // HomeAppBar'dan kopyalanan kullanıcı menüsü widget'ı
  Widget _userMenu(String displayName, BuildContext context, WidgetRef ref) {
    final bool isUserAdmin = ref.watch(isAdminProvider);
    final double screenW = MediaQuery.of(context).size.width;

    return PopupMenuButton<_UserMenuOptions>(
      tooltip: 'Menüyü göster',
      // 1) İkon ya da “displayName” gözüken buton olarak:
      offset: const Offset(0, 40),
      // color: Colors.grey.shade500,
      color: Colors.grey.shade600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      onSelected: (_UserMenuOptions choice) async {
        switch (choice) {
          case _UserMenuOptions.account:
            Navigator.pop(context);
            context.go('/account');

            break;
          case _UserMenuOptions.adminPanel:
            // context.go('/adminPanel');
            Navigator.pop(context);
            context.go('/admin');
            break;
          case _UserMenuOptions.logout:
            await _showSignOutConfirmationDialog(context, ref);
            // await FirebaseAuth.instance.signOut();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_UserMenuOptions>>[
        const PopupMenuItem<_UserMenuOptions>(
          value: _UserMenuOptions.account,
          child: Text('Hesabım', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuDivider(),
        if (isUserAdmin)
          const PopupMenuItem<_UserMenuOptions>(
            value: _UserMenuOptions.adminPanel,
            child: Text('Admin Panel', style: TextStyle(color: Colors.white)),
          ),
        if (isUserAdmin) const PopupMenuDivider(),
        const PopupMenuItem<_UserMenuOptions>(
          value: _UserMenuOptions.logout,
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      // 1) İkon ya da “displayName” gözüken buton olarak:
      child: Container(
        // Menü butonuna maksimum bir genişlik verelim.

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                displayName,
                style: AppTextStyles.title.copyWith(color: Colors.white),
                overflow: TextOverflow.fade, // Sığmazsa sonuna '...' koy

                softWrap: false, // Alt satıra kaymasını engelle
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth durumunu okuyarak UI'ı dinamik hale getiriyoruz.
    final authStateAsync = ref.watch(authStateProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Image.asset('assets/images/merino.png'),
          ),

          // --- YENİ EKLENEN ÜST BÖLÜM ---
          // 1) Kullanıcı oturum durumuna göre “YAYINLA” veya giriş dialog göster:
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2) Kullanıcı oturum durumuna göre “Giriş Yap” veya kullanıcı menüsü göster:
              authStateAsync.when(
                data: (authState) {
                  // authState artık AuthState nesnesi
                  // Senaryo 1: Kullanıcı giriş yapmamış.
                  if (authState.user == null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _loginButton('Giriş Yap', () {
                        showDialog(
                            context: context,
                            builder: (_) => const LoginSelectionDialog());
                      }),
                    );
                  }
                  // Senaryo 2: Kullanıcı giriş yapmış.
                  else {
                    // userProfileProvider'ı burada, giriş yapıldığından emin olduktan sonra izle.
                    final userProfileAsync =
                        ref.watch(currentUserProfileProvider);

                    return userProfileAsync.when(
                        data: (profileData) {
                          // Profil verisi null gelebilir (henüz oluşturulmamışsa).
                          // Null kontrolü yaparak daha güvenli hale getirelim.
                          final mahlas = profileData?['mahlas'] as String?;
                          final displayName =
                              (mahlas != null && mahlas.isNotEmpty)
                                  ? mahlas
                                  : authState.user!.displayName ??
                                      authState.user!.email?.split('@').first ??
                                      'Kullanıcı';

                          authState.user!.updateDisplayName(displayName);
                          authState.user!.reload();

                          return Flexible(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _userMenu(displayName, context, ref),
                          ));
                        },
                        // Profil yüklenirken gösterilecek.
                        loading: () => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                        // Profil alınırken hata olursa.
                        error: (err, _) {
                          // Hata durumunda bile kullanıcı adını e-postadan alıp menüyü gösterebiliriz.
                          final displayName =
                              authState.user!.email?.split('@').first ??
                                  'Kullanıcı';
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _userMenu(displayName, context, ref),
                          );
                        });
                  }
                },
                // Auth durumu yüklenirken gösterilecek.
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                // Auth durumunda hata olursa.
                error: (err, _) => Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _loginButton('Giriş Yap', () {
                    showDialog(
                        context: context,
                        builder: (_) => const LoginSelectionDialog());
                  }),
                ),
              ),

              authStateAsync.when(
                data: (authState) {
                  // --- Senaryo 1: Kullanıcı giriş yapmamış ---
                  if (authState.user == null) {
                    // Kullanıcıya giriş yapması için diyalog göster.
                    return _publishButton('YAYINLA', () {
                      showDialog(
                        context: context,
                        builder: (_) => const LoginSelectionDialog(),
                      ).then((_) {
                        // Diyalog kapandıktan sonra, eğer giriş yapıldıysa yayınla sayfasına git.
                        if (FirebaseAuth.instance.currentUser != null) {
                          onPublish();
                        }
                      });
                    });
                  }

                  // --- Senaryo 2: Kullanıcı giriş yapmış ---
                  else {
                    // Butona her basıldığında çalışacak olan ASENKRON fonksiyon.
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _publishButton('YAYINLA', () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return; // Güvenlik kontrolü

                        // 1. Firebase'den en güncel durumu çek.
                        await user.reload();

                        // 2. Yenilenmiş kullanıcı durumunu al.
                        final isNowVerified =
                            FirebaseAuth.instance.currentUser?.emailVerified ??
                                false;

                        // 3. Duruma göre davran.
                        if (isNowVerified) {
                          // Artık DOĞRULANMIŞ: Yayınla sayfasına git.
                          onPublish();
                        } else {
                          // Hala DOĞRULANMAMIŞ: Geçici uyarı banner'ını göster.
                          ref.read(bannerVisibilityProvider.notifier).show();
                        }
                      }),
                    );
                  }
                },
                loading: () {
                  // Yüklenirken basit bir bekleme göstergesi.
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  );
                },
                error: (_, __) {
                  // Hata durumunda, butonu pasif hale getirmek en güvenlisi.
                  return _publishButton('YAYINLA', () {});
                },
              ),
            ],
          ),

          const Divider(),

          // Alt taraftaki navigasyon linkleri
          _tile('Merino çizgi nedir', () => onNavTap(merinoKey)),
          _tile('Çizgi Romanlar', () => onNavTap(comicsKey)),
          _tile('Sanatçılar', () => onNavTap(artistsKey)),
        ],
      ),
    );
  }

  Widget _tile(String text, VoidCallback onTap) {
    return ListTile(
      title: Text(text),
      onTap: onTap,
    );
  }
}

/// Kullanıcı menüsü için seçenekler
enum _UserMenuOptions {
  account,
  adminPanel,
  logout,
}

// --- BU METODU YENİ EKLİYORUZ ---
/// Çıkış yapmadan önce kullanıcıdan onay isteyen bir diyalog gösterir.
Future<void> _showSignOutConfirmationDialog(
    BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'Çıkış Yap',
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(color: Colors.black),
        ),
        content: const Text('Oturumu kapatmak istediğinize emin misiniz?'),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () async {
                // Önce diyaloğu kapat.
                Navigator.of(dialogContext).pop();

                // Sonra çıkış işlemini gerçekleştir.
                await FirebaseAuth.instance.signOut();

                // İsteğe bağlı: Çıkış sonrası kullanıcıya bir bildirim gösterilebilir.
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text("Başarıyla çıkış yapıldı.")),
                // );
              },
              child: const Text('Çıkış Yap'))
        ],
      );
    },
  );
}

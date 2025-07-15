// lib/features/home/widgets/home_appbar.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/features/auth/controller/auth_providers.dart';
import 'package:merinocizgi/features/auth/widgets/login_dialogs.dart';

/// HomeAppBar artık bir ConsumerWidget. Böylece Riverpod'dan authStateProvider'ı izleyebiliyoruz.
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isTablet;
  final VoidCallback onMenuTap;
  final void Function(GlobalKey) onNavTap;
  final VoidCallback onPublish;
  final VoidCallback onLogin; // ← Yeni eklenen satır
  final GlobalKey merinoKey, comicsKey, artistsKey;

  const HomeAppBar({
    Key? key,
    required this.merinoKey,
    required this.comicsKey,
    required this.artistsKey,
    required this.isTablet,
    required this.onMenuTap,
    required this.onNavTap,
    required this.onPublish,
    required this.onLogin, // ← Yeni eklenen satır
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Riverpod üzerinden auth state'i oku:
    final authStateAsync = ref.watch(authStateProvider); // İsmi daha
    // final _scaffoldKey = GlobalKey<ScaffoldState>();

    // authState bir AsyncValue<User?> döner.

    return AppBar(
      toolbarHeight: 100,
      backgroundColor: AppColors.primary,
      title: GestureDetector(
        // onTap: () => onNavTap(merinoKey),
        onTap: () => context.go('/'),
        child: Image.asset(
          'assets/images/merino.png',
          height: 100,
        ),
      ),
      centerTitle: false,

      // Küçük ekranda hamburger ikonu
      leading: isTablet
          ? null
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            ),

      // Büyük ekranda nav + publish + login veya kullanıcı menüsü
      actions: isTablet
          ? <Widget>[
              _navButton(
                  'Merino çizgi nedir',
                  () => merinoKey.currentContext != null
                      ? onNavTap(merinoKey)
                      : context.go('/')),
              _navButton(
                  'Çizgi Romanlar',
                  () => comicsKey.currentContext != null
                      ? onNavTap(comicsKey)
                      : context.go('/')),
              _navButton(
                  'Sanatçılar',
                  () => artistsKey.currentContext != null
                      ? onNavTap(artistsKey)
                      : context.go('/')),
              const SizedBox(width: 20),

// lib/features/home/widgets/home_appbar.dart -> build metodu içinde
              // 1) Kullanıcı oturum durumuna göre “YAYINLA” veya giriş dialog göster:
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
                    return _publishButton('YAYINLA', () async {
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
                    });
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
              const SizedBox(width: 20),

              // 2) Kullanıcı oturum durumuna göre “Giriş Yap” veya kullanıcı menüsü göster:

              authStateAsync.when(
                data: (authState) {
                  // authState artık AuthState nesnesi
                  // Senaryo 1: Kullanıcı giriş yapmamış.
                  if (authState.user == null) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
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
                    final userProfileAsync = ref.watch(userProfileProvider);

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

                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: _userMenu(displayName, context, ref),
                          );
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
                            padding: const EdgeInsets.only(right: 20),
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
              const SizedBox(width: 8),
            ]
          : <Widget>[],
    );
  }

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
  // --- YENİ METOT SONU ---

  Widget _navButton(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label.toUpperCase(), style: AppTextStyles.title),
    );
  }

  Widget _loginButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          // side: const BorderSide(color: Colors.white),
          ),
      child: Text(label.toUpperCase(), style: AppTextStyles.title),
    );
  }

  Widget _publishButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      // style: OutlinedButton.styleFrom(
      //   side: const BorderSide(color: Colors.white),
      //   backgroundColor: AppColors.accent,
      // ),
      onPressed: onTap,
      child: Text(label.toUpperCase(), style: AppTextStyles.title),
    );
  }

  /// Kullanıcı menüsü: Kullanıcı adına tıklayınca popup menü gösterir.
  Widget _userMenu(String displayName, BuildContext context, WidgetRef ref) {
    final bool isUserAdmin = ref.watch(isAdminProvider);

    return PopupMenuButton<_UserMenuOptions>(
      tooltip: 'Menüyü göster',
      // 1) İkon ya da “displayName” gözüken buton olarak:
      offset: const Offset(-5, 40),
      // color: Colors.grey.shade500,
      color: Colors.grey.shade600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      onSelected: (_UserMenuOptions choice) async {
        switch (choice) {
          case _UserMenuOptions.account:
            context.go('/account');
            break;
          case _UserMenuOptions.adminPanel:
            // context.go('/adminPanel');
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
        constraints: const BoxConstraints(
          maxWidth: 200, // Örneğin, maksimum 200 piksel genişliğinde olsun.
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                displayName,
                style: AppTextStyles.title.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Sığmazsa sonuna '...' koy
                softWrap: false, // Alt satıra kaymasını engelle
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kullanıcı menüsü için seçenekler
enum _UserMenuOptions {
  // subscribed,
  // comments,
  // creators,

  account,
  adminPanel,
  logout,
}

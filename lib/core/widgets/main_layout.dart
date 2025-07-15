// lib/features/shared/view/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/features/auth/controller/auth_controller.dart';
import 'package:merinocizgi/features/auth/widgets/login_method_dialog.dart';
import 'package:merinocizgi/features/home/controller/home_controller.dart';
import 'package:merinocizgi/features/auth/widgets/email_login_dialog.dart';
import 'package:merinocizgi/features/home/widgets/home_appbar.dart';
import 'package:merinocizgi/features/home/widgets/home_drawer.dart';

class MainLayout extends ConsumerStatefulWidget {
  // Bu widget, GoRouter tarafından verilecek olan asıl sayfa içeriğini tutar.
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  // ScaffoldKey ve diğer key'ler artık sadece burada, tek bir yerde tanımlanacak.
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final merinoKey = GlobalKey();
  final comicsKey = GlobalKey();
  final artistsKey = GlobalKey();

  // ─── A) “Giriş Yap” seçim dialog’unu açan fonksiyon ───────────────────
  void _showLoginMethodPopup() {
    showDialog(
      context: context,
      builder: (_) => LoginMethodDialog(
        onEmailSelected: () {
          Navigator.of(context).pop();
          _showEmailLoginPopup();
        },
        onGoogleSelected: () async {
          Navigator.of(context).pop();
          await ref.read(authControllerProvider.notifier).signInWithGoogle();
        },
      ),
    );
  }

  // ─── B) “E-posta ile Giriş” dialog’unu açan fonksiyon ────────────────
  void _showEmailLoginPopup() {
    showDialog(
      context: context,
      builder: (_) => const EmailLoginDialog(isLoginMode: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTabletUp = context.isTablet;
    final homeController = ref.read(homeControllerProvider);

    // Key'leri provider'dan oku.
    final merinoKey = ref.watch(merinoKeyProvider);
    final comicsKey = ref.watch(comicsKeyProvider);
    final artistsKey = ref.watch(artistsKeyProvider);

    return Scaffold(
      key: _scaffoldKey, // Anahtarımızı buradaki Scaffold'a atıyoruz.
      drawer: isTabletUp
          ? null
          : HomeDrawer(
              merinoKey: merinoKey,
              comicsKey: comicsKey,
              artistsKey: artistsKey,
              // onNavTap'te artık doğrudan controller'ın metodunu çağırıyoruz.
              onNavTap: (key) {
                // --- DÜZELTME BURADA ---
                // Mevcut rota durumunu al.
                final currentState = GoRouterState.of(context);
                // O anki yolun string halini al.
                final currentLocation = currentState.uri.toString();

                // Eğer ana sayfada değilsek, önce ana sayfaya git, sonra scroll et.
                if (currentLocation != '/') {
                  context.go('/');
                  // Kısa bir gecikme, sayfanın yüklenmesini ve key'lerin oluşmasını sağlar.
                  Future.delayed(const Duration(milliseconds: 50), () {
                    homeController.scrollTo(key);
                  });
                } else {
                  homeController.scrollTo(key);
                }
                Navigator.of(context).pop(); // Drawer'ı kapat
              },
              onLogin: () {
                Navigator.of(context).pop();
                _showLoginMethodPopup();
              },
              onPublish: () {
                Navigator.of(context).pop();
                context.go("/create-comic");
              },
            ),
      appBar: HomeAppBar(
        merinoKey: merinoKey,
        comicsKey: comicsKey,
        artistsKey: artistsKey,
        isTablet: isTabletUp,
        // Drawer açma mantığı artık her zaman çalışır.
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onNavTap: homeController.scrollTo,
        onPublish: () => context.go("/create-comic"),
        onLogin: _showLoginMethodPopup,
      ),
      // 'body' olarak artık GoRouter'ın bize verdiği 'child' widget'ını kullanıyoruz.
      body: widget.child,
    );
  }
}

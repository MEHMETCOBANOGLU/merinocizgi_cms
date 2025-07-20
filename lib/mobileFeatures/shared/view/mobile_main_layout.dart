// lib/features/shared/view/mobile_main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/bottom_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/home_app_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

class MobileMainLayout extends ConsumerWidget {
  final Widget child;

  const MobileMainLayout({Key? key, required this.child}) : super(key: key);

  // Bu metot, her bir butona basıldığında ne olacağını merkezi olarak yönetir.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);
    List<Widget>? getAppBarActions(BuildContext context) {
      final location = GoRouterState.of(context).uri.toString();

      if (location == '/myAccount') {
        return [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          )
        ];
      }

      return null;
    }

    // Alt bar'ın kaplayacağı yükseklik
    const double bottomBarTotalHeight = 0.0;

    return Scaffold(
      appBar: MobileHomeAppBar(actions: getAppBarActions(context)),
      body: Stack(
        children: [
          // 1. Katman: Ana İçerik
          // İçeriğin en altının, bar ve altındaki gradyan tarafından
          // gizlenmemesi için bir SafeArea veya Padding kullanabiliriz.
          Positioned.fill(
            child: child,
          ),

          // --- YENİ EKLENEN GRADYAN VE BOŞLUK ---
          // Bu, içeriğin bar'ın arkasında yavaşça kaybolmasını sağlar.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: bottomBarTotalHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6], // Gradyanın geçişini ayarla
                  ),
                ),
              ),
            ),
          ),

          // 2. Katman: Süzülen Alt Bar
          // Konumlandırma sorumluluğu artık burada.
          Positioned(
            left: 34.0,
            right: 34.0,
            bottom: 16.0, // Alt kenardan boşluk
            child: BottomBarWidget(
              selectedIndex: selectedBottomBarIndex,
              onItemSelected: (index) => onItemTapped(index, ref, context),
              items: [
                BottomBarItem(
                    icon: Icons.home_outlined,
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.white),
                BottomBarItem(
                    icon: Icons.people_alt_sharp,
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.white),
                BottomBarItem(
                    icon: Icons.search_outlined,
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.white),
                BottomBarItem(
                    icon: Icons.person_outlined,
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

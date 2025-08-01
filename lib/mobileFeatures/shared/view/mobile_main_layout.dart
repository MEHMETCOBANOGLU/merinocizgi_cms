// lib/features/shared/view/mobile_main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/books_tab_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/bottom_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/home_app_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

class MobileMainLayout extends ConsumerWidget implements PreferredSizeWidget {
  final Widget child;

  const MobileMainLayout({Key? key, required this.child}) : super(key: key);
  @override
  Size get preferredSize => const Size.fromHeight(100);
  // Bu metot, her bir butona basıldığında ne olacağını merkezi olarak yönetir.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);
    // Mevcut rotanın yolunu alıyoruz.
    final location = GoRouterState.of(context).uri.toString();
    // TabBar'ın sadece ana sayfada ('/') görünmesini sağlıyoruz.
    final bool isHomePage = (location == '/');

    // Alt bar'ın kaplayacağı yükseklik
    const double bottomBarTotalHeight = 0.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          // Sol taraftaki logo
          leadingWidth: 100,
          leading:
              Image.asset('assets/images/merino.png', fit: BoxFit.fitHeight),

          // 'title' parametresini, sekmeleri içeren bir Row ile dolduruyoruz.
          // 'Expanded' kullanarak, sekmelerin 'actions'a kadar olan tüm boşluğu doldurmasını sağlıyoruz.
          title: isHomePage
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: preferredSize.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        transform: const GradientRotation(1.1),
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.primary
                              .withOpacity(0.40), // Opacity azaltıldı
                          AppColors.primary.withOpacity(0.20),
                          AppColors.primary.withOpacity(0.10),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: TabBar(
                      splashFactory: NoSplash
                          .splashFactory, //  tıklama / focus olayları için bir ripple splash (çarpma efekti) uygulamasını kaldırma
                      // TabBar'ın kendi padding'ini ve boyutunu ayarlıyoruz
                      isScrollable:
                          true, // Dar ekranlarda kaydırılabilir olmasını sağlar
                      tabAlignment: TabAlignment.start,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),

                      indicator: UnderlineTabIndicator(
                        borderSide: const BorderSide(
                            width: 4.0, color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12.0),
                        insets: const EdgeInsets.symmetric(
                            horizontal: 40.0), // Soldan ve sağdan boşluk
                      ),
                      // indicatorSize: TabBarIndicatorSize.,

                      labelStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                      ),

                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Çizgi'),
                        Tab(text: 'Kitap'),
                      ],
                    ),
                  ),
                )
              : null, // Ana sayfada değilse başlık gösterme

          // Sağ taraftaki aksiyon butonları
          actions: getAppBarActions(context, location),
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. Katman: Ana İçerik
            // İçeriğin en altının, bar ve altındaki gradyan tarafından
            // gizlenmemesi için bir SafeArea veya Padding kullanabiliriz.
            Positioned.fill(
              child: isHomePage
                  ? TabBarView(
                      children: [
                        // SEKME 1: Çizgi Romanlar (Mevcut HomePage içeriği)
                        // HomePage'in kendisini buraya koyuyoruz.
                        child,

                        // SEKME 2: Kitaplar
                        // Bu, kitapları listeleyecek YENİ bir widget.
                        const BooksTabPage(), // Bu widget'ı oluşturacağız.
                      ],
                    )
                  : child, // Diğer sayfalar (MyAccountPage vb.)
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
              left: 24.0,
              right: 24.0,
              bottom: 8.0, // Alt kenardan boşluk
              child: BottomBarWidget(
                selectedIndex: selectedBottomBarIndex,
                onItemSelected: (index) => onItemTapped(index, ref, context),
                items: [
                  BottomBarItem(
                      icon: Icons.home_sharp,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white),
                  BottomBarItem(
                      icon: Icons.people_alt_sharp,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white),
                  BottomBarItem(
                      icon: Icons.add_box_outlined,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white),
                  BottomBarItem(
                      icon: Icons.search_outlined,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white),
                  BottomBarItem(
                      icon: Icons.person_sharp,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar'daki aksiyon butonlarını, bulunulan sayfaya göre dinamik hale getiren
  // yardımcı bir metot.
  List<Widget>? getAppBarActions(BuildContext context, String location) {
    if (location.startsWith('/myAccount')) {
      return [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        )
      ];
    }
    // Diğer sayfalar için farklı aksiyonlar eklenebilir.
    return null;
  }
}

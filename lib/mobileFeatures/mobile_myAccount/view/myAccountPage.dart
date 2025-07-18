// lib/mobileFeatures/account/view/myAccountPage.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_auth/view/loginPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/bottom_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_home/widget/home_app_bar_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/followers_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/following_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/my_series_list.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/reading_history_list.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/reading_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/profile_header.dart';

// Seçili olan profil sekmesinin (Okumaya Devam Et, Serilerim vb.) state'ini tutar.
final _selectedProfileTabIndexProvider =
    StateProvider.autoDispose<int>((ref) => 0);

class MyAccountPage extends ConsumerWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  // Sabit verileri build metodu dışında tanımlamak en iyi pratiktir.
  static const List<String> _tabs = [
    'Okumaya Devam Et',
    'Serilerim',
    'Okuma Listesi',
    'Süper Beğeni',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state'ini ve seçili sekme index'ini izle.
    final authStateAsync = ref.watch(authStateProvider);
    final selectedTabIndex = ref.watch(_selectedProfileTabIndexProvider);
    final selectedBottomBarIndex = ref.watch(selectedBottomBarIndexProvider);

    // Auth state'i hala yükleniyorsa veya hata varsa, bir bekleme ekranı göster.
    if (authStateAsync is! AsyncData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Kullanıcı giriş yapmamışsa, login sayfasını göster.
    if (authStateAsync.value?.user == null) {
      return const MobileLoginPage();
    }

    // DefaultTabController, TabBar ve TabBarView'ın senkronize çalışmasını sağlar.
    // Bu, sekmeli yapılar için en doğru ve performanslı yöntemdir.
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        // AppBar ve BottomNavigationBar artık MobileMainLayout'tan (ShellRoute) geliyor.
        // Bu sayfanın kendi AppBar'ına ihtiyacı var.
        appBar: MobileHomeAppBar(
          // title: authStateAsync.value?.user?.displayName ?? 'Profilim',
          actions: [
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. Profilin üst bilgilerini (Avatar, isim, takipçi sayısı) içeren bölüm.
              SliverToBoxAdapter(
                child: ProfileHeader(
                  authorId: authStateAsync.value!.user!.uid,
                ),
              ),
              // 2. Sekmelerin olduğu, kaydırıldığında yukarıya yapışan bar.
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    onTap: (index) => ref
                        .read(_selectedProfileTabIndexProvider.notifier)
                        .state = index,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: _tabs.map((label) => Tab(text: label)).toList(),
                  ),
                ),
                pinned: true, // Bu, TabBar'ın yukarıya yapışmasını sağlar.
              ),
            ];
          },
          // 3. Sekmelere karşılık gelen içerik.
          body: TabBarView(
            children: [
              const ReadingHistoryList(), // En Son
              MySeriesyList(userId: authStateAsync.value!.user!.uid),
              MyReadingListPage(),

              // const UserCommentsWidget(), // Yorumlar
              // const UserSuperLikesWidget(),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            child: BottomBarWidget(
              items: [
                BottomBarItem(
                  icon: Icons.home_outlined,
                  color: selectedBottomBarIndex == 0
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 0;
                    context.go('/');
                  },
                ),
                BottomBarItem(
                  icon: Icons.favorite_border,
                  color: selectedBottomBarIndex == 1
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 1;
                  },
                ),
                BottomBarItem(
                  icon: Icons.search_outlined,
                  color: selectedBottomBarIndex == 2
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 2;
                  },
                ),
                BottomBarItem(
                  icon: Icons.person_outlined,
                  color: selectedBottomBarIndex == 3
                      ? AppColors.primary
                      : Colors.white,
                  onTap: () {
                    ref.read(selectedBottomBarIndexProvider.notifier).state = 3;
                    context.push('/myAccount');
                  },
                ),
              ],
            )),
      ),
    );
  }
}

// --- BU SAYFAYA ÖZEL ALT WIDGET'LAR ---

// TabBar'ı yapışkan hale getirmek için gereken delegate sınıfı.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Arka plan rengi
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
